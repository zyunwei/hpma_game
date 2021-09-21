CustomEvents('xxwar_cast_pickup', function(e, data)
	if data == nil or data.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end

	local hero = player:GetAssignedHero()
	if IsNull(hero) then return end

	if hero:IsSilenced() or hero:IsRooted() or hero:IsStunned() then
		return
	end

    if hero:IsChanneling() then
        return
    end

    local vItemDrops = Entities:FindAllByClassname("dota_item_drop")
    local pickupRange = 300
    local drops = {}
    for _, drop in pairs(vItemDrops) do
        if NotNull(drop) then
            local item = drop:GetContainedItem()
            if NotNull(item) then
            	local len = (drop:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D()
                if len < pickupRange then
                	table.insert(drops, { containner = drop, len = len})
                end
            end
        end
    end

    table.sort(drops, function(a, b)
        return a.len < b.len
    end)

    if #drops > 0 then
    	for _, v in pairs(drops) do
	    	local item = v.containner:GetContainedItem()
	    	if hero:AddItem(item) then
	    		v.containner:RemoveSelf()
	    	end
	    end    	
    else
    	hero:ShowCustomMessage({type="bottom", msg={"xxwar_no_items_nearby"}, class="error"})
    end
end)

CustomEvents('avalon_get_item_tooltip_data', function(e, data)
	if data == nil or data.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end

	local hero = player:GetAssignedHero()
	if IsNull(hero) then return end

	-- 获取物品属性
	local item = EntIndexToHScript(data.item)
	if not item then return end

	local custom_attributes
	if item:HasCustomAttributes() then
		custom_attributes = item:GetAllCustomAttribute()
	end

	local compare = true
	for i=0,5 do
		local _item = hero:GetItemInSlot(i)
		if _item == item then
			compare = false
			break
		end
	end

	local compareItem1
	local compareItem1_Config
	local compareItem1_Specials
	local compareItem1_CustomAttributes
	local compareItem1_CustomData
	local inventoryItemCooldown = nil
	
	if compare then
		-- 获取比较的装备
		local inventorySlot = EquipCtrl:GetSlot(item)
		if inventorySlot >= 0 then
			local inventoryItem = hero:GetItemInSlot(inventorySlot)
			if inventoryItem and inventoryItem ~= item then

				compareItem1 = inventoryItem:GetEntityIndex()
				compareItem1_Config = ItemConfig[inventoryItem:GetAbilityName()]
				compareItem1_Specials = inventoryItem:GetAbilityKeyValues()["AbilitySpecial"]
				compareItem1_CustomData = inventoryItem:GetCustomData()
				inventoryItemCooldown = inventoryItem:GetCooldown(1)
				if inventoryItem:HasCustomAttributes() then
					compareItem1_CustomAttributes = inventoryItem:GetAllCustomAttribute()
				end

			end
		end
	end

	local item_specials = item:GetAbilityKeyValues()["AbilitySpecial"] or {}

	CustomGameEventManager:Send_ServerToPlayer(player, "avalon_get_item_tooltip_data_response", {
		item=data.item, specials=item_specials, custom_attributes=custom_attributes, config=ItemConfig[item:GetAbilityName()],
		custom_data = item:GetCustomData(),
		compareItem1=compareItem1, compareItem1_Specials=compareItem1_Specials,compareItem1_CustomAttributes=compareItem1_CustomAttributes, 
		compareItem1_Config=compareItem1_Config, compareItem1_CustomData=compareItem1_CustomData,
		cooldown = item:GetCooldown(1),
		compareItem1_cooldown = inventoryItemCooldown
		})
end)

CustomEvents('avalon_get_item_tooltip_data_for_kv', function(e, data)
	if data == nil or data.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end

	local hero = player:GetAssignedHero()
	if IsNull(hero) then return end

	local itemname = data.itemname or ""
	local kv = ItemsKV[itemname]
	if not kv then return end

	local compareItem1
	local compareItem1_Config
	local compareItem1_Specials
	local compareItem1_CustomAttributes
	local compareItem1_CustomData
	
	-- 获取比较的装备
	local inventorySlot = EquipCtrl:GetSlotForItemName(itemname)
	if inventorySlot >= 0 then
		local inventoryItem = hero:GetItemInSlot(inventorySlot)
		if inventoryItem then

			compareItem1 = inventoryItem:GetEntityIndex()
			compareItem1_Config = ItemConfig[inventoryItem:GetAbilityName()]
			compareItem1_Specials = inventoryItem:GetAbilityKeyValues()["AbilitySpecial"]
			compareItem1_CustomData = inventoryItem:GetCustomData()
			if inventoryItem:HasCustomAttributes() then
				compareItem1_CustomAttributes = inventoryItem:GetAllCustomAttribute()
			end

		end
	end

	CustomGameEventManager:Send_ServerToPlayer(player, "avalon_get_item_tooltip_data_for_kv_response", {
		itemname = data.itemname, kv=kv, config=ItemConfig[itemname],
		compareItem1=compareItem1, compareItem1_Specials=compareItem1_Specials,compareItem1_CustomAttributes=compareItem1_CustomAttributes, 
		compareItem1_Config=compareItem1_Config, compareItem1_CustomData=compareItem1_CustomData,
	})
end)

-- 分配属性点
CustomEvents('assign_attribute_points', function(e, data)
	if data == nil or data.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end

	local hero = player:GetAssignedHero()
	if IsNull(hero) then return end

	local name = data.name or ""
	if name ~= "str" and name ~= "agi" and name ~= "int" then
		return
	end

	if hero:SpendAssignAttributePoints(1) then
		hero:ModifyCustomAttribute(name,"assign_attribute_points",1)
	end
end)

-- 随机分配属性点
CustomEvents('assign_attribute_points_random', function(e, data)
	if data == nil or data.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end

	local hero = player:GetAssignedHero()
	if IsNull(hero) then return end

	local points = hero:GetAssignAttributePoints()
	if points > 0 and hero:SpendAssignAttributePoints(points) then
		local a = 1
		for i=1,points do
			if a == 1 then
				hero:ModifyCustomAttribute("str","assign_attribute_points",1)
			elseif a == 2 then
				hero:ModifyCustomAttribute("agi","assign_attribute_points",1)
			elseif a == 3 then
				hero:ModifyCustomAttribute("int","assign_attribute_points",1)
			end
			a = (a%3) + 1
		end
	end
end)

-- 切换自动释放
CustomEvents('toggle_ability_autocast', function(e, data)
	if data == nil or data.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end

	local hero = player:GetAssignedHero()
	if IsNull(hero) then return end

	local ability = EntIndexToHScript(data.ability)
	if not ability then return end

	if ability:GetLevel() > 0 and bitContains(ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_AUTOCAST) then
		ability:ToggleAutoCast()
	end
end)

CustomEvents('set_enemy_info_target', function(e, data)
	local playerInfo = GameRules.XW.PlayerList[data.PlayerID]
    if playerInfo == nil or playerInfo.IsBot then
        return
    end

    if playerInfo.Hero ~= nil then
    	playerInfo.Hero.LastShowEnemyUnitEntIndex = data.target
    end
end)

CustomEvents('select_region', function(e, data)
	if data == nil or data.PlayerID == nil then return end

	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end

	local hero = player:GetAssignedHero()
	if IsNull(hero) then return end

	local ability = hero:FindAbilityByName("ability_xxwar_teleport")
	if IsNull(ability) then return end

	local teleportTarget = TELEPORT_POSITION[data.RegionId]
	if teleportTarget == nil then return end

	local findEntities = Entities:FindAllByClassname("npc_dota_techies_mines")
	local target = nil
	for _, v in pairs(findEntities) do
		if v:GetUnitName() == "npc_teleport" and (v:GetAbsOrigin() - teleportTarget):Length2D() < 500 then
			target = v
			break
		end
	end

	if IsNull(target) then return end

	hero:CastAbilityOnTarget(target, ability, data.PlayerID)
end)

CustomEvents('xxwar_respawn', function(e, data)
	if data == nil or data.PlayerID == nil then return end

	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end

	local playerInfo = GameRules.XW:GetPlayerInfo(data.PlayerID)

	local hero = player:GetAssignedHero()
	if IsNull(hero) then return end

	if hero.Respawn ~= nil then
		if hero.LastRespawnTime ~= nil and GameManager:GetGameTime() < hero.LastRespawnTime + 2 then
			return
		end
		playerInfo.TaskTable.respawn_count = playerInfo.TaskTable.respawn_count + 1
		hero.LastRespawnTime = GameManager:GetGameTime()
		local postData = { SteamAccountId = playerInfo.SteamAccountId, GameId = GameRules.XW.GameId }
			HttpPost("api/Member/RespawnHero", postData, function(result)
			if(result.isSuccess and result.tag ~= nil) then
				playerInfo.XXCoin = result.tag.coin
				playerInfo.Bullion = result.tag.bullion
        		playerInfo.RespawnCoin = result.tag.respawnCoin
        		playerInfo.RespawnCount = playerInfo.RespawnCount + 1
				playerInfo.TaskTable.use_repsawn_coin_count = playerInfo.TaskTable.use_repsawn_coin_count + 1

        		-- 复活的人自己头上加50元宝
        		local selfBounty = 50
        		playerInfo.BountyBullion = playerInfo.BountyBullion + selfBounty

    			local killerPlayerInfo = GameRules.XW:GetPlayerInfo(playerInfo.LastKillerPlayerId)
    			if killerPlayerInfo ~= nil and killerPlayerInfo.IsAlive then
    				-- 之前击杀的人头上加50元宝
    				killerPlayerInfo.BountyBullion = killerPlayerInfo.BountyBullion + 50

    				-- 给之前击杀的人账户加50元宝，会员加倍
    				local bountyAmount = 50
    				if killerPlayerInfo.IsVip then
	        			bountyAmount = bountyAmount * 2
	        		end
		    		if killerPlayerInfo.IsBot == false and NotNull(killerPlayerInfo.Hero) then
		    			killerPlayerInfo.SavedBullion = killerPlayerInfo.SavedBullion + bountyAmount
			    		local postData = { SteamAccountId = killerPlayerInfo.SteamAccountId, GameId = GameRules.XW.GameId, amount = bountyAmount, remark = 'KILL_RESPAWN' }
					    HttpPost("api/Member/DepositBullion", postData, function(result)
					        if(result.isSuccess) then
					        	killerPlayerInfo.Hero:ShowCustomMessage({type="bottom", msg={bountyAmount, "xxwar_increase_bullion"}, class="success"})
					        else
					        	ShowGlobalMessage(result.message)
					        end
					    end)
					end

    				playerInfo.LastKillerPlayerId = nil
    			end

				-- 本局奖池加150元宝
				local jackpotBullion = 150
				GameRules.XW.Jackpot = GameRules.XW.Jackpot + jackpotBullion
				CustomMessage:all({
                    type="bottom",
                    class="success",
                    msg={"xxwar_jackpot_increased", jackpotBullion, "xxwar_store_bullion"}
                })

                -- 世界奖池加250元宝
                local globalJackpot = 250
                local postData = { SteamAccountId = playerInfo.SteamAccountId, GameId = GameRules.XW.GameId, amount = globalJackpot, remark = 'respawn' }
			    HttpPost("api/Jackpot/AddJackpot", postData, function(result)
			    	-- table.print(result)
			    end)

				if (GetMapName() == "3x2" or GetMapName() == "1x8" or GetMapName() == "3x3" or GetMapName() == "2x4") and GameManager:IsInPalaceDead(hero) then
			    	local respawnPos = table.random(GameManager.StartPosList[playerInfo.TeamId])
			    	playerInfo.Hero:DelayRespawn(0.1, respawnPos.pos)
			    else
			    	hero:Respawn()	
			    end
			end
		end)
	end
end)

CustomEvents('xxwar_respawn_reload', function(e, data)
	if data == nil or data.PlayerID == nil then return end

	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end

	local playerInfo = GameRules.XW:GetPlayerInfo(data.PlayerID)

	local hero = player:GetAssignedHero()
	if IsNull(hero) then return end

	local postData = { SteamAccountId = playerInfo.SteamAccountId, GameId = GameRules.XW.GameId }
	    HttpPost("api/Member/GetCoinInfo", postData, function(result)
	        if(result.isSuccess and result.tag ~= nil) then
	        	playerInfo.XXCoin = result.tag.coin
	        	playerInfo.Bullion = result.tag.bullion
	        	playerInfo.RespawnCoin = result.tag.respawnCoin
	        else
	        	playerInfo.XXCoin = 0
	        	playerInfo.Bullion = 0
	        	playerInfo.RespawnCoin = 0
	        end
	    end)
end)

CustomEvents('check_team_state', function(e, data)
	if data == nil or data.PlayerID == nil then return end
	local playerInfo = GameRules.XW.PlayerList[data.PlayerID]
    if playerInfo == nil or playerInfo.IsBot then
        return
    end
	playerInfo.ShowDeathFrame = false
	local state = 0
	if GameManager:CheckTeamIsAlive(playerInfo.TeamId) then
		state = 1
	end
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(data.PlayerID),"check_team_state_response", {state = state})
end)

