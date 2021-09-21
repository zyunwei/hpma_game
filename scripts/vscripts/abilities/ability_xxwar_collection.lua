ability_xxwar_collection = ability_xxwar_collection or class({})

function ability_xxwar_collection:CastFilterResultTarget(target)
    return UF_SUCCESS
end

function ability_xxwar_collection:GetCastRange(vLocation, hTarget)
    if IsServer() then
        return 150 - self:GetCaster():GetCastRangeBonus()
    end

    return 0
end

function ability_xxwar_collection:OnAbilityPhaseStart()
    if not IsServer() then return end

    if self:GetCurrentAbilityCharges() == 0 then
        return false
    end
    local target = self:GetCursorTarget()
    if IsNull(target) then return false end

    local caster = self:GetCaster()
    if IsNull(caster) then return false end

    local player = caster:GetPlayerOwner()
    if IsNull(player) then return false end

    self.CollectType = "CollectionUnit"
    local unitName = target:GetUnitName()
    if table.containsKey(COLLECTION_UNIT_NAME, unitName) then
        CustomNetTables:SetTableValue("PlayerCollectionType", tostring(self:GetCaster():GetEntityIndex()), { typename = self.CollectType })
        return true
    end
    if unitName == "npc_supply_present" then
        self.CollectType = "Supply"
        CustomNetTables:SetTableValue("PlayerCollectionType", tostring(self:GetCaster():GetEntityIndex()), { typename = self.CollectType })
        return true
    end
    if unitName == "npc_treasure_chest" then
        -- local creeps = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),
        --     caster, 300, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, true)

        -- if #creeps > 0 and IsInToolsMode() == false then
        --     caster:ShowCustomMessage({type="bottom", msg="#xxwar_msg_nearby_creeps_treasure", class="error"})
        --     return false
        -- end

        self.CollectType = "Treasure"
        CustomNetTables:SetTableValue("PlayerCollectionType", tostring(self:GetCaster():GetEntityIndex()), { typename = self.CollectType })
        return true
    end
    if unitName == "npc_radar" then
        self.CollectType = "Radar"
        CustomNetTables:SetTableValue("PlayerCollectionType", tostring(self:GetCaster():GetEntityIndex()), { typename = self.CollectType })
        return true
    end

    if unitName == "npc_supply_trap" then
        if target:GetOwner() == caster then
            caster:ShowCustomMessage({type="bottom", msg="#xxwar_msg_owned_trap", class="error"})
            return false
        end
        self.CollectType = "Trap"
        CustomNetTables:SetTableValue("PlayerCollectionType", tostring(self:GetCaster():GetEntityIndex()), { typename = self.CollectType })
        return true
    end

    if target:HasAbility("ability_npc_unit") then
        -- local creeps = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),
        --     caster, 1000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, true)

        -- if #creeps > 0 and IsInToolsMode() == false then
        --     caster:ShowCustomMessage({type="bottom", msg="#xxwar_msg_nearby_creeps_npc", class="error"})
        --     return false
        -- end

        CustomGameEventManager:Send_ServerToPlayer(player, "xxwar_touch_npc", {unit = target:GetEntityIndex()})
        return false
    end

    if target:HasAbility("ability_npc_teleport") then
        local ability = caster:FindAbilityByName("ability_xxwar_teleport")
        if ability then
            if ability:IsCooldownReady() == false then
                caster:ShowCustomMessage({type="bottom", msg="#xxwar_msg_teleport_in_cooldown", class="error"})
            else
                if target.IsSpecialTeleport then
                    local teleportTarget = TELEPORT_POSITION[5]
                    if teleportTarget == nil then return false end
                    local findEntities = Entities:FindAllByClassname("npc_dota_techies_mines")
                    local tptarget = nil
                    for _, v in pairs(findEntities) do
                        if v:GetUnitName() == "npc_teleport" and (v:GetAbsOrigin() - teleportTarget):Length2D() < 500 then
                            tptarget = v
                            break
                        end
                    end

                    if IsNull(tptarget) then return false end

                    tptarget.IsSpecialTeleportTarget = true

                    caster:CastAbilityOnTarget(tptarget, ability, caster:GetPlayerID())
                else
                    CustomGameEventManager:Send_ServerToPlayer(player, "xxwar_touch_teleport", {unit = target:GetEntityIndex()})
                end
            end
        end

        return false
    end

    if target:HasAbility("ability_npc_tombstone") then
        if target.PlayerId == nil then return false end
        local targetPlayerInfo = GameRules.XW.PlayerList[target.PlayerId]
        if targetPlayerInfo == nil then return false end

        if caster:GetTeamNumber() ~= targetPlayerInfo.TeamId then
            caster:ShowCustomMessage({type="bottom", msg="#xxwar_msg_can_not_rescue", class="error"})
            return false
        end

        self.CollectType = "Tombstone"
        CustomNetTables:SetTableValue("PlayerCollectionType", tostring(self:GetCaster():GetEntityIndex()), { typename = self.CollectType })
        return true
    end

    return false
end

