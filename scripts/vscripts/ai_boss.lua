require "libs.utils"

if BossAI == nil then BossAI = class({}) end

HERO_CMD_LIST = {"ATTACK_TARGET", "USE_ABILITY", "MOVE_TO_POSITION"}
UNIT_FILTER = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS

BossAI.DontCastAbility = {
    "elder_titan_echo_stomp",
    "elder_titan_ancestral_spirit",
    "elder_titan_return_spirit",
}

BossAI.CastToFarestPointAbility = {
    "antimage_mana_overload",
    "shredder_timber_chain",
    "morphling_waveform",
    "shredder_chakram",
    "shredder_chakram_2",
    "tusk_frozen_sigil",
    "antimage_blink",
    "sandking_burrowstrike",
    "void_spirit_astral_step",
    "beastmaster_wild_axes",
    "templar_assassin_psionic_trap",
    "earth_spirit_stone_caller",
    "dawnbreaker_celestial_hammer",
    "boss_timbersaw_timber_chain",
}

function BossAI:IsValidPosition(pos)
    if pos == nil or pos == vec3_invalid then
        return false
    end

    if pos.y == nil or pos.x == nil or pos.y < -GameRules.XW.MapSize or pos.y > GameRules.XW.MapSize or pos.x > GameRules.XW.MapSize or pos.x < -GameRules.XW.MapSize then
        return false
    end

    return true
end

function BossAI:GetAdjustPosition(pos)
    local newPos = Vector(pos.x, pos.y, pos.z)
    if(pos.x > GameRules.XW.MapSize) then
        newPos.x = GameRules.XW.MapSize
    end

    if(pos.x < -GameRules.XW.MapSize) then
        newPos.x = -GameRules.XW.MapSize
    end

    if(pos.y > GameRules.XW.MapSize) then
        newPos.y = GameRules.XW.MapSize
    end

    if(pos.y < -GameRules.XW.MapSize) then
        newPos.y = -GameRules.XW.MapSize
    end
    return newPos
end

function BossAI:IsAlive(target)
    if(target == nil or target.IsNull == nil or target:IsNull()) then
        return false
    end
    
    if(target.IsAlive == nil or target:IsAlive() == false) then
        return false
    end
    
    return true
end

function BossAI:IsValidHeroTargetToCast(target)
    if(target == nil or target:IsNull()) then
        return false
    end

    if(target.IsIllusion == nil or target:IsIllusion()) then
        return false
    end

    if(target.IsRealHero == nil or target:IsRealHero() == false) then
        return false
    end

    if(target.IsOutOfGame == nil or target:IsOutOfGame()) then
        return false
    end

    if(target.HasModifier == nil or target.GetAbsOrigin == nil or target.IsInvulnerable == nil) then
        return false
    end

    if(target:IsInvulnerable()) then
        return false
    end

    if(BossAI:IsValidPosition(target:GetAbsOrigin()) == false) then
        return false
    end

    return true
end

function BossAI:IsTaunt(hero)
    if(hero == nil or hero:IsNull()) then
        return false
    end

    if(hero.HasModifier == nil) then
        return false
    end

    if(hero:HasModifier("modifier_axe_berserkers_call") or hero:HasModifier("modifier_legion_commander_duel")) then
        return true
    end

    if(hero:HasModifier("modifier_winter_wyvern_winters_curse")) then
        return true
    end

    if(hero:HasModifier("modifier_huskar_life_break_taunt")) then
        return true
    end
    
    return false
end

function BossAI:HasTargetTrueSight(hero, target)
    if(hero == nil or hero:IsNull() or target == nil or target:IsNull()) then
        return false
    end

    if(target:HasModifier("modifier_truesight")) then
        local modifiers = target:FindAllModifiersByName("modifier_truesight")
        for i, v in pairs(modifiers) do
            local caster = v:GetCaster()
            if(caster ~= nil and caster:IsNull() == false) then
                if(caster:GetTeamNumber() == hero:GetTeamNumber()) then
                    return true
                end
            end
        end
    end
    return false
end

function BossAI:OnHeroThink(hero)
    if IsClient() or GameManager.IsGameOver then return nil end

    local highestScoreCommand = 1
    local highestScore = 0
    local highestData = nil
    
    if(hero == nil or hero:IsNull()) then
        return nil
    end

    if(string.find(hero:GetUnitName(), "npc_boss_nevermore") == 1 and hero.HasSetSouls == nil) then
        hero.HasSetSouls = true
        local stackModifier = hero:FindModifierByName("modifier_nevermore_necromastery")
        local ability = hero:FindAbilityByName("nevermore_necromastery")
        if(ability ~= nil and ability:GetLevel() > 0) then
            local maxSoulsCount = ability:GetSpecialValueFor("necromastery_max_souls")
            if(maxSoulsCount ~= nil) then
                if(stackModifier ~= nil) then
                    stackModifier:SetStackCount(maxSoulsCount)
                end
            end
        end
    end
    
    if(BossAI:IsAlive(hero) == false and hero:IsReincarnating() == false) then
        return nil
    end

    if(GameRules:IsGamePaused()) then
        return 0.2
    end

    local heroPosition = hero:GetAbsOrigin()
    if(BossAI:IsValidPosition(heroPosition) == false) then
        local newPos = BossAI:GetAdjustPosition(heroPosition)
        if(heroPosition ~= newPos) then
            FindClearSpaceForUnit(hero, newPos, true)
        end
    end

    if hero.IsCommandRestricted ~= nil and hero:IsCommandRestricted() then
        return 0.2
    end

    if(hero.IsOutOfGame ~= nil and hero:IsOutOfGame()) then
        return 0.2
    end

    for i, v in pairs(HERO_CMD_LIST) do
        local score, cmdData = BossAI:EvaluateCommand(hero, v)
        if(score > highestScore or (score == highestScore and RollPercentage(50))) then
            highestScore = score
            highestScoreCommand = i
            highestData = cmdData
        end
    end

    hero.LastThinkTime = GameRules:GetGameTime()

    if(highestData ~= nil and highestScore > 0) then
        local delay = BossAI:ExecuteCommand(hero, HERO_CMD_LIST[highestScoreCommand], highestData)
        -- if(HERO_CMD_LIST[highestScoreCommand] == "USE_ABILITY") then
        --     print(HERO_CMD_LIST[highestScoreCommand], highestData.ability:GetName(), delay)
        -- else
        --     print(HERO_CMD_LIST[highestScoreCommand], delay)
        -- end
        if(delay == nil or delay <= 0) then
            delay = 0.2
        end
        return delay
    else
        return 0.2
    end