CustomEvents("xxwar_ability_swap", function(e, data)
	if data == nil or data.PlayerID == nil then return end

	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end

	local hero = player:GetAssignedHero()
	if IsNull(hero) then return end

	hero:SwapAbilities(data.abilityname, data.targetAbility, true, true)
end)

CustomEvents("xxwar_ability_discard", function(e, data)
	if data == nil or data.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end

	local hero = player:GetAssignedHero()
	if IsNull(hero) then return end

	local minorAbilities = CardGroupSystem:GetPlayerUsingCards(data.PlayerID)
	if table.contains(minorAbilities, data.abilityName) then
		local ability = hero:FindAbilityByName(data.abilityName)
		if NotNull(ability) then
            ability:StartCooldownByReduction(ability:GetCooldown(1))
            ability:MinorAbilityUsed()
        end
		return
	end
	
	hero:RemoveAbilityByName(data.abilityName)
end)

CustomEvents("xxwar_config_finish", function(e, data)
	if data == nil or data.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end
	local playerInfo = GameRules.XW:GetPlayerInfo(data.PlayerID)
	player:SetSelectedHero(data.HeroName)
	local cards = data.SelectedCards
	local groupIndex = CardGroupSystem:PlayerCreateCardGroup(data.PlayerID)
	for _, value in pairs(cards) do
		CardGroupSystem:PlayerAddCardToGroup(data.PlayerID, groupIndex, value)
		if string.find(value, "ability_custom_call_summon_") == 1 then
			local heroName = string.gsub(value, "ability_custom_call_summon_", "npc_dota_hero_")
			PrecacheUnitByNameAsync(heroName, function(...) end)
		end
	end
	CardGroupSystem:PlayerSelectCardGroup(data.PlayerID, groupIndex)
	CustomNetTables:SetTableValue("PlayerReadyInfo", tostring(data.PlayerID), {steamid = playerInfo.SteamId, msg = "xxwar_msg_set_ready"})
end)