function ability_xxwar_collection:GetChannelTime()
    local baseTime = 1

    local collectType = CustomNetTables:GetTableValue("PlayerCollectionType", tostring(self:GetCaster():GetEntityIndex()))
    if collectType ~= nil and collectType["typename"] == "Tombstone" then
        baseTime = 4
    end

    if IsServer() then
        local affixAttr = self:GetCaster():GetCustomAttribute("collection")
        if affixAttr and affixAttr > 0 then
            return baseTime * (1 - affixAttr * 0.01)
        end

        return baseTime
    else
        local statTable = CustomNetTables:GetTableValue("CustomAttributes",  
            "StatisticalAttributes_" .. tostring(self:GetCaster():GetEntityIndex()))

        if statTable ~= nil and statTable["collection"] ~= nil then
            return baseTime * (1 - statTable["collection"] * 0.01)
        end

        return baseTime
    end
end

function ability_xxwar_collection:OnChannelFinish(bInterrupted)
    if not IsServer() then return end

    local caster = self:GetCaster()
    if caster and bInterrupted == false then
        local cursorUnit = self:GetCursorTarget()
        if cursorUnit ~= nil and cursorUnit:IsNull() == false then

            if self.CollectType == "CollectionUnit" then
                EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), SoundRes.OPEN_TREASURE, caster)
                local targetItemName = COLLECTION_UNIT_NAME[cursorUnit:GetUnitName()]
                if targetItemName ~= nil then
                    caster:AddOwnerItemByName(targetItemName)
                end
                cursorUnit:RemoveSelf()

            elseif self.CollectType == "Supply" then
                EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), SoundRes.OPEN_TREASURE, caster)
                local entIndex = cursorUnit:entindex()
                SupplyCtrl:OnOpenSupply(entIndex, caster)
                local modifier = caster:FindModifierByName("modifier_ability_custom_collect_boost_buff")
                local expBounty = RandomInt(50, 100)
                local goldBounty = RandomInt(75, 100)
                if NotNull(modifier) then 
                    expBounty = expBounty + modifier:GetBonusExp()
                    goldBounty = goldBounty + modifier:GetBonusGold()
                end
                caster:AddExperience(expBounty, 0, false, false)
                caster:GiveGold(goldBounty)
                SendOverheadEventMessage(caster:GetPlayerOwner(), OVERHEAD_ALERT_GOLD, caster, goldBounty, nil)

            elseif self.CollectType == "Treasure" then
                EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), SoundRes.OPEN_TREASURE, caster)
                local entIndex = cursorUnit:entindex()
                TreasuresCtrl:OnOpenTreasure(entIndex, caster)
                local modifier = caster:FindModifierByName("modifier_ability_custom_collect_boost_buff")
                local expBounty = RandomInt(75, 125)
                local goldBounty = RandomInt(75, 125)
                if NotNull(modifier) then
                    expBounty = expBounty + modifier:GetBonusExp()
                    goldBounty = goldBounty + modifier:GetBonusGold()
                end
                caster:AddExperience(expBounty, 0, false, false)
                caster:GiveGold(goldBounty)

                --每周任务
                local playerId = caster:GetPlayerID()
                local playerInfo = GameRules.XW:GetPlayerInfo(playerId)
                if playerInfo then
                    playerInfo.TaskTable.open_treasure_count = playerInfo.TaskTable.open_treasure_count + 1
                end

                SendOverheadEventMessage(caster:GetPlayerOwner(), OVERHEAD_ALERT_GOLD, caster, goldBounty, nil)

            elseif self.CollectType == "Radar" then
                EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), SoundRes.OPEN_TREASURE, caster)
                local entIndex = cursorUnit:entindex()
                RadarCtrl:OnTouched(entIndex, caster)

                -- local modifier = caster:FindModifierByName("modifier_ability_custom_collect_boost_buff")
                -- local expBounty = RandomInt(50, 100)
                local goldBounty = RandomInt(50, 100)
                if NotNull(modifier) then 
                    -- expBounty = expBounty + modifier:GetBonusExp()
                    goldBounty = goldBounty + modifier:GetBonusGold()
                end
                -- caster:AddExperience(expBounty, 0, false, false)
                caster:GiveGold(goldBounty)
                SendOverheadEventMessage(caster:GetPlayerOwner(), OVERHEAD_ALERT_GOLD, caster, goldBounty, nil)
                
            elseif self.CollectType == "Tombstone" then
                if cursorUnit.PlayerId ~= nil then
                    local targetPlayerInfo = GameRules.XW.PlayerList[cursorUnit.PlayerId]
                    if targetPlayerInfo ~= nil and targetPlayerInfo.Hero then
                        if IsNull(targetPlayerInfo.Hero) == false and targetPlayerInfo.Hero.Respawn then
                            targetPlayerInfo.LastKillerPlayerId = nil
                            targetPlayerInfo.Hero:Respawn()
                        end
                    end
                end
            elseif self.CollectType == "Trap" then
                EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), SoundRes.OPEN_TREASURE, caster)
                local entIndex = cursorUnit:entindex()
                TrapCtrl:OnOpenTrap(entIndex, caster)
            end
        end
        caster:Stop()
    end
end

function ability_xxwar_collection:GetPlayerID()
    local caster = self:GetCaster()
    if caster == nil then
        return
    end
    if caster.GetPlayerID ~= nil then
        return caster:GetPlayerID()
    end
    local owner = caster:GetOwner()
    if owner == nil or owner:IsNull() then
        return nil
    end
    if owner.GetPlayerID ~= nil then
        return owner:GetPlayerID()
    end
    return nil
end