end

function BossAI:EvaluateCommand(hero, cmdName)
    if(hero == nil or hero:IsNull()) then
        return 0, nil
    end

    local location = hero:GetAbsOrigin()
    local teamId = hero:GetTeam()
    local score = 0
    
    if(cmdName == "ATTACK_TARGET") then
        if(hero:IsChanneling()) then
            return 0, nil
        end

        if(hero:IsStunned() or hero:IsFrozen()) then
            return 0, nil
        end
        
        if(hero:IsIdle() == false) then
            if(hero:AttackReady() == false or hero:IsAttacking()) then
                return 0, nil
            end
            
            if(hero:GetCurrentActiveAbility() ~= nil) then
                return 0, nil
            end
        end

        local attackTarget = hero:GetAttackTarget()
        
        if(attackTarget == nil or BossAI:IsAlive(attackTarget) == false) then
            local closestTarget = BossAI:GetClosestEnemyHero(hero, FIND_UNITS_EVERYWHERE)
            -- if hero.IsReleaseBoss == true then
            --     closestTarget = BossAI:GetTopPlayerHero(hero, FIND_UNITS_EVERYWHERE)
            -- else
                -- closestTarget = BossAI:GetClosestEnemyHero(hero, FIND_UNITS_EVERYWHERE)
            -- end
            
            if(closestTarget == nil or BossAI:IsAlive(closestTarget) == false) then
                return 0, nil
            end
            
            return 3, closestTarget
        end
        
        return 0, nil
    end
    
    if(cmdName == "USE_ABILITY") then
        if(hero:IsSilenced()) then
            return 0, nil
        end

        if(hero:IsStunned() or hero:IsFrozen()) then
            return 0, nil
        end
        
        if(hero:IsChanneling() and hero:HasModifier("modifier_puck_phase_shift") == false) then
            return 0, nil
        end

        if(BossAI:IsTaunt(hero)) then
            return 0, nil
        end
        
        local canCastAbilities = {}
        
        for i = 0, hero:GetAbilityCount() - 1 do
            local ability = hero:GetAbilityByIndex(i)
            local canCast = true
            
            if(ability == nil or ability:GetLevel() <= 0) then
                canCast = false
            elseif(ability:IsHidden() or ability:IsPassive() or ability:IsActivated() == false) then
                canCast = false
            elseif(string.find(ability:GetName(), "_bonus") ~= nil) then
                canCast = false
            elseif(ability:IsFullyCastable() == false or ability:IsCooldownReady() == false) then
                canCast = false
            elseif(ability:IsInAbilityPhase()) then
                canCast = false
            elseif(bitContains(ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_AUTOCAST)) then
                if ability:GetAutoCastState() == false then
                    ability:ToggleAutoCast()
                end
                
                canCast = false
            end
            
            if(canCast and ability:IsToggle() and ability:GetToggleState() == true) then
                canCast = false
            end

            if(canCast and ability.IsInactiveByPlayer == true) then
                ability:SetActivated(false)
                canCast = false
            end
            
            if canCast and table.contains(BossAI.DontCastAbility, ability:GetName()) == false then
                table.insert(canCastAbilities, ability)
            end
        end

        canCastAbilities = table.shuffle(canCastAbilities) 
        for _, v in pairs(canCastAbilities) do
            local abilityName = v:GetName()
            if(table.contains(PriorityCastNoTargetAbility, abilityName) == false) then
                local spellData = BossAI:GetSpellData(v)
                if(spellData ~= nil) then
                    local score = 4
            
                    if(abilityName == "bounty_hunter_track" and hero:HasModifier("modifier_bounty_hunter_wind_walk")) then
                        score = 6
                    end

                    return score, spellData
                end
            end
        end
        
        return 0, nil
    end
    
    if(cmdName == "MOVE_TO_POSITION") then
        if(hero:IsChanneling() or hero:IsStunned() or hero:IsFrozen()) then
            return 0, nil
        end

        if(BossAI:IsTaunt(hero)) then
            return 0, nil
        end

        return 0, nil
    end
end

