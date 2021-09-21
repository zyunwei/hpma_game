-- 选择NPC，返回相关选项
CustomEvents('xxwar_event_select_npc', function(e, data)
	if data == nil or data.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end

	local hero = player:GetAssignedHero()
	if hero ==nil then return end

	local npc = EntIndexToHScript(data.unit or -1)
	if npc == nil then return end

	local btnList = NpcCtrl:GetNpcItems(npc)
	CustomGameEventManager:Send_ServerToPlayer(player, "xxwar_select_npc_response", {btnList = btnList, unit = data.unit})
end)

-- 购买物品
CustomEvents('xxwar_event_buy_item', function(e, data)
	if data == nil or data.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end
	local playerInfo = GameRules.XW:GetPlayerInfo(data.PlayerID)

	local hero = player:GetAssignedHero()
	if hero ==nil then return end

	local npc = EntIndexToHScript(data.unit or -1)
	if npc == nil then return end

	if not NpcCtrl:HasTouchingHero(npc, hero) then
		return Avalon:Throw(hero,"error_msg_not_near_npc")
	end

	local itemname = data.itemname
	local npcInfo = table.find(NPC_CONFIG, "unitName", npc:GetUnitName())
	if npcInfo ~= nil and npcInfo.options then
		for i, option in pairs(npcInfo.options) do
			if option.requireType == "gold" and option.targetName == itemname then
				if hero:SpendGold(option.requireAmount) then
					hero:AddOwnerItemByName(itemname)
					EmitSoundOnClient("General.Buy",PlayerResource:GetPlayer(hero:GetPlayerID()))
					playerInfo.TaskTable.buy_ability_book_count = playerInfo.TaskTable.buy_ability_book_count + 1
				end
				break
			end
		end
	end

	local items = NpcCtrl:GetNpcItems(npc)
	if #items > 0 then
		CustomGameEventManager:Send_ServerToPlayer(player, "xxwar_select_npc_response", {btnList = items, unit = data.unit})
	else
		CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "xxwar_touch_npc_close", {unit = npc})
	end
end)

-- 购买BOSS
CustomEvents('xxwar_event_buy_boss', function(e, data)
	if data == nil or data.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if player == nil then return end
	local playerInfo = GameRules.XW:GetPlayerInfo(data.PlayerID)

	local hero = player:GetAssignedHero()
	if hero == nil then return end

	if GameManager:GetGameTime() < GameRules.XW.BuyBossOpenTime and IsInToolsMode() == false then
		hero:ShowCustomMessage({type="bottom", msg="#xxwar_can_not_buy_boss", class="error"})
		return 
	end

	local npc = EntIndexToHScript(data.unit or -1)
	if npc == nil then return end

	if not NpcCtrl:HasTouchingHero(npc, hero) then
		return Avalon:Throw(hero,"error_msg_not_near_npc")
	end

	local npcInfo = table.find(NPC_CONFIG, "unitName", npc:GetUnitName())
	if npcInfo == nil then return end

	local buySuccess = false
	local bossname = data.itemname
	if npcInfo ~= nil and npcInfo.options then
		for i, option in pairs(npcInfo.options) do
			if option.requireType == "gold" and option.targetName == bossname then
				if hero:SpendGold(option.requireAmount) then
					table.remove(npcInfo.options, i)
					EmitSoundOnClient("General.Buy",PlayerResource:GetPlayer(hero:GetPlayerID()))
					buySuccess = true
					if string.find(bossname, "npc_boss_[%w%p]+_3") then
						playerInfo.TaskTable.summon_boss_lv3_count = playerInfo.TaskTable.summon_boss_lv3_count + 1
					end
				end
				break
			end
		end
	end

	if buySuccess then
		local particleIndex = ParticleManager:CreateParticle(ParticleRes.SummonBoss, PATTACH_WORLDORIGIN, nil)
		local particPos = Vector(npcInfo.bossPos.x, npcInfo.bossPos.y, GetGroundHeight(npcInfo.bossPos, nil))
		ParticleManager:SetParticleControl( particleIndex, 0, particPos + Vector(0, 0, 128) ) 
		ParticleManager:SetParticleControl( particleIndex, 6, particPos + Vector(0, 0, 128) ) 
		ParticleManager:SetParticleControl( particleIndex, 60, Vector(168, 100, 219) ) 
		ParticleManager:SetParticleControl( particleIndex, 61, Vector(168, 100, 219) ) 

		DelayDispatch(3, data.unit, function(bossname, npcInfo, particleIndex)
			local boss = CreateUnitByName(bossname, npcInfo.bossPos, true, nil, nil, DOTA_TEAM_NEUTRALS)
			boss.SpawnPosition = npcInfo.bossPos
			boss.IsBoss = true
			boss:SetContextThink("OnHeroThink", function() return BossAI:OnHeroThink(boss) end, 1)
			if string.find(bossname, "npc_boss_timbersaw") == 1 then
                EmitGlobalSound("XXWAR.RIM_SOUND_2")
            end
			ParticleManager:DestroyParticle(particleIndex, false)
		end, bossname, npcInfo, particleIndex)
	end
	
	local items = NpcCtrl:GetNpcItems(npc)
	if #items > 0 then
		CustomGameEventManager:Send_ServerToPlayer(player, "xxwar_select_npc_response", {btnList = items, unit = data.unit})
	else
		CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "xxwar_touch_npc_close", {unit = npc})
	end