CustomEvents("xxwar_get_cardpool_data", function(e, data)
	if data == nil or data.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end

	local cardList = CardGroupSystem:PlayerGetAllCards(data.PlayerID)
	local respData = {}
	for i, v in pairs(cardList) do
		respData[v.AbilityName] = {
			CrystalCost = v.CrystalCost,
			HeroLimit = v.HeroLimit,
			CardType = v.CardType,
			MaxCount = v.MaxCount,
			IsHidden = v.IsHidden,
			ForSell = v.ForSell,
			Classify = {},
		}

		for j, k in pairs(MINOR_CLASSIFY) do
			if table.contains(k, v.AbilityName) then
				table.insert(respData[v.AbilityName].Classify, j)
			end
		end
	end

	local playerInfo = GameRules.XW:GetPlayerInfo(data.PlayerID)
	if playerInfo ~= nil then
		local postData = { SteamAccountId = playerInfo.SteamAccountId}
		HttpPost("api/Member/GetPurchasedCard", postData, function(result)
	        if(result.isSuccess and result.tag ~= nil) then
				for _, v in pairs(result.tag) do
					if(respData[v]) then
						respData[v].ForSell = 0
					end
				end

				CustomGameEventManager:Send_ServerToPlayer(player, "xxwar_get_cardpool_data_res", respData)
	        end
	    end)
	end
end)