function BossAI:ExecuteCommand(hero, cmdName, cmdData)
    if(hero == nil or hero:IsNull()) then
        return 0.2
    end

    if(cmdName == "ATTACK_TARGET") then
        if(cmdData == nil or cmdData:IsNull()) then
            hero:MoveToPositionAggressive(hero.SpawnPosition)
            return 0.2
        end

        if(BossAI:IsTaunt(hero)) then
            hero:MoveToPositionAggressive(hero:GetAbsOrigin())
            return 0.2
        end

        local heroPos = hero:GetAbsOrigin()
        local targetPosition = cmdData:GetAbsOrigin()
        if(BossAI:IsValidPosition(targetPosition) == false) then
            targetPosition = hero.SpawnPosition
        end
        
        if(hero:IsDisarmed() and hero:IsRangedAttacker()) then
            if(hero.releaseMove == nil or hero.releaseMove == false) then
                hero.releaseMove = true
                ExecuteOrderFromTable({
                    UnitIndex = hero:entindex(),
                    OrderType = DOTA_UNIT_ORDER_STOP
                })
            end
            return 0.2
        else
            hero.releaseMove = false
            hero:MoveToPositionAggressive(targetPosition)
        end

        local delay = 0.5
        if(hero.GetDisplayAttackSpeed ~= nil and hero:GetDisplayAttackSpeed() > 0) then
            delay = 170 / hero:GetDisplayAttackSpeed()
        end

        return delay
    end
    
    if(cmdName == "USE_ABILITY") then
        if(cmdData == nil) then
            hero:MoveToPositionAggressive(hero.SpawnPosition)
            return 0.2
        end
        
        local loopTime = BossAI:CastSpell(cmdData)
        return loopTime
    end

    if(cmdName == "MOVE_TO_POSITION") then
        if(BossAI:IsValidPosition(cmdData) == false) then
            hero:MoveToPositionAggressive(hero.SpawnPosition)
            return 0.2
        end
        
        local startPos = hero:GetAbsOrigin()
        local targetPos = cmdData
        
        hero:MoveToPosition(cmdData)
        
        local spendTime = (targetPos - startPos):Length2D() / hero:GetIdealSpeed()
        if(spendTime < 0.1) then spendTime = 0.1 end
        if(spendTime > 2.0) then spendTime = 2.0 end
        
        return spendTime
    end

    return 0.2
end

function BossAI:CastSpell(spellData)
    local hSpell = spellData.ability
    
    if hSpell == nil then
        return 0.2
    end
    
    local caster = hSpell:GetCaster()
    if(caster == nil or caster:IsNull()) then
        return 0.2
    end
    
    if(BossAI:IsAlive(caster) == false) then
        return 0.2
    end
    
    local abilityName = hSpell:GetName()
    
    if(spellData.type == "unit_target") then
        return BossAI:CastSpellUnitTarget(hSpell, spellData.target)
    end
    
    if(spellData.type == "point_target") then
        return BossAI:CastSpellPointTarget(hSpell, spellData.target)
    end
    
    if(spellData.type == "no_target") then
        return BossAI:CastSpellNoTarget(hSpell)
    end
    
    if(spellData.type == "tree_target") then
        return BossAI:CastSpellTreeTarget(hSpell, spellData.target)
    end
    
    return 0.2
end

function BossAI:HasEnemyNearby(hero, range)
    if(range == nil) then
        range = 850
    end

    local units = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(),
    hero, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, UNIT_FILTER, 0, true)

    local realHeroCount = 0
    for _, v in pairs(units) do
        if BossAI:IsValidHeroTargetToCast(v) then
            realHeroCount = realHeroCount + 1
        end
    end
    return realHeroCount > 0
end

function BossAI:HasEnemyNearPosition(hero, pos, range)
    if(range == nil) then
        range = 850
    end
    local units = FindUnitsInRadius(hero:GetTeamNumber(), pos,
    hero, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, UNIT_FILTER, 0, true)
    
    local realHeroCount = 0
    for _, v in pairs(units) do
        if BossAI:IsValidHeroTargetToCast(v) then
            realHeroCount = realHeroCount + 1
        end
    end
    return realHeroCount > 0
end

function BossAI:HasInvisibleEnemyNearby(hero, range)
    if(range == nil) then
        range = 850
    end
    local enemies = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(),
    hero, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS, 0, true)

    local count = 0
    for index = 1, #enemies do
        if(enemies[index]:IsInvisible() == true) then
            count = count + 1
        end
    end

    return count > 0
end

function BossAI:GetNearestUnit(hero, range)
    local units = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(), 
    hero, range, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS, FIND_CLOSEST, true)
    
    if #units == 0 then
        return nil
    end

    local target = nil
    for _, v in pairs(units) do
        if v ~= hero then
            target = v
            break
        end
    end
    
    return target
end