end)

CustomEvents('xxwar_event_buy_creep_refresh', function (e, data)
	if data == nil or data.PlayerID == nil then return end
    local player = PlayerResource:GetPlayer(data.PlayerID)
    if player == nil then return end

    local hero = player:GetAssignedHero()
    if hero == nil then return end

    local npc = EntIndexToHScript(data.unit or -1)
    if npc == nil then return end

    if not NpcCtrl:HasTouchingHero(npc, hero) then
        return Avalon:Throw(hero,"error_msg_not_near_npc")
    end

    local npcInfo = table.find(NPC_CONFIG, "unitName", npc:GetUnitName())
    if npcInfo == nil then return end

    local target_name = data.itemname
    if npcInfo ~= nil and npcInfo.options then
        for i, option in pairs(npcInfo.options) do
            if option.requireType == "gold" and option.targetName == target_name then
                local needGold = RefreshCreepSystem:GetRegionRefreshCostGold(option.regionId)
                if hero:SpendGold(needGold) then
                    EmitSoundOnClient("General.Buy",PlayerResource:GetPlayer(hero:GetPlayerID()))
                    RefreshCreepSystem:RefreshCreeps(option.regionId)
                end
                break
            end
        end
    end
	
	CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "xxwar_touch_npc_close", {unit = npc})
end)

CustomEvents('xxwar_event_buy_creep_upgrade', function (e, data)
	if data == nil or data.PlayerID == nil then return end
    local player = PlayerResource:GetPlayer(data.PlayerID)
    if player == nil then return end

    local hero = player:GetAssignedHero()
    if hero == nil then return end

    local npc = EntIndexToHScript(data.unit or -1)
    if npc == nil then return end

    if not NpcCtrl:HasTouchingHero(npc, hero) then
        return Avalon:Throw(hero,"error_msg_not_near_npc")
    end

    local npcInfo = table.find(NPC_CONFIG, "unitName", npc:GetUnitName())
    if npcInfo == nil then return end

    local target_name = data.itemname
    if npcInfo ~= nil and npcInfo.options then
        for i, option in pairs(npcInfo.options) do
            if option.requireType == "gold" and option.targetName == target_name then
                local needGold = RefreshCreepSystem:GetRegionUpgradeCostGold(option.regionId)
                if needGold == nil then
                    break
                end
                if hero:SpendGold(needGold) then
                    EmitSoundOnClient("General.Buy",PlayerResource:GetPlayer(hero:GetPlayerID()))
                    RefreshCreepSystem:UpgradeCreeps(option.regionId)
                end
                break
            end
        end
    end
	
	CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "xxwar_touch_npc_close", {unit = npc})