CustomEvents("xxwar_load_card_group", function(e, data)
	if data == nil or data.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end
	local playerInfo = GameRules.XW:GetPlayerInfo(data.PlayerID)
	CustomNetTables:SetTableValue("PlayerSelectedCards", tostring(data.PlayerID), nil)
	playerInfo.PrePickHero = data.HeroName
	local postData = { SteamAccountId = playerInfo.SteamAccountId, HeroName = "hpma_" .. data.HeroName}
	local cardGroups = {}
	cardGroups[0] = {
		Cards = NEW_COMER_CARDGROUP[data.HeroName],
		IsDefault = 0,
		IsNewComer = 1,
	}
	HttpPost("api/Member/GetCardGroup", postData, function(result)
        if(result.isSuccess and result.tag ~= nil) then
			for _, v in pairs(result.tag) do
				cardGroups[v.GroupIndex] = {}
				cardGroups[v.GroupIndex].Cards = json.decode(v.Cards)
				if v.IsDefault == true then
					cardGroups[v.GroupIndex].IsDefault = 1
				else
					cardGroups[v.GroupIndex].IsDefault = 0
				end
			end

			for _, v in pairs(cardGroups) do
				local validCards = {}
				for i, info in pairs(v.Cards) do
					if CardGroupSystem:CheckCardValid(info.name) then
						table.insert(validCards, info)
					end
				end
				v.Cards = validCards
			end
			CustomGameEventManager:Send_ServerToPlayer(player, "xxwar_load_card_group_res", cardGroups)
        else
            CustomGameEventManager:Send_ServerToPlayer(player, "xxwar_card_group_msg", {msg = result.message})
        end
    end)
end)