function BossAI:GetSpellData(hSpell)
    if hSpell == nil or hSpell:IsNull() or hSpell:IsActivated() == false then
        return nil
    end
    
    local nBehavior = hSpell:GetBehavior()
    local nTargetTeam = hSpell:GetAbilityTargetTeam()
    local nTargetType = hSpell:GetAbilityTargetType()
    local nTargetFlags = hSpell:GetAbilityTargetFlags()
    local abilityName = hSpell:GetName()
    local hero = hSpell:GetCaster()

    if(hero == nil or hero:IsNull()) then
        return nil
    end

    local isRooted = false
    if(hero.IsRooted ~= nil and hero:IsRooted()) then
        isRooted = true
    end

    if(isRooted) then
        if(bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES)) then
            return nil
        end
    end

    if(abilityName == "nevermore_shadowraze1") then
        local checkPoint = hero:GetAbsOrigin()
        checkPoint = checkPoint + hero:GetForwardVector() * 200
        if(BossAI:HasEnemyNearPosition(hero, checkPoint, 250)) then
            return {ability = hSpell, type = "no_target", target = nil}
        end
        return nil
    end

    if(abilityName == "nevermore_shadowraze2") then
        local checkPoint = hero:GetAbsOrigin()
        checkPoint = checkPoint + hero:GetForwardVector() * 450
        if(BossAI:HasEnemyNearPosition(hero, checkPoint, 250)) then
            return {ability = hSpell, type = "no_target", target = nil}
        end
        return nil
    end

    if(abilityName == "nevermore_shadowraze3") then
        local checkPoint = hero:GetAbsOrigin()
        checkPoint = checkPoint + hero:GetForwardVector() * 700
        if(BossAI:HasEnemyNearPosition(hero, checkPoint, 250)) then
            return {ability = hSpell, type = "no_target", target = nil}
        end
        return nil
    end

    if(table.contains(BossAI.CastToFarestPointAbility, abilityName)) then
        local hTarget = BossAI:GetFarestEnemyTarget(hero, (BossAI:GetSpellRange(hSpell)) * 0.8)
        if(hTarget ~= nil and BossAI:IsAlive(hTarget)) then
            local castLength = (hTarget:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D()
            local castVector = (hTarget:GetAbsOrigin() - hero:GetAbsOrigin()):Normalized()
            local castLocation = hero:GetAbsOrigin() + castVector * castLength * 1.25
            if(BossAI:IsValidPosition(castLocation)) then
                return {ability = hSpell, type = "point_target", target = castLocation}
            end
        end

        return nil
    end

    if bitContains(nTargetType, DOTA_UNIT_TARGET_TREE) then
        local treeTarget = BossAI:FindTreeTarget(hSpell)
        if treeTarget ~= nil then
            return {ability = hSpell, type = "tree_target", target = treeTarget}
        end
    elseif bitContains(nTargetTeam, DOTA_UNIT_TARGET_TEAM_CUSTOM) then
        if bitContains(nTargetFlags, DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO) then
            local hTarget = BossAI:GetBestCreepTarget(hSpell)
            if hTarget ~= nil and BossAI:IsAlive(hTarget) then
                return {ability = hSpell, type = "unit_target", target = hTarget}
            end
        else
            local hTarget = BossAI:GetBestHeroTargetInRange(hSpell)
            if hTarget ~= nil and BossAI:IsAlive(hTarget) then
                return {ability = hSpell, type = "unit_target", target = hTarget}
            end
        end
    elseif bitContains(nTargetTeam, DOTA_UNIT_TARGET_TEAM_ENEMY) then
        if bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_NO_TARGET) then
            if BossAI:IsNoTargetSpellCastValid(hSpell, DOTA_UNIT_TARGET_TEAM_ENEMY) then
                return {ability = hSpell, type = "no_target", target = nil}
            end
        elseif bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_DIRECTIONAL) then
            local vTargetLoc = BossAI:GetBestDirectionalPointTarget(hSpell, DOTA_UNIT_TARGET_TEAM_ENEMY)
            if BossAI:IsValidPosition(vTargetLoc) then
                return {ability = hSpell, type = "point_target", target = vTargetLoc}
            end
        elseif bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_POINT) then
            local vTargetLoc = BossAI:GetBestAOEPointTarget(hSpell, DOTA_UNIT_TARGET_TEAM_ENEMY)
            if BossAI:IsValidPosition(vTargetLoc) then
                return {ability = hSpell, type = "point_target", target = vTargetLoc}
            end
        elseif bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) then
            if bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_AOE) then
                local hTarget = BossAI:GetBestHeroTargetInRange(hSpell)
                if hTarget ~= nil and BossAI:IsAlive(hTarget) then
                    return {ability = hSpell, type = "unit_target", target = hTarget}
                end
            else
                if bitContains(nTargetType, DOTA_UNIT_TARGET_HERO) then
                    local hTarget = BossAI:GetBestHeroTargetInRange(hSpell)
                    if hTarget ~= nil and BossAI:IsAlive(hTarget) then
                        return {ability = hSpell, type = "unit_target", target = hTarget}
                    end
                else
                    local hTarget = BossAI:GetBestCreepTarget(hSpell)
                    if hTarget ~= nil and BossAI:IsAlive(hTarget) then
                        return {ability = hSpell, type = "unit_target", target = hTarget}
                    end
                end
            end
        end
    elseif bitContains(nTargetTeam, DOTA_UNIT_TARGET_TEAM_FRIENDLY) then
        if(BossAI:HasEnemyNearby(hero, 1500) == false) then
            return nil
        end
        if bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_NO_TARGET) then
            if BossAI:IsNoTargetSpellCastValid(hSpell, DOTA_UNIT_TARGET_TEAM_FRIENDLY) then
                return {ability = hSpell, type = "no_target", target = nil}
            end
        elseif bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_POINT) then
            local vTargetLoc = BossAI:GetBestAOEPointTarget(hSpell, DOTA_UNIT_TARGET_TEAM_FRIENDLY)
            if BossAI:IsValidPosition(vTargetLoc) then
                return {ability = hSpell, type = "point_target", target = vTargetLoc}
            end
        else
            local hTarget = BossAI:GetBestFriendlyTarget(hSpell, 0.99)
            if hTarget ~= nil and BossAI:IsAlive(hTarget) then
                return {ability = hSpell, type = "unit_target", target = hTarget}
            end
        end
    else
        if bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_NO_TARGET) then
            if BossAI:IsNoTargetSpellCastValid(hSpell, DOTA_UNIT_TARGET_TEAM_ENEMY) then
                return {ability = hSpell, type = "no_target", target = nil}
            end
        elseif bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_POINT) then
            local vTargetLoc = BossAI:GetBestAOEPointTarget(hSpell, DOTA_UNIT_TARGET_TEAM_ENEMY)
            if BossAI:IsValidPosition(vTargetLoc) then
                return {ability = hSpell, type = "point_target", target = vTargetLoc}
            end
        else
            local hTarget = BossAI:GetBestHeroTargetInRange(hSpell)
            if hTarget ~= nil and BossAI:IsAlive(hTarget) then
                return {ability = hSpell, type = "unit_target", target = hTarget}
            end
        end
    end
    
    return nil
