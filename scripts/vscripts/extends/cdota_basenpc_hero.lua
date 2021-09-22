
--@Class CDOTA_BaseNPC_Hero

--[[
Return hero's player steamID64

@return string
]]
function CDOTA_BaseNPC_Hero:GetSteamID()
	return tostring(PlayerResource:GetSteamID(self:GetPlayerID()))
end

function CDOTA_BaseNPC_Hero:HasVIP()
	return true
end

function CDOTA_BaseNPC_Hero:Respawn()
    if GameManager.IsGameOver then
        self:ShowCustomMessage({type="bottom", msg={"xxwar_gameover"}, class="error"})
        return
    end
	self:SetTimeUntilRespawn(0.1)
	self:SetRespawnPosition(self:GetAbsOrigin())
	self:RespawnHero(false, false)

	local playerId = self:GetPlayerID()
	local playerInfo = GameRules.XW:GetPlayerInfo(playerId)
	if playerInfo == nil then return end

	playerInfo.IsAlive = true
	playerInfo.ShowDeathFrame = false

    if GameManager.IsGameOver == false then
        GameManager:SetTeamDeathTime(playerInfo.TeamId, 0)
    end

	if IsNull(playerInfo.TombStone) == false then
		UTIL_Remove(playerInfo.TombStone)
		playerInfo.TombStone = nil
	end

	local particleIndex = ParticleManager:CreateParticle(ParticleRes.Respawn, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(particleIndex, 0, self:GetAbsOrigin())
    ParticleManager:SetParticleControl(particleIndex, 1, self:GetAbsOrigin())
	ParticleManager:SetParticleControl(particleIndex, 2, self:GetAbsOrigin())

	if(NotNull(self)) then
		-- 刷新小技能
	    for i = 0, 4 do
	        local ability = self:GetAbilityByIndex(i)
	        if(ability ~= nil and ability:GetLevel() > 0) then
	            if(ability:IsCooldownReady() == false) then
	                ability:EndCooldown()
	            end
	            if ability.RefreshCharges ~= nil then
	                ability:RefreshCharges()
	            end
	            ability:SetActivated(true)
	        end
	    end
		self:AddNewModifier(self, nil, "modifier_respawn_protection", { duration = 5 })
	end
end

function CDOTA_BaseNPC_Hero:DelayRespawn(delay, respawnPos)
    if GameManager.IsGameOver then
        self:ShowCustomMessage({type="bottom", msg={"xxwar_gameover"}, class="error"})
        return
    end
    self:SetTimeUntilRespawn(delay)
    self:SetRespawnPosition(respawnPos)
    local hero = self
    CreateTimer(function()
        if GameManager.IsGameOver == false and NotNull(hero) and IsAlive(hero) == false then
            hero:RespawnHero(false, false)

            local playerId = hero:GetPlayerID()
            local playerInfo = GameRules.XW:GetPlayerInfo(playerId)
            if playerInfo == nil then return end

            playerInfo.IsAlive = true
            playerInfo.ShowDeathFrame = false
            playerInfo.RespawnCount = playerInfo.RespawnCount + 1

            if GameManager.IsGameOver == false then
                GameManager:SetTeamDeathTime(playerInfo.TeamId, 0)
            end

            if IsNull(playerInfo.TombStone) == false then
                UTIL_Remove(playerInfo.TombStone)
                playerInfo.TombStone = nil
            end

            local particleIndex = ParticleManager:CreateParticle(ParticleRes.Respawn, PATTACH_WORLDORIGIN, nil)
            ParticleManager:SetParticleControl(particleIndex, 0, hero:GetAbsOrigin())
            ParticleManager:SetParticleControl(particleIndex, 1, hero:GetAbsOrigin())
            ParticleManager:SetParticleControl(particleIndex, 2, hero:GetAbsOrigin())

            if(NotNull(hero)) then
                -- 刷新小技能
                for i = 0, 4 do
                    local ability = hero:GetAbilityByIndex(i)
                    if(ability ~= nil and ability:GetLevel() > 0) then
                        if(ability:IsCooldownReady() == false) then
                            ability:EndCooldown()
                        end
                        if ability.RefreshCharges ~= nil then
                            ability:RefreshCharges()
                        end
                        ability:SetActivated(true)
                    end
                end
                hero:AddNewModifier(hero, nil, "modifier_respawn_protection", { duration = 5 })
            end
        end
    end, delay)
end

function CDOTA_BaseNPC_Hero:GetCanLevelUpAbility(isForLevelUp, includeTalent)
	local hero = self
    if hero == nil or hero:IsNull() == true or hero:GetAbilityCount() == 0 then
        return nil
    end
    local canLevelUpAbilities = {}
    local heroLevel = hero:GetLevel()
    for i = 0, hero:GetAbilityCount() - 1 do
        local ability = hero:GetAbilityByIndex(i)
        if ability ~= nil then
            local nBehaviorFlags = ability:GetBehavior()
            local abilityName = ability:GetName()
            
            if(ability:IsHidden() == false) and
                bitContains(nBehaviorFlags, DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE) == false and
                abilityName ~= "invoker_invoke" and abilityName ~= "ogre_magi_unrefined_fireblast" and abilityName ~= "techies_minefield_sign" then
                local isTalent = string.find(ability:GetName(), "special_bonus_") ~= nil
                if(isForLevelUp) then
                    if(isTalent) then
                        if(includeTalent) then
                            local talent = hero:GetTalent(ability:GetAbilityIndex() + 1)
                            if(talent ~= nil and talent.status == 0 and heroLevel >= talent.reqLvl) then
                                table.insert(canLevelUpAbilities, ability)
                            end
                        end
                    elseif(ability:GetMaxLevel() > ability:GetLevel() and ability:GetHeroLevelRequiredToUpgrade() <= heroLevel and ability:IsStolen() == false) then
                        table.insert(canLevelUpAbilities, ability)
                    end
                else
                    if(isTalent == false) then
                        table.insert(canLevelUpAbilities, ability)
                    end
                end
            end
        end
    end

    return canLevelUpAbilities
end

function CDOTA_BaseNPC_Hero:LearnAllTalents()
	local hero = self
    if hero == nil or hero:IsNull() then
        return
    end

    for i = 0, hero:GetAbilityCount() - 1 do
        local ability = hero:GetAbilityByIndex(i)
        if ability ~= nil then
            local abilityName = ability:GetName()
            if(string.find(abilityName, "special_bonus_") ~= nil) then
                hero:UpgradeAbility(ability)
            end
        end
    end
end

function CDOTA_BaseNPC_Hero:AutoUpgradeAbility(addTalent)
	local hero = self
    local canLevelUpAbilities = hero:GetCanLevelUpAbility(true, addTalent)
    if(canLevelUpAbilities == nil or #canLevelUpAbilities == 0) then
        return
    end
    
    if(#canLevelUpAbilities > 0) then
        local ability = nil
        for i, v in pairs(canLevelUpAbilities) do
            if(v:GetAbilityType() == ABILITY_TYPE_ULTIMATE or string.find(v:GetName(), "special_bonus_")) then
                ability = v
                break
            end
        end
        
        if(ability == nil) then
            for i, v in pairs(canLevelUpAbilities) do
                if(table.contains(KV_PRIORITY_STUDY_ABILITIES, v:GetName())) then
                    ability = v
                    break
                end
            end
        end

        if(ability == nil) then
            ability = canLevelUpAbilities[RandomInt(1, #canLevelUpAbilities)]
        end
        
        if(ability == nil) then
            return
        end
        
        hero:UpgradeAbility(ability)
        
        if(string.find(ability:GetName(), "special_bonus_") ~= nil) then
            local talent = hero:GetTalent(ability:GetAbilityIndex() + 1)
            if(talent ~= nil) then
                talent.status = 1
            end
        end
        
        -- if(bitContains(ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_AUTOCAST)) then
        --     if ability:GetAutoCastState() == false then
        --         ability:ToggleAutoCast()
        --     end
        -- end
    end
end

function CDOTA_BaseNPC_Hero:GetTalentIndexTable()
	local heroName = self:GetUnitName()

    local tIdx = {10, 11, 12, 13, 14, 15, 16, 17}
    local reqLvlDiff = 0
    if(heroName == "npc_dota_hero_morphling") then
        tIdx = {15, 16, 17, 18, 19, 20, 21, 22}
        reqLvlDiff = 5
    end
    if(heroName == "npc_dota_hero_invoker") then
        tIdx = {17, 18, 19, 20, 21, 22, 23, 24}
        reqLvlDiff = 7
    end
    if(heroName == "npc_dota_hero_rubick") then
        tIdx = {12, 13, 14, 15, 16, 17, 18, 19}
        reqLvlDiff = 1
    end
    if(heroName == "npc_dota_hero_keeper_of_the_light") then
        tIdx = {11, 12, 13, 14, 15, 16, 17, 18}
        reqLvlDiff = 1
    end
    return tIdx, reqLvlDiff
end

function CDOTA_BaseNPC_Hero:InitHeroTalent()
	local hero = self
    if(hero ~= nil and hero:IsNull() == false) then
        hero.talent = {}
        local heroName = hero:GetUnitName()
        local tIdx, reqLvlDiff = hero:GetTalentIndexTable()
        if(RollPercentage(50)) then table.insert(hero.talent, {id = tIdx[1], status = 0, reqLvl = 10}) else table.insert(hero.talent, {id = tIdx[2], status = 0, reqLvl = 10}) end
        if(heroName == "npc_dota_hero_pudge") then
            table.insert(hero.talent, {id = tIdx[4], status = 0, reqLvl = 15})
        else
            if(RollPercentage(50)) then table.insert(hero.talent, {id = tIdx[3], status = 0, reqLvl = 15}) else table.insert(hero.talent, {id = tIdx[4], status = 0, reqLvl = 15}) end
        end        
        if(RollPercentage(50)) then table.insert(hero.talent, {id = tIdx[5], status = 0, reqLvl = 20}) else table.insert(hero.talent, {id = tIdx[6], status = 0, reqLvl = 20}) end
        if(heroName == "npc_dota_hero_pudge") then
            table.insert(hero.talent, {id = tIdx[8], status = 0, reqLvl = 25})
        else
            if(RollPercentage(50)) then table.insert(hero.talent, {id = tIdx[7], status = 0, reqLvl = 25}) else table.insert(hero.talent, {id = tIdx[8], status = 0, reqLvl = 25}) end
        end
    end
end

function CDOTA_BaseNPC_Hero:GetTalentTable()
	local hero = self
    if(hero ~= nil and hero:IsNull() == false) then
        local heroLevel = hero:GetLevel()
        if(heroLevel >= 30 or heroLevel < 25) then
            return hero.talent
        end

        local heroName = hero:GetName()
        local tIdx, reqLvlDiff = hero:GetTalentIndexTable()
        local talentTable = {}
        for i = 0, hero:GetAbilityCount() - 1 do
            local ability = hero:GetAbilityByIndex(i)
            if ability ~= nil and ability:GetLevel() > 0 then
                local abilityName = ability:GetName()
                if(string.find(ability:GetName(), "special_bonus_") ~= nil) then
                    for _, id in pairs(tIdx) do
                        if(id == ability:GetAbilityIndex() + 1) then
                            local reqLvl = 10
                            if(id >= 12 + reqLvlDiff) then
                                reqLvl = 15
                            end

                            if(id >= 14 + reqLvlDiff) then
                                reqLvl = 20
                            end

                            if(id >= 16 + reqLvlDiff) then
                                reqLvl = 25
                            end
                            table.insert(talentTable, {id = id, status = 0, reqLvl = reqLvl})
                            break
                        end
                    end
                end
            end
        end

        return talentTable
    end

    return nil
end

function CDOTA_BaseNPC_Hero:GetTalent(abilityIndex)
	local hero = self
    if(hero == nil or hero:IsNull() or hero.talent == nil) then
        return nil
    end
    
    for _, v in pairs(hero.talent) do
        if(v.id == abilityIndex) then
            return v
        end
    end
    
    return nil
end

function CDOTA_BaseNPC_Hero:GetTalentLearnedCount()
	local hero = self
    if(hero == nil or hero:IsNull() or hero.talent == nil) then
        return 0
    end
    
    local count = 0
    
    for _, v in pairs(hero.talent) do
        if(v.status == 1) then
            count = count + 1
        end
    end
    
    return count
end

function CDOTA_BaseNPC_Hero:EndAbilitiesCooldown()
    local hero = self
    if(hero == nil or hero:IsNull()) then
        return
    end
    for i = 0, hero:GetAbilityCount() - 1 do
        local ability = hero:GetAbilityByIndex(i)
        
        if(ability ~= nil and ability:GetLevel() > 0) then
            if(ability:IsCooldownReady() == false) then
                ability:EndCooldown()
            end
            if ability.RefreshCharges ~= nil then
                ability:RefreshCharges()
            end
        end
    end
end

function CDOTA_BaseNPC_Hero:EndItemsCooldown()
    local hero = self
    if(hero == nil or hero:IsNull()) then
        return
    end

    for slotIndex = 0, 16 do
        local item = hero:GetItemInSlot(slotIndex)
        if(item ~= nil and item:IsNull() == false) then
            item:SetItemState(1)
            item:EndCooldown()
        end
    end
end

function CDOTA_BaseNPC_Hero:AddOwnerItemByName(itemName)
    local hero = self
    if(hero == nil or hero:IsNull()) then
        return
    end

    local targetNewItem = CreateItem(itemName, hero, hero)
    if NotNull(targetNewItem) then
        targetNewItem:SetOwner(hero)
        hero:AddItem(targetNewItem)
    end
end

function CDOTA_BaseNPC_Hero:CheckPosition()
    local playerId = self:GetPlayerID()
    local playerInfo = GameRules.XW:GetPlayerInfo(playerId)
    if playerInfo == nil then return end

    local position = self:GetAbsOrigin()
    if self:IsValidPosition(position) == false then
        local newPos = self:GetAdjustPosition(position)
        if(position ~= newPos) then
            FindClearSpaceForUnit(self, newPos, true)
        end
    end
end

function CDOTA_BaseNPC_Hero:IsValidPosition(pos)
    if pos == nil or pos == vec3_invalid then
        return false
    end

    local playerId = self:GetPlayerID()
    local playerInfo = GameRules.XW:GetPlayerInfo(playerId)
    if playerInfo == nil then return true end

    if pos.y == nil or pos.x == nil or pos.y < -1350 or pos.y > 1050 or pos.x > 1050 or pos.x < -1050 then
        return false
    end

    if playerInfo.BattleSide > 0 and pos.y < -128 then
        return false
    end

    if playerInfo.BattleSide < 0 and pos.y > -128 then
        return false
    end

    return true
end

function CDOTA_BaseNPC_Hero:GetAdjustPosition(pos)
    local playerId = self:GetPlayerID()
    local playerInfo = GameRules.XW:GetPlayerInfo(playerId)
    if playerInfo == nil then return pos end

    local newPos = Vector(pos.x, pos.y, pos.z)
    if(pos.x > 1050) then
        newPos.x = 1050
    end

    if(pos.x < -1050) then
        newPos.x = -1050
    end

    if(pos.y > 1050) then
        newPos.y = 1050
    end

    if(pos.y < -1350) then
        newPos.y = -1350
    end

    if(pos.y > 0 and playerInfo.BattleSide < -128) then
        newPos.y = -128
    end

    if(pos.y < 0 and playerInfo.BattleSide > -128) then
        newPos.y = -128
    end

    return newPos
end