CustomEvents("xxwar_save_card_group", function(e, data)
	if data == nil or data.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end
	local playerInfo = GameRules.XW:GetPlayerInfo(data.PlayerID)
	local cardIndexTable = {}
	for i, _ in pairs(data.CardGroup) do
		table.insert(cardIndexTable, i)
	end
	table.sort(cardIndexTable)
	local sortedCards = {}
	for _, v in pairs(cardIndexTable) do
		table.insert(sortedCards, data.CardGroup[v])
	end

	local isDefault = false
	if data.IsDefault == 1 then isDefault = true end
	local postData = { SteamAccountId = playerInfo.SteamAccountId, HeroName = "hpma_" .. data.HeroName,
	GroupIndex = tonumber(data.GroupIndex), IsDefault = isDefault, Cards = sortedCards }
    HttpPost("api/Member/SaveCardGroup", postData, function(result)
		if result.isSuccess then
			CustomGameEventManager:Send_ServerToPlayer(player, "xxwar_card_group_saved", {msg = "xxwar_msg_saved_success", groupIndex = data.GroupIndex})
		else
            CustomGameEventManager:Send_ServerToPlayer(player, "xxwar_card_group_msg", {msg = result.message})
		end
	end)
end)

CustomEvents("xxwar_del_card_group", function(e, data)
	if data == nil or data.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end
	local playerInfo = GameRules.XW:GetPlayerInfo(data.PlayerID)
	local postData = { SteamAccountId = playerInfo.SteamAccountId, HeroName = "hpma_" .. data.HeroName, GroupIndex = tonumber(data.GroupIndex)}
	HttpPost("api/Member/DeleteCardGroup", postData, function(result)
		if result.isSuccess then
			CustomGameEventManager:Send_ServerToPlayer(player, "xxwar_del_card_group_refresh", {msg = "xxwar_msg_delete_success"})
		else
            CustomGameEventManager:Send_ServerToPlayer(player, "xxwar_card_group_msg", {msg = result.message})
		end
    end)
end)