end

function BossAI:ClosestEnemyAll(hero, teamId)
    if(hero == nil or hero:IsNull()) then
        return nil
    end

    local enemies = FindUnitsInRadius(teamId, hero:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, true)

    if #enemies == 0 then
        return nil
    end
    
    local firstEnemy = nil
    local heroName = hero:GetName()
    
    for index = 1, #enemies do
        if(enemies[index]:IsInvisible() == false or BossAI:HasTargetTrueSight(hero, enemies[index])) then
            if(BossAI:IsValidPosition(enemies[index]:GetAbsOrigin()) and BossAI:IsAlive(enemies[index]) and enemies[index]:IsInvulnerable() == false and enemies[index]:IsAttackImmune() == false) then
                if(enemies[index].HasModifier ~= nil and enemies[index]:HasModifier("modifier_monkey_king_tree_dance_hidden") == false) then
                    firstEnemy = enemies[index]
                    break
                end
            end
        end
    end
    
    return firstEnemy
end

function BossAI:GetSpellRange(hSpell)
    if(hSpell == nil) then
        return 250
    end
    
    local baseCastRange = nil

    local ok = pcall(function()
        baseCastRange = hSpell:GetCastRange()
    end)

    if not ok then
        baseCastRange = hSpell:GetCastRange(vec3_invalid, nil)
    end

    if(baseCastRange == nil or baseCastRange < 250) then
        baseCastRange = 250
    end
    
    local caster = hSpell:GetCaster()
    if(caster == nil or caster:IsNull()) then
        return baseCastRange
    end
    
    local abilityName = hSpell:GetName()
    if(caster.GetCastRangeBonus ~= nil) then
        baseCastRange = baseCastRange + caster:GetCastRangeBonus()
    end

    return baseCastRange
end

function BossAI:GetBestHeroTargetInRange(hSpell, findFarthest)
    local findWay = FIND_CLOSEST
    if(findFarthest ~= nil) then
        findWay = FIND_FARTHEST
    end

    local abilityName = hSpell:GetName()
    
    local castMagicImmuneTarget = false
    if (table.contains(KV_SPELL_IMMUNITY_ABILITIES, hSpell:GetName()) == true) then
        castMagicImmuneTarget = true
    end

    local hero = hSpell:GetCaster()

    local teamId = hero:GetTeamNumber()
    local radius = BossAI:GetSpellRange(hSpell)

    local needCheckModifier = table.contains(CheckModifierPointTargetAbility, abilityName)
    
    local enemies = FindUnitsInRadius(teamId, hero:GetAbsOrigin(), hero, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, UNIT_FILTER, findWay, true)
    
    if #enemies == 0 then
        return nil
    end
    
    local firstEnemy = nil
    
    for index = 1, #enemies do
        if(enemies[index]:IsInvisible() == false or BossAI:HasTargetTrueSight(hero, enemies[index])) then
            if(BossAI:IsAlive(enemies[index]) and BossAI:IsValidHeroTargetToCast(enemies[index])) then
                if(enemies[index]:IsMagicImmune() == false or castMagicImmuneTarget) then
                    if(needCheckModifier == false or BossAI:CheckTargetNoModifier(hSpell, enemies[index]) == true) then
                        firstEnemy = enemies[index]
                        break
                    end
                end
            end
        end 
    end
    
    return firstEnemy
end

function BossAI:CheckTargetNoModifier(hSpell, targetHero)
    if(hSpell == nil or targetHero == nil or targetHero:IsNull()) then
        return false
    end

    local abilityName = hSpell:GetName()
    local modifierName = "modifier_" .. hSpell:GetName()

    if(targetHero:HasModifier(modifierName)) then
        return false
    end

    return true
end

function BossAI:GetClosestEnemyHero(hero, radius)
    if(hero == nil or hero:IsNull()) then
        return nil
    end

    if(radius == nil) then
        radius = 1000
    end
    
    local enemies = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(), hero,
    radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, UNIT_FILTER, FIND_CLOSEST, true)
    
    if #enemies == 0 then
        return nil
    end
    
    local target = nil
    for _, v in pairs(enemies) do
        if(v:IsInvisible() == false or BossAI:HasTargetTrueSight(hero, v)) then
            if(BossAI:IsAlive(v) and BossAI:IsValidHeroTargetToCast(v)) then
                target = v
                break
            end
        end
    end
    
    return target