end)

-- 靠近宝箱
CustomEvents('xxwar_event_select_treasure', function(e, data)
	if data == nil or data.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end

	local hero = player:GetAssignedHero()
	if hero ==nil then return end

	local npc = EntIndexToHScript(data.unit or -1)
	if npc == nil then return end

	local npcname = npc:GetUnitName()

	local items = TreasuresCtrl:GetTreasureItems(data.unit)

	CustomGameEventManager:Send_ServerToPlayer(player, "xxwar_event_select_treasure_response", {btnList = items, unit=data.unit})
end)

-- 拾取物品
CustomEvents('avalon_treasures_pickup_item', function(e, data)
	if data == nil or data.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end

	local hero = player:GetAssignedHero()
	if hero ==nil then return end

	local npc = EntIndexToHScript(data.unit or -1)
	if npc == nil then return end

	local bag = hero:GetBag()
	if bag and bag:CanCreateItem(data.itemname, 1) == false then
		Avalon:Throw(hero, "error_msg_bag_can_not_add_item", nil)
		return
	end

	hero:AddOwnerItemByName(data.itemname)

	TreasuresCtrl:RemoveItem(data.unit, data.itemname)

	local items = TreasuresCtrl:GetTreasureItems(data.unit)
	if #items > 0 then
		CustomGameEventManager:Send_ServerToPlayer(player, "xxwar_event_select_treasure_response", {btnList = items, unit=data.unit})
	else
		CustomGameEventManager:Send_ServerToPlayer(player, "xxwar_event_select_treasure_response", {btnList = {}, unit=data.unit})
		local modifiers = npc:FindAllModifiers()
		for _, v in pairs(modifiers) do
			npc:RemoveModifierByName(v:GetName())
		end
		npc:Destroy()
	end
end)

CustomEvents('xxwar_supply_pickup_item', function(e, data)
	if data == nil or data.PlayerID == nil then return end
    local player = PlayerResource:GetPlayer(data.PlayerID)
    if IsNull(player) then return end

    local hero = player:GetAssignedHero()
    if hero ==nil then return end

    local npc = EntIndexToHScript(data.unit or -1)
    if npc == nil then return end

    local bag = hero:GetBag()
    if bag and bag:CanCreateItem(data.itemname, 1) == false then
        Avalon:Throw(hero, "error_msg_bag_can_not_add_item", nil)
        return
    end

    hero:AddOwnerItemByName(data.itemname)
    SupplyCtrl:RemoveItemFromSupplyBox(data.unit, data.itemname)
    local items = SupplyCtrl:GetSupplyBoxItems(data.unit)
	if #items > 0 then
        CustomGameEventManager:Send_ServerToPlayer(player, "xxwar_event_select_treasure_response", {btnList = items, unit=data.unit})
	else
		CustomGameEventManager:Send_ServerToPlayer(player, "xxwar_event_select_treasure_response", {btnList = {}, unit=data.unit})
        local modifiers = npc:FindAllModifiers()
        for _, v in pairs(modifiers) do
            npc:RemoveModifierByName(v:GetName())
        end
        SupplyCtrl:RemoveSupplyBox(data.unit)
	end
end)

CustomEvents('xxwar_event_select_supply', function(e, data)
	if data == nil or data.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if player == nil then return end
	local hero = player:GetAssignedHero()
	if hero == nil then return end
	local supplyBoxIndex = data.unit
	local items = SupplyCtrl:GetSupplyBoxItems(supplyBoxIndex)
	CustomGameEventManager:Send_ServerToPlayer(player, "xxwar_event_select_treasure_response", {btnList = items, unit=data.unit})
end)