CustomEvents("xxwar_custom_pet_item_swap", function(e, data)
	if data == nil or data.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end

	local hero = player:GetAssignedHero()
	if IsNull(hero) then return end

	local source_entity = EntIndexToHScript(data.source_entity)
	local source_item = EntIndexToHScript(data.source_item)
	local target_entity = EntIndexToHScript(data.target_entity)
	local target_slot = tonumber(data.target_slot)

	if IsNull(source_entity) or IsNull(source_item) or IsNull(target_entity) or target_slot == -1 then
		return
	end

	local pets = CallHeroPool:GetPlayerPets(data.PlayerID)
	local sourceEntityChecked = false
	local targetEntityChecked = false
	for _, v in pairs(pets) do
		if source_entity == v then
			sourceEntityChecked = true
		end
		if target_entity == v then
			targetEntityChecked = true
		end
	end

	if sourceEntityChecked == false and targetEntityChecked == false then
		return
	end

	if source_entity == target_entity then
		source_entity:SwapItems(target_slot, source_item:GetItemSlot())
		return
	end

	if hero:SpendGold(150) then 
		EmitSoundOnClient("General.Buy", player)
		local target_item = target_entity:GetItemInSlot(target_slot)
		local targetNewItem = nil
		if NotNull(target_item) then
			local targetItemName = target_item:GetAbilityName()
			targetNewItem = CreateItem(targetItemName, source_entity, source_entity)
			if(NotNull(targetNewItem)) then
				targetNewItem:SetPurchaseTime(0)
				targetNewItem:StartCooldown(target_item:GetCooldownTimeRemaining())
				targetNewItem:SetCurrentCharges(target_item:GetCurrentCharges())
				targetNewItem.SuggestSlot = source_item:GetItemSlot()
			end
			target_entity:RemoveItem(target_item)
		end

		local sourceItemName = source_item:GetAbilityName()
		local sourceeNewItem = CreateItem(sourceItemName, target_entity, target_entity)
		if(NotNull(sourceeNewItem)) then
			sourceeNewItem:SetPurchaseTime(0)
			sourceeNewItem:StartCooldown(source_item:GetCooldownTimeRemaining())
			sourceeNewItem:SetCurrentCharges(source_item:GetCurrentCharges())
			sourceeNewItem.SuggestSlot = target_slot
		end
		source_entity:RemoveItem(source_item)

		if NotNull(targetNewItem) then
			source_entity:AddItem(targetNewItem)
		end

		if NotNull(sourceeNewItem) then
			target_entity:AddItem(sourceeNewItem)
		end
	end
end)

CustomEvents("xxwar_pet_item_discard", function(e, data)
	if data == nil or data.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end

	local target_item = EntIndexToHScript(data.item_entity)

	if IsNull(target_item) then
		return
	end

	local pets = CallHeroPool:GetPlayerPets(data.PlayerID)
	local pet = target_item:GetParent()

	if table.contains(pets, pet) then
		pet:RemoveItem(target_item)
	end
end)

CustomEvents("xxwar_add_selected_card_to_nettable", function(e, data)
	local cardName = data.CardName
	local playerId = data.PlayerID
	local cards = CustomNetTables:GetTableValue("PlayerSelectedCards", tostring(playerId))
	if cards == nil then 
		cards = {}
	end
	local count = 0 
	for _, v in pairs(cards) do
		count = count + 1
	end
	if not table.contains(cards, cardName) then 
		cards[tostring(count + 1)] = cardName
		CustomNetTables:SetTableValue("PlayerSelectedCards", tostring(playerId), cards)
	end
end)

CustomEvents("xxwar_remove_selected_card_from_nettable", function(e, data)
	local cardName = data.CardName
	local playerId = data.PlayerID
	local cards = CustomNetTables:GetTableValue("PlayerSelectedCards", tostring(playerId))
	if cards == nil then 
		return
	end
	local newCards = {}
	for key, value in pairs(cards) do
		if value ~= cardName then 
			table.insert(newCards, value)
		end
	end
	CustomNetTables:SetTableValue("PlayerSelectedCards", tostring(playerId), newCards)
end)

CustomEvents("xxwar_get_ranking", function(e, data)
	if data == nil or data.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end

	local postData = {SteamId = tostring(PlayerResource:GetSteamID(data.PlayerID))}
	HttpPost("api/Member/GetTopPlayers", postData, function(result)
        if(result.isSuccess) then
        	CustomGameEventManager:Send_ServerToPlayer(player, "xxwar_show_ranking", result.tag)
        end
    end)
end)