end

function BossAI:GetTopPlayerHero(hero, radius)
    if(hero == nil or hero:IsNull()) then
        return nil
    end

    if(radius == nil) then
        radius = 1000
    end
    
    local enemies = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(), hero,
    radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, UNIT_FILTER, FIND_CLOSEST, true)
    
    if #enemies == 0 then
        return nil
    end
    
    local target = nil
    local maxLevel = 0

    for _, v in pairs(enemies) do
        if(v:IsInvisible() == false or BossAI:HasTargetTrueSight(hero, v)) then
            if BossAI:IsAlive(v) and BossAI:IsValidHeroTargetToCast(v) then
                if v:GetLevel() > maxLevel then
                    maxLevel = v:GetLevel()
                    target = v
                end
            end
        end
    end
    
    return target
end

function BossAI:GetBestFriendlyTarget(hSpell, minHpPercent)
    if(minHpPercent == nil) then
        minHpPercent = 1.0
    end

    local hero = hSpell:GetCaster()
    if(hero == nil or hero:IsNull()) then
        return nil
    end

    local friends = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(), hero,
    BossAI:GetSpellRange(hSpell), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, hSpell:GetAbilityTargetFlags(), 0, true)
    
    if #friends == 0 then
        return nil
    end
    
    local minHP = nil
    local target = nil
    for _, v in pairs(friends) do
        if(BossAI:IsAlive(v) and BossAI:IsValidHeroTargetToCast(v)) then
            local HP = v:GetHealth() / v:GetMaxHealth()
            if(HP <= minHpPercent) then
                if minHP == nil or HP < minHP then
                    minHP = v:GetHealth() / v:GetMaxHealth()
                    target = v
                end
            end
        end
    end
    
    return target
end

function BossAI:GetBestCreepTarget(hSpell)
    local enemies = FindUnitsInRadius(hSpell:GetCaster():GetTeamNumber(), hSpell:GetCaster():GetAbsOrigin(), hSpell:GetCaster(),
    BossAI:GetSpellRange(hSpell), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_CREEP, hSpell:GetAbilityTargetFlags(), FIND_CLOSEST, true)
    
    if #enemies == 0 then
        return nil
    end
    
    for _, v in pairs(enemies) do
        if(v:IsInvisible() == false or BossAI:HasTargetTrueSight(hSpell:GetCaster(), v)) then
            if(BossAI:IsValidPosition(v:GetAbsOrigin()) and BossAI:IsAlive(v)) then
                if(hSpell:GetName() ~= "item_hand_of_midas" or v:HasModifier("modifier_ghost_state") == false) then
                    return v
                end
            end
        end
    end
    
    return nil
end

function BossAI:GetNotImmueCreepTarget(hSpell)
    local enemies = FindUnitsInRadius(hSpell:GetCaster():GetTeamNumber(), hSpell:GetCaster():GetAbsOrigin(), hSpell:GetCaster(),
    BossAI:GetSpellRange(hSpell), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_CREEP, UNIT_FILTER, FIND_CLOSEST, true)
    
    if #enemies == 0 then
        return nil
    end
    
    for _, v in pairs(enemies) do
        if(v:IsInvisible() == false or BossAI:HasTargetTrueSight(hSpell:GetCaster(), v)) then
            if(BossAI:IsAlive(v) and v:IsMagicImmune() == false and v:IsInvulnerable() == false) then
                return v
            end
        end
    end
    
    return nil
end

function BossAI:GetSpellCastTime(hSpell)
    if(hSpell ~= nil and hSpell:IsNull() == false) then
        local flCastPoint = math.max(0.25, hSpell:GetCastPoint() + 0.25)
        
        return flCastPoint
    end
    return 0.25
end

function BossAI:FindTreeTarget(hSpell)
    local Trees = GridNav:GetAllTreesAroundPoint(hSpell:GetCaster():GetAbsOrigin(), BossAI:GetSpellRange(hSpell), false)
    if #Trees == 0 then
        return nil
    end
    
    local nearestTree = nil
    local nearestLength = nil
    
    for i, v in pairs(Trees) do
        if(v ~= nil and v:IsNull() == false) then
            local treeLoc = v:GetAbsOrigin()
            if(treeLoc.y < 3680) then
                local len = (hSpell:GetCaster():GetAbsOrigin() - treeLoc):Length2D()
                if (nearestLength == nil or len < nearestLength) then
                    nearestLength = len
                    nearestTree = v
                end
            end
        end
    end

    return nearestTree
end

function BossAI:CastSpellNoTarget(hSpell)
    local caster = hSpell:GetCaster()
    if(caster == nil or caster:IsNull() or BossAI:IsAlive(caster) == false) then
        return 0.2
    end

    if(hSpell == nil or hSpell:IsNull()) then
        return 0.2
    end

    local abilityName = hSpell:GetName()
    if(hSpell.IsItem ~= nil and hSpell:IsItem() == false) then
        caster.LastSpellAbilityName = abilityName
    end

    caster:CastAbilityNoTarget(hSpell, -1)

    -- local radius = hSpell:GetCastRange() or 0
    -- local channel_time = hSpell:GetChannelTime()
    -- BossAI:PlayRingWarningEffect(caster:GetAbsOrigin(), radius, channel_time)

    return BossAI:GetSpellCastTime(hSpell)
end

function BossAI:CastSpellUnitTarget(hSpell, hTarget)
    local caster = hSpell:GetCaster()
    if(caster == nil or caster:IsNull() or BossAI:IsAlive(caster) == false) then
        return 0.2
    end
    
    if(hTarget == nil or hTarget:IsNull() or BossAI:IsAlive(hTarget) == false) then
        return 0.2
    end

    if(hSpell == nil or hSpell:IsNull()) then
        return 0.2
    end

    if(BossAI:IsValidPosition(hTarget:GetAbsOrigin()) == false) then
        return 0.2
    end

    local abilityName = hSpell:GetName()
    if(hSpell.IsItem ~= nil and hSpell:IsItem() == false) then
        caster.LastSpellAbilityName = abilityName
    end

    caster:CastAbilityOnTarget(hTarget, hSpell, -1)
    
    return BossAI:GetSpellCastTime(hSpell)
end

function BossAI:CastSpellTreeTarget(hSpell, treeTarget)
    local caster = hSpell:GetCaster()
    if(caster == nil or caster:IsNull() or BossAI:IsAlive(caster) == false) then
        return 0.2
    end
    
    if(treeTarget == nil or treeTarget:IsNull()) then
        return 0.2
    end

    if(hSpell == nil or hSpell:IsNull()) then
        return 0.2
    end

    local abilityName = hSpell:GetName()
    if(hSpell.IsItem ~= nil and hSpell:IsItem() == false) then
        caster.LastSpellAbilityName = abilityName
    end
    
    caster:CastAbilityOnTarget(treeTarget, hSpell, -1)
    
    return BossAI:GetSpellCastTime(hSpell)
end

function BossAI:CastSpellPointTarget(hSpell, vLocation)
    local caster = hSpell:GetCaster()
    if(caster == nil or caster:IsNull() or BossAI:IsAlive(caster) == false) then
        return 0.2
    end
    
    if(BossAI:IsValidPosition(vLocation) == false) then
        return 0.2
    end

    if(hSpell == nil or hSpell:IsNull()) then
        return 0.2
    end

    if(vLocation.z > 128) then
        local casterPos = caster:GetAbsOrigin()
        if casterPos.z <= 128 then
            vLocation = Vector(vLocation.x, vLocation.y, casterPos.z)
        else
            vLocation = Vector(vLocation.x, vLocation.y, 128)
        end
    end
    
    local abilityName = hSpell:GetName()
    if(hSpell.IsItem ~= nil and hSpell:IsItem() == false) then
        caster.LastSpellAbilityName = abilityName
    end

    local nBehavior = hSpell:GetBehavior()
    local channel_time = hSpell:GetChannelTime()
    if bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_AOE) then
        local radius = hSpell:GetAOERadius() or 0
        BossAI:PlayRingWarningEffect(caster:GetAbsOrigin(), radius, channel_time)
    end

    caster:CastAbilityOnPosition(vLocation, hSpell, -1)

    return BossAI:GetSpellCastTime(hSpell)
end

function BossAI:IsNoTargetSpellCastValid(hSpell, targetTeamType)
    local nUnitsRequired = 1
    local abilityName = hSpell:GetName()
    local caster = hSpell:GetCaster()

    local nAbilityRadius = 0

    if hSpell.GetAOERadius ~= nil then
        nAbilityRadius = hSpell:GetAOERadius()
    end

    if nAbilityRadius == nil or nAbilityRadius == 0 then
        nAbilityRadius = 1000
    end

    local units = FindUnitsInRadius(hSpell:GetCaster():GetTeamNumber(), hSpell:GetCaster():GetAbsOrigin(),
    hSpell:GetCaster(), nAbilityRadius, targetTeamType, DOTA_UNIT_TARGET_HERO, UNIT_FILTER, 0, true)
    
    if #units < nUnitsRequired then
        return false
    end
    
    return true
end

function BossAI:GetBestAOEPointTarget(hSpell, targetTeamType)
    if(hSpell == nil) then
        return nil
    end
    local caster = hSpell:GetCaster()
    local nUnitsRequired = 1
    local nAbilityRadius = 0

    if hSpell.GetAOERadius ~= nil then
        nAbilityRadius = hSpell:GetAOERadius()
    end
    
    if nAbilityRadius == nil or nAbilityRadius == 0 then
        nAbilityRadius = 250
    end

    local abilityName = hSpell:GetName()
    
    if(nAbilityRadius > 1200) then
        nAbilityRadius = 1200
    end

    local searchRadius = BossAI:GetSpellRange(hSpell) + nAbilityRadius

    local ignoreMagicImmune = false

    local vLocation = BossAI:GetBestAOELocation(hSpell, searchRadius, nUnitsRequired, ignoreMagicImmune, targetTeamType, nil)

    return vLocation
end