CustomEvents("xxwar_get_task_status", function(e, data)
	if data == nil or data.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end

	local playerInfo = GameRules.XW.PlayerList[data.PlayerID]
    if playerInfo == nil or playerInfo.IsBot then
        return
    end

    local postData = { SteamAccountId = playerInfo.SteamAccountId, GameId = GameRules.XW.GameId }
    HttpPost("api/MemberTask/GetTaskStatus", postData, function(result)
    	if(result.isSuccess) then
    		local statusInfo = {}
    		statusInfo.task_status = result.tag

    		local task_data = {}
    		for i, v in pairs(GameRules.XW.TaskIndicatorNames) do
    			task_data[i] = playerInfo.ServerTaskTable[v]
    		end
    		statusInfo.task_data = task_data

    		local task_data_current = {}
    		for i, v in pairs(GameRules.XW.TaskIndicatorNames) do
    			task_data_current[i] = playerInfo.TaskTable[v]
    		end
    		statusInfo.task_data_current = task_data_current

    		statusInfo.task_indicators = GameRules.XW.TaskIndicators

        	CustomGameEventManager:Send_ServerToPlayer(player, "xxwar_show_task_status", statusInfo)
        end
    end)
end)

CustomEvents("xxwar_finish_task", function(e, data)
	if data == nil or data.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end

	local playerInfo = GameRules.XW.PlayerList[data.PlayerID]
    if playerInfo == nil or playerInfo.IsBot then
        return
    end

	local postData = { SteamAccountId = playerInfo.SteamAccountId, GameId = GameRules.XW.GameId, AwardId = data.AwardId }
	HttpPost("api/MemberTask/GetTaskAward", postData, function(result)
		if result.isSuccess then
			CustomGameEventManager:Send_ServerToPlayer(player, "xxwar_finish_task_response", result)	
		else
			playerInfo.Hero:ShowCustomMessage({type="bottom", msg={result.message}, class="error"})
		end
    end)
end)

CustomEvents("xxwar_get_img_item_award", function(e, data)
	if data == nil or data.PlayerID == nil then return end

	local playerInfo = GameRules.XW.PlayerList[data.PlayerID]
    if playerInfo == nil or playerInfo.IsBot then
        return
    end
	if playerInfo.LastGetImgAwardTime == nil then
		playerInfo.LastGetImgAwardTime = 0
	end

	if GameManager:GetGameTime() - playerInfo.LastGetImgAwardTime < 0.5 then return end

	playerInfo.LastGetImgAwardTime = GameManager:GetGameTime()
	local imgList = playerInfo.ImgItem
	local award = 0
	for k, v in pairs(imgList) do
		if k ~= "Changeable" then
			local itemInfo = {
				name = k,
				value = 0,
			}
			if v >= 3 and v < 9 then
				local count = math.floor(v / 3)
				itemInfo.value = -3
				for i = 1, count do
					award = award + AWARD[k.."_3"]
					playerInfo:UploadImgItem(itemInfo)
				end
			elseif v == 9 then
				print(v)
				award = award + AWARD[k.."_9"]
				itemInfo.value = -9
				playerInfo:UploadImgItem(itemInfo)
			end
		end
	end

	local postData = { SteamAccountId = playerInfo.SteamAccountId, GameId = GameRules.XW.GameId, amount = award, remark = 'IMG_AWARD' }
	HttpPost("api/Member/DepositBullion", postData, function(result)
		if(result.isSuccess) then
			playerInfo.Hero:ShowCustomMessage({type="bottom", msg={award, "xxwar_increase_bullion"}, class="success"})
		else
			ShowGlobalMessage(result.message)
		end
	end)
end)

CustomEvents("xxwar_select_img_item", function(e, data)
	if data == nil or data.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end

	local playerInfo = GameRules.XW.PlayerList[data.PlayerID]
    if playerInfo == nil or playerInfo.IsBot then
        return
    end

	playerInfo:UploadImgItem({name = "Changeable", value = -1})

	playerInfo:UploadImgItem({name = data.name, value = 1})
end)