function BossAI:GetBestAOELocation(hSpell, searchRadius, unitsRequired, ignoreMagicImmune, targetTeamType, searchStartPoint)
    local hero = hSpell:GetCaster()
    if(hero == nil or hero:IsNull()) then
        return nil
    end

    local searchFromPoint = hero:GetAbsOrigin()
    if searchStartPoint ~= nil then
        searchFromPoint = searchStartPoint
    end 

    local targets = FindUnitsInRadius(hero:GetTeamNumber(), searchFromPoint, hero,
        searchRadius, targetTeamType, DOTA_UNIT_TARGET_HERO, UNIT_FILTER, FIND_CLOSEST, true)

    if #targets == 0 then
        return nil
    end
    
    local validTargets = {}

    for _, v in pairs(targets) do
        if(v:IsInvisible() == false or BossAI:HasTargetTrueSight(hero, v)) then
            if(BossAI:IsAlive(v) and BossAI:IsValidHeroTargetToCast(v)) then
                if(v:IsMagicImmune() == false or ignoreMagicImmune) then
                    table.insert(validTargets, v)
                end
            end
        end
    end

    if #validTargets == 0 then
        return nil
    end

    local nAbilityRadius = 250
    if hSpell.GetAOERadius ~= nil then
        nAbilityRadius = hSpell:GetAOERadius()
    end

    if nAbilityRadius == nil or nAbilityRadius < 250 then
        nAbilityRadius = 250
    end

    local checkPointsGroup = {}
    for _, v1 in pairs(validTargets) do
        for _, v2 in pairs(validTargets) do
            if v1 ~= v2 and (v1:GetAbsOrigin() - v2:GetAbsOrigin()):Length2D() < nAbilityRadius * 2 then
                table.insert(checkPointsGroup, {loc1 = v1:GetAbsOrigin(), loc2 = v2:GetAbsOrigin()})
            end
        end
    end

    local bestPos = nil
    local maxUnits = unitsRequired - 1

    for _, g in pairs(checkPointsGroup) do
        local point1 = Vector((g.loc1.x + g.loc2.x) * 0.5, (g.loc1.y + g.loc2.y) * 0.5)
        if BossAI:IsValidPosition(point1) then
            local units1 = FindUnitsInRadius(hero:GetTeamNumber(), point1, hero,
            nAbilityRadius, targetTeamType, DOTA_UNIT_TARGET_HERO, UNIT_FILTER, FIND_CLOSEST, true)

            if #units1 > maxUnits then
                bestPos = point1
                maxUnits = #units1
            end
        end
    end

    if bestPos == nil and unitsRequired <= 1 and validTargets[1] ~= nil then
        return validTargets[1]:GetAbsOrigin()
    end

    return bestPos
end

function BossAI:GetBestDirectionalPointTarget(hSpell, targetTeamType)
    if(hSpell == nil) then
        return nil
    end
    local caster = hSpell:GetCaster()
    local nUnitsRequired = 1
    local nAbilityRadius = 0

    if hSpell.GetAOERadius ~= nil then
        nAbilityRadius = hSpell:GetAOERadius()
    end
    
    if nAbilityRadius == nil or nAbilityRadius == 0 then
        nAbilityRadius = 250
    end
    
    local vLocation = GetTargetLinearLocation(hSpell:GetCaster():GetTeamNumber(),
        DOTA_UNIT_TARGET_HERO,
        targetTeamType,
        hSpell:GetCaster():GetAbsOrigin(),
        BossAI:GetSpellRange(hSpell),
        nAbilityRadius,
    nUnitsRequired)
    
    if BossAI:IsValidPosition(vLocation) == false then
        return nil
    end
    
    return vLocation
end

function BossAI:GetBestLinearTarget(hSpell, width)
    if(hSpell == nil or width == nil) then
        return nil
    end
    local caster = hSpell:GetCaster()
    local nUnitsRequired = 1
    local vLocation = GetTargetLinearLocation(hSpell:GetCaster():GetTeamNumber(),
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        hSpell:GetCaster():GetAbsOrigin(),
        BossAI:GetSpellRange(hSpell) * 0.75,
        width,
    nUnitsRequired)

    if BossAI:IsValidPosition(vLocation) == false then
        return nil
    end
    
    return vLocation
end

function BossAI:PlayRingWarningEffect(position, radius, time)
    if position == nil or radius == nil then
        return
    end
    if time > 0 and radius > 0 then
        local path = "particles/warning_ring.vpcf"
        local particle_index = ParticleManager:CreateParticle(path, PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(particle_index, 0, position)
        ParticleManager:SetParticleControl(particle_index, 1, Vector(radius, 0,  0))
        Timers:CreateTimer(time, function()
            ParticleManager:DestroyParticle(particle_index, true)
        end)
    end
end

function BossAI:GetFarestEnemyTarget(hero, radius)
    if(hero == nil or hero:IsNull()) then
        return nil
    end

    if(radius == nil) then
        radius = 1000
    end

    local enemies = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(), hero,
    radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, UNIT_FILTER, FIND_FARTHEST, true)
    
    if #enemies == 0 then
        return nil
    end
    
    local farestLength = 0
    local target = nil
    for _, v in pairs(enemies) do
        if(v:IsInvisible() == false or BossAI:HasTargetTrueSight(hero, v)) then
            if(BossAI:IsAlive(v) and BossAI:IsValidHeroTargetToCast(v)) then
                local length = (hero:GetAbsOrigin() - v:GetAbsOrigin()):Length2D()
                if(length > farestLength) then
                    farestLength = length
                    target = v
                end
            end
        end
    end
    
    return target
end