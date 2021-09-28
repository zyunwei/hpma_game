require "libs.utils"

if HPMASummonAI == nil then HPMASummonAI = class({}) end

SUMMON_CMD_LIST = {"ATTACK_TARGET", "USE_ABILITY", "USE_ITEM", "MOVE_TO_POSITION"}
SUMMON_UNIT_FILTER = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS

HPMASummonAI.CONTROL_RADIUS = 2000

HPMASummonAI.PriorityCastNoTargetAbility = {
    "dragon_knight_elder_dragon_form",
    "naga_siren_mirror_image",
    "sven_gods_strength",
    "beastmaster_call_of_the_wild_boar",
    "clinkz_wind_walk",
    "terrorblade_metamorphosis",
    "lone_druid_spirit_bear",
    "lone_druid_true_form",
    "templar_assassin_refraction",
    "nyx_assassin_vendetta",
    "bounty_hunter_wind_walk",
    "ddw_chaos_knight_phantasm",
    "visage_summon_familiars",
    "ember_spirit_flame_guard",
    "phantom_assassin_blur",
    "invoker_forge_spirit",
    "invoker_ghost_walk",
    "mirana_invis",
    "pangolier_gyroshell",
    "spirit_breaker_bulldoze",
    "pangolier_shield_crash",
    "undying_flesh_golem",
    "winter_wyvern_arctic_burn",
    "windrunner_windrun",
    "sniper_take_aim",
    "wisp_spirits",
    "keeper_of_the_light_spirit_form",
}

HPMASummonAI.CastToFarestPointAbility = {
    "antimage_mana_overload",
    "shredder_timber_chain",
    "morphling_waveform",
    "shredder_chakram",
    "shredder_chakram_2",
    "tusk_frozen_sigil",
    "antimage_blink",
    "sandking_burrowstrike",
    "sand_king_boss_burrowstrike",
    "void_spirit_astral_step",
    "beastmaster_wild_axes",
    "templar_assassin_psionic_trap",
    "earth_spirit_stone_caller",
    "dawnbreaker_celestial_hammer",
}

HPMASummonAI.ToggleOnAbility = {
    "medusa_mana_shield",
    "leshrac_pulse_nova",
    "pudge_rot",
    "troll_warlord_berserkers_rage",
    "medusa_split_shot",
}

HPMASummonAI.DontCastItems = {
    "item_moon_shard",
    "item_bfury",
    "item_aegis",
    "item_smoke_of_deceit",
    "item_tome_of_upgrade",
    "item_scroll_of_time",
    "item_assassin_medal",
    "item_shadow_amulet",
    "item_aghanims_shard_new",
    "item_tpscroll",
}

HPMASummonAI.DontCastAbility = {
    "phoenix_sun_ray_stop",
    "phoenix_sun_ray_toggle_move",
    "invoker_quas",
    "invoker_wex",
    "invoker_exort",
    "spectre_haunt",
    "tiny_toss_tree",
    "puck_ethereal_jaunt",
    "techies_focused_detonate",
    "tusk_ice_shards_stop",
    "morphling_morph_agi",
    "morphling_morph_str",
    "lone_druid_true_form_druid",
    "phoenix_icarus_dive_stop",
    "abyssal_underlord_cancel_dark_rift",
    "skeleton_king_vampiric_aura",
    "pangolier_gyroshell_stop",
    "templar_assassin_trap",
    "keeper_of_the_light_illuminate_end",
    "keeper_of_the_light_spirit_form_illuminate_end",
    "naga_siren_song_of_the_siren_cancel",
    "rubick_telekinesis_land",
    "monkey_king_untransform",
    "templar_assassin_self_trap",
    "visage_stone_form_self_cast",
    "monkey_king_primal_spring_early",
    "phantom_lancer_phantom_edge",
    "pudge_eject",
    "life_stealer_consume",
    "wisp_tether_break",
    "hoodwink_sharpshooter_release",
    "morphling_replicate",
    "vengefulspirit_nether_swap",
    "kunkka_x_marks_the_spot",
    "kunkka_return",
}

HPMASummonAI.CheckModifierPointTargetAbility = {
    "doom_bringer_doom",
    "bloodseeker_rupture",
    "oracle_false_promise",
    "dazzle_shallow_grave",
    "slardar_amplify_damage",
    "axe_battle_hunger",
    "bounty_hunter_track",
    "winter_wyvern_cold_embrace",
    "shadow_demon_demonic_purge",
}

HPMASummonAI.CastToNearestPointAbility = {
    "nyx_assassin_impale",
    "lion_impale",
    "zuus_lightning_bolt",
    "lina_light_strike_array",
    "shadow_demon_soul_catcher",
    "clinkz_burning_army",
    "techies_stasis_trap",
    "techies_land_mines",
    "techies_remote_mines",
    "tiny_avalanche",
    "mirana_arrow",
    "monkey_king_primal_spring",
    "meepo_earthbind",
    "faceless_void_time_walk",
    "undying_decay",
    "undying_tombstone",
    "faceless_void_chronosphere",
    "jakiro_dual_breath",
    "lina_dragon_slave",
    "mars_spear",
    "silencer_curse_of_the_silent",
    "phoenix_fire_spirits",
    "pangolier_swashbuckle",
    "furion_sprout",
    "riki_tricks_of_the_trade",
    "snapfire_mortimer_kisses",
    "treant_natures_grasp",
    "leshrac_split_earth",
    "furion_wrath_of_nature",
    "arc_warden_spark_wraith",
    "legion_commander_overwhelming_odds",
    "tusk_ice_shards",
    "mars_gods_rebuke",
    "dragon_knight_breathe_fire",
    "alchemist_acid_spray",
    "snapfire_scatterblast",
    "drow_ranger_wave_of_silence",
    "drow_ranger_multishot",
    "omniknight_pacify",
    "queenofpain_sonic_wave",
    "death_prophet_silence",
    "death_prophet_carrion_swarm",
    "weaver_the_swarm",
    "troll_warlord_whirling_axes_ranged",
    "item_branches",
    "terrorblade_reflection",
    "hoodwink_bushwhack",
    "hoodwink_sharpshooter",
    "dawnbreaker_fire_wreath",
    "hoodwink_decoy",
}

function HPMASummonAI:IsValidPosition(pos)
    if pos == nil or pos == vec3_invalid then
        return false
    end

    if pos.y == nil or pos.x == nil or pos.y < -GameRules.XW.MapSize or pos.y > GameRules.XW.MapSize or pos.x > GameRules.XW.MapSize or pos.x < -GameRules.XW.MapSize then
        return false
    end

    return true
end

function HPMASummonAI:GetAdjustPosition(pos)
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

function HPMASummonAI:IsAlive(target)
    if(target == nil or target.IsNull == nil or target:IsNull()) then
        return false
    end
    
    if(target.IsAlive == nil or target:IsAlive() == false) then
        return false
    end
    
    return true
end

function HPMASummonAI:IsValidTargetToCast(target)
    if(target == nil or target:IsNull()) then
        return false
    end

    if(target.IsIllusion == nil or target:IsIllusion()) then
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

    if(HPMASummonAI:IsValidPosition(target:GetAbsOrigin()) == false) then
        return false
    end

    return true
end

function HPMASummonAI:IsTaunt(hero)
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

function HPMASummonAI:HasTargetTrueSight(hero, target)
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

function HPMASummonAI:OnHeroThink(hero)
    if IsClient() or GameManager.IsGameOver then return nil end

    local highestScoreCommand = 1
    local highestScore = 0
    local highestData = nil
    
    if(hero == nil or hero:IsNull()) then
        return nil
    end

    if not hero.hasAI then
        hero.hasAI = true
    end
    
    if(HPMASummonAI:IsAlive(hero) == false and hero:IsReincarnating() == false) then
        return nil
    end

    if(GameRules:IsGamePaused()) then
        return 0.2
    end

    local heroPosition = hero:GetAbsOrigin()
    if(HPMASummonAI:IsValidPosition(heroPosition) == false) then
        local newPos = HPMASummonAI:GetAdjustPosition(heroPosition)
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

    -- if(hero:GetAbilityPoints() > 0) then
    --     hero:AutoUpgradeAbility(hero, true)
    -- end

    for i, v in pairs(SUMMON_CMD_LIST) do
        local score, cmdData = HPMASummonAI:EvaluateCommand(hero, v)
        if(score > highestScore or (score == highestScore and RollPercentage(50))) then
            highestScore = score
            highestScoreCommand = i
            highestData = cmdData
        end
    end

    hero.LastThinkTime = GameRules:GetGameTime()

    if(highestData ~= nil and highestScore > 0) then
        local delay = HPMASummonAI:ExecuteCommand(hero, SUMMON_CMD_LIST[highestScoreCommand], highestData)
        -- if(hero:GetName() == "npc_dota_hero_pudge") then
        --     if SUMMON_CMD_LIST[highestScoreCommand] == "USE_ABILITY" or SUMMON_CMD_LIST[highestScoreCommand] == "USE_ITEM" then
        --         print(SUMMON_CMD_LIST[highestScoreCommand], highestData.ability:GetName(), delay)
        --     else
        --         print(SUMMON_CMD_LIST[highestScoreCommand], delay)
        --     end
        -- end
        if(delay == nil or delay <= 0) then
            delay = 0.2
        end
        return delay
    else
        return 0.2
    end
end

function HPMASummonAI:IsValidSummonAttackTarget(hero, target)
    local owner = hero:GetOwner()
    if IsNull(owner) == false then
        if (owner:GetAbsOrigin() - target:GetAbsOrigin()):Length2D() > HPMASummonAI.CONTROL_RADIUS then
            return false
        end
    end

    return true
end

function HPMASummonAI:EvaluateCommand(hero, cmdName)
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

        if hero:HasAttackCapability() == false then
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

        local owner = hero:GetOwner()
        if IsNull(owner) == false then
            local ownerAttackTarget = owner:GetAttackTarget()
            if IsNull(ownerAttackTarget) == false then
                return 5, ownerAttackTarget
            end

            -- local toggleAiAbility = owner:FindAbilityByName("ability_xxwar_toggle_ai")
            -- if IsNull(toggleAiAbility) == false then
            --     if toggleAiAbility:GetToggleState() == false then
            --         return 0, nil
            --     end
            -- end

            if (owner:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D() > HPMASummonAI.CONTROL_RADIUS and hero:HasAttackCapability() == false then
                return 0, nil
            end
        end

        local attackTarget = hero:GetAttackTarget()
        if(attackTarget == nil or HPMASummonAI:IsAlive(attackTarget) == false) then
            local closestTarget = HPMASummonAI:ClosestEnemyAll(hero, hero:GetTeamNumber())
            if(closestTarget == nil or HPMASummonAI:IsAlive(closestTarget) == false) then
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

        if(HPMASummonAI:IsTaunt(hero)) then
            return 0, nil
        end

        if(hero:HasModifier("modifier_riki_tricks_of_the_trade_phase") or hero:HasModifier("modifier_snapfire_mortimer_kisses")) then
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

            if canCast and table.contains(HPMASummonAI.DontCastAbility, ability:GetName()) == false then
                table.insert(canCastAbilities, ability)
            end
        end

        if(hero:HasAbility("morphling_morph_agi")) then
            local morph_agi = hero:FindAbilityByName("morphling_morph_agi")
            local morph_str = hero:FindAbilityByName("morphling_morph_str")
            if(morph_agi ~= nil and morph_str ~= nil and morph_agi:GetLevel() > 0 and morph_str:GetLevel() > 0) then
                local currentHealth = hero:GetHealth()
                if(currentHealth > 3000 and hero:GetBaseStrength() > 1) then
                    if(morph_agi:GetToggleState() == false) then
                        morph_agi:ToggleAbility()
                    end
                elseif(currentHealth < 2500 and hero:GetBaseAgility() > 1) then
                    if(morph_str:GetToggleState() == false) then
                        morph_str:ToggleAbility()
                    end
                else
                    if(morph_agi:GetToggleState() == true) then
                        morph_agi:ToggleAbility()
                    elseif(morph_str:GetToggleState() == true) then
                        morph_str:ToggleAbility()
                    end
                end
            end
        end

        if(#canCastAbilities > 0) then
            for _, v in pairs(canCastAbilities) do
                if(v:IsToggle() and v:GetToggleState() == false and table.contains(HPMASummonAI.ToggleOnAbility, v:GetName())) then
                    v:ToggleAbility()
                end
            end
        end

        canCastAbilities = table.shuffle(canCastAbilities) 
        for _, v in pairs(canCastAbilities) do
            local abilityName = v:GetName()
            if(table.contains(HPMASummonAI.PriorityCastNoTargetAbility, abilityName) == false) then
                local spellData = HPMASummonAI:GetSpellData(v)
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

    if(cmdName == "USE_ITEM") then
        if(hero:IsMuted() or hero:IsStunned() or hero:IsFrozen()) then
            return 0, nil
        end

        if(HPMASummonAI:IsTaunt(hero)) then
            return 0, nil
        end

        local canCastItems = {}
        
        for slotIndex = 0, 16 do
            if(slotIndex <= 5 or slotIndex == 15 or slotIndex == 16) then
                local item = hero:GetItemInSlot(slotIndex)
                if(item ~= nil) then
                    local itemName = item:GetName()
                    local canCast = true
                    
                    if(item:IsMuted() or item:IsPassive() or item:IsToggle()) then
                        canCast = false
                    elseif(item:RequiresCharges() and item:GetCurrentCharges() <= 0) then
                        canCast = false
                    elseif(item:IsFullyCastable() == false or item:IsCooldownReady() == false) then
                        canCast = false
                    elseif(item:IsInAbilityPhase()) then
                        canCast = false
                    elseif(table.contains(HPMASummonAI.DontCastItems, itemName)) then
                        canCast = false
                    end

                    if canCast then
                        table.insert(canCastItems, item)
                    end
                end
            end
        end

        canCastItems = table.shuffle(canCastItems) 
        for _, v in pairs(canCastItems) do
            local itemName = v:GetName()

            if(hero:GetHealthPercent() <= 80) then
                if(itemName == "item_black_king_bar" and hero:IsMagicImmune() == false) then
                    return 5, {ability = v, type = "no_target", target = nil}
                end

                if(itemName == "item_minotaur_horn" and hero:IsMagicImmune() == false) then
                    return 5, {ability = v, type = "no_target", target = nil}
                end

                if(itemName == "item_beast_horn" and hero:IsMagicImmune() == false and hero:HasAbility("tinker_rearm") == false) then
                    return 5, {ability = v, type = "no_target", target = nil}
                end

                if(itemName == "item_blade_mail" and hero:HasModifier("modifier_item_blade_mail_reflect") == false) then
                    return 5, {ability = v, type = "no_target", target = nil}
                end
            end

            local spellData = HPMASummonAI:GetSpellData(v)
            if(spellData ~= nil) then
                return 4, spellData    
            end
        end
        
        return 0, nil
    end
    
    if(cmdName == "MOVE_TO_POSITION") then
        if(hero:IsChanneling() or hero:IsStunned() or hero:IsFrozen()) then
            return 0, nil
        end

        if(HPMASummonAI:IsTaunt(hero)) then
            return 0, nil
        end

        if hero:HasAttackCapability() == true then
            return 0, nil
        end

        local owner = hero:GetOwner()
        if IsNull(owner) == false then
            local ownerAttackTarget = owner:GetAttackTarget()
            if HPMASummonAI:IsAlive(ownerAttackTarget) ~= false then
                return 0, nil
            end

            local length = (owner:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D()
            if length > HPMASummonAI.CONTROL_RADIUS then
                if length > 2000 then
                    FindClearSpaceForUnit(hero, owner:GetAbsOrigin() + RandomVector(300), true)
                    return 0, nil
                end

                return 4, owner:GetAbsOrigin() + RandomVector(300)
            else
                if hero:IsAttacking() then
                    return 0, nil
                end

                if(hero:GetName() == "npc_dota_hero_batrider") then
                    if(hero:HasModifier("modifier_batrider_flaming_lasso_self")) then
                        local owner = hero:GetOwner()
                        if IsNull(owner) == false then
                            local vTargetLoc = owner:GetAbsOrigin()
                            if (hero:GetAbsOrigin() - vTargetLoc):Length2D() > 100 then
                                return 4, vTargetLoc
                            end
                        end
                    elseif(hero:HasModifier("modifier_batrider_firefly")) then
                        local enemy = HPMASummonAI:GetFarestEnemyTarget(hero, 800)
                        if(enemy ~= nil) then
                            local vTargetLoc = enemy:GetAbsOrigin()
                            if HPMASummonAI:IsValidPosition(vTargetLoc) and (hero:GetAbsOrigin() - vTargetLoc):Length2D() > 100 then
                                return 4, vTargetLoc
                            end
                        end
                    end
                end

                return 2, owner:GetAbsOrigin() + RandomVector(300)
            end
        end

        return 0, nil
    end
end

function HPMASummonAI:ExecuteCommand(hero, cmdName, cmdData)
    if(hero == nil or hero:IsNull()) then
        return 0.2
    end

    if(cmdName == "ATTACK_TARGET") then
        if(cmdData == nil or cmdData:IsNull()) then
            hero:MoveToPositionAggressive(hero:GetAbsOrigin())
            return 0.2
        end

        if(HPMASummonAI:IsTaunt(hero)) then
            hero:MoveToPositionAggressive(hero:GetAbsOrigin())
            return 0.2
        end

        local heroPos = hero:GetAbsOrigin()
        local targetPosition = cmdData:GetAbsOrigin()
        if(HPMASummonAI:IsValidPosition(targetPosition) == false) then
            targetPosition = hero:GetAbsOrigin()
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
            hero:MoveToTargetToAttack(cmdData)
        end

        local delay = 0.5
        if(hero.GetDisplayAttackSpeed ~= nil and hero:GetDisplayAttackSpeed() > 0) then
            delay = 170 / hero:GetDisplayAttackSpeed()
        end

        return delay
    end
    
    if(cmdName == "USE_ABILITY") then
        if(cmdData == nil) then
            hero:MoveToPositionAggressive(hero:GetAbsOrigin())
            return 0.2
        end
        
        local loopTime = HPMASummonAI:CastSpell(cmdData)
        return loopTime
    end

    if(cmdName == "USE_ITEM") then
        if(cmdData == nil) then
            hero:MoveToPositionAggressive(hero:GetAbsOrigin())
            return 0.2
        end
        
        local loopTime = HPMASummonAI:CastSpell(cmdData)
        return loopTime
    end

    if(cmdName == "MOVE_TO_POSITION") then
        if(HPMASummonAI:IsValidPosition(cmdData) == false) then
            hero:MoveToPositionAggressive(hero:GetAbsOrigin())
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

function HPMASummonAI:CastSpell(spellData)
    local hSpell = spellData.ability
    
    if hSpell == nil then
        return 0.2
    end
    
    local caster = hSpell:GetCaster()
    if(caster == nil or caster:IsNull()) then
        return 0.2
    end
    
    if(HPMASummonAI:IsAlive(caster) == false) then
        return 0.2
    end
    
    local abilityName = hSpell:GetName()
    
    if(spellData.type == "unit_target") then
        return HPMASummonAI:CastSpellUnitTarget(hSpell, spellData.target)
    end
    
    if(spellData.type == "point_target") then
        return HPMASummonAI:CastSpellPointTarget(hSpell, spellData.target)
    end
    
    if(spellData.type == "no_target") then
        return HPMASummonAI:CastSpellNoTarget(hSpell)
    end
    
    if(spellData.type == "tree_target") then
        return HPMASummonAI:CastSpellTreeTarget(hSpell, spellData.target)
    end
    
    return 0.2
end

function HPMASummonAI:HasInvisibleEnemyNearby(hero, range)
    if(range == nil) then
        range = 850
    end
    local enemies = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(),
    hero, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, true)

    local count = 0
    for index = 1, #enemies do
        if(enemies[index]:IsInvisible() == true) then
            count = count + 1
        end
    end

    return count > 0
end

function HPMASummonAI:GetSpellData(hSpell)
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

    if(abilityName == "item_black_king_bar") then
        if(hero:IsMagicImmune()) then
            return nil
        end
    end

    if(abilityName == "item_blade_mail") then
        if(hero:HasModifier("modifier_item_blade_mail_reflect")) then
            return nil
        end
    end

    if(abilityName == "item_satanic") then
        if(hero:HasModifier("modifier_item_satanic_unholy")) then
            return nil
        end

        if(hero:GetHealthPercent() <= 80 and hero:IsAttacking()) then
            return {ability = hSpell, type = "no_target", target = nil}
        end
        return nil
    end

    if(abilityName == "item_mask_of_madness") then
        if(hero:IsAttacking()) then
            return {ability = hSpell, type = "no_target", target = nil}
        end
    end

    if(abilityName == "item_lotus_orb") then
        local hTarget = HPMASummonAI:GetNearestFriendWithoutBuff(hSpell)
        if hTarget ~= nil and HPMASummonAI:IsAlive(hTarget) and hTarget ~= hero then
            return {ability = hSpell, type = "unit_target", target = hTarget}
        end
        return nil
    end

    if(abilityName == "item_sphere") then
        return nil
    end

    if(abilityName == "item_fallen_sky") then
        if(hero:HasModifier("modifier_batrider_flaming_lasso_self") or hero:HasModifier("modifier_nyx_assassin_burrow")) then
            return nil
        end
    end

    if(abilityName == "magnataur_empower" or abilityName == "ogre_magi_bloodlust" or abilityName == "treant_living_armor" or abilityName == "tinker_defense_matrix") then
        local hTarget = HPMASummonAI:GetNearestFriendWithoutBuff(hSpell)
        if(hTarget ~= nil and HPMASummonAI:IsAlive(hTarget)) then
            return {ability = hSpell, type = "unit_target", target = hTarget}
        end

        return nil
    end

    if(abilityName == "witch_doctor_voodoo_restoration") then
        if hSpell:IsToggle() and hSpell:GetToggleState() == false then
            hSpell:ToggleAbility()
        end

        return nil
    end

    if(abilityName == "witch_doctor_death_ward") then
        local castRange = HPMASummonAI:GetSpellRange(hSpell)
        local target = hero:GetNearestEnemyHero(castRange + 400, true)
        if(target ~= nil) then
            local heroPosition = hero:GetAbsOrigin()

            local castVector = (target:GetAbsOrigin() - heroPosition):Normalized()
            local castPos = heroPosition + castVector * castRange

            if HPMASummonAI:IsValidPosition(castPos) then
                return {ability = hSpell, type = "point_target", target = castPos}
            end
        end
        return nil
    end

    if(abilityName == "batrider_flaming_lasso") then
        local castRange = HPMASummonAI:GetSpellRange(hSpell)
        local target = hero:GetNearestEnemyHero(castRange, true)
        if(target ~= nil) then
            return {ability = hSpell, type = "unit_target", target = target}
        end

        target = hero:GetNearestBoss(castRange, true)
        if(target ~= nil) then
            return {ability = hSpell, type = "unit_target", target = target}
        end
        
        return nil
    end

    if(abilityName == "keeper_of_the_light_chakra_magic") then
        local hTarget = HPMASummonAI:GetLowManaFriendlyTarget(hSpell, 101)
        if(hTarget ~= nil and HPMASummonAI:IsAlive(hTarget)) then
            return {ability = hSpell, type = "unit_target", target = hTarget}
        end
        return nil
    end

    if(abilityName == "riki_tricks_of_the_trade") then
        if(hero:HasScepter() == false) then
            nTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
            nBehavior = DOTA_ABILITY_BEHAVIOR_NO_TARGET
        else
            nTargetTeam = DOTA_UNIT_TARGET_TEAM_FRIENDLY
            nBehavior = DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
        end
    end

    if(table.contains(HPMASummonAI.CastToFarestPointAbility, abilityName)) then
        local hTarget = HPMASummonAI:GetFarestEnemyTarget(hero, (HPMASummonAI:GetSpellRange(hSpell)) * 0.8)
        if(hTarget ~= nil and HPMASummonAI:IsAlive(hTarget)) then
            local castLength = (hTarget:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D()
            local castVector = (hTarget:GetAbsOrigin() - hero:GetAbsOrigin()):Normalized()
            local castLocation = hero:GetAbsOrigin() + castVector * castLength * 1.25

            if(HPMASummonAI:IsValidPosition(castLocation)) then
                return {ability = hSpell, type = "point_target", target = castLocation}
            end
        end

        return nil
    end

    if(table.contains(HPMASummonAI.CastToNearestPointAbility, abilityName)) then
        local hTarget = HPMASummonAI:GetClosestEnemyTarget(hero, HPMASummonAI:GetSpellRange(hSpell))
        if(hTarget ~= nil and HPMASummonAI:IsAlive(hTarget)) then
            return {ability = hSpell, type = "point_target", target = hTarget:GetAbsOrigin()}
        end
        
        return nil
    end

    if(abilityName == "spirit_breaker_charge_of_darkness") then 
        local hTarget = HPMASummonAI:FindTargetPlayer(hero:GetTeamNumber())
        if(hTarget ~= nil and HPMASummonAI:IsAlive(hTarget)) then
            return {ability = hSpell, type = "unit_target", target = hTarget}
        end
    end

    if(abilityName == "storm_spirit_ball_lightning") then
        if(hero:HasModifier("modifier_storm_spirit_ball_lightning")) then
            return nil
        end

        local hTarget = HPMASummonAI:GetFarestEnemyTarget(hero, 1200)
        if(hTarget ~= nil and HPMASummonAI:IsAlive(hTarget)) then
            local castLength = (hTarget:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D()
            local castVector = (hTarget:GetAbsOrigin() - hero:GetAbsOrigin()):Normalized()
            local castLocation = hero:GetAbsOrigin() + castVector * (castLength + 320)

            if(HPMASummonAI:IsValidPosition(castLocation)) then
                return {ability = hSpell, type = "point_target", target = castLocation}
            end
        end

        return nil
    end

    if(abilityName == "pudge_meat_hook" or abilityName == "pet_pudge_meat_hook") then
        local hTarget = HPMASummonAI:GetBestTargetInRange(hSpell)
        if(hTarget ~= nil and HPMASummonAI:IsAlive(hTarget)) then
            local friends = FindUnitsInLine(hero:GetTeamNumber(), hero:GetAbsOrigin(), hTarget:GetAbsOrigin(), nil, 150, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, SUMMON_UNIT_FILTER)

            if(#friends > 1) then
                return nil
            else
                return {ability = hSpell, type = "point_target", target = hTarget:GetAbsOrigin()}
            end
        end

        return nil
    end

    if(abilityName == "oracle_false_promise" or abilityName == "winter_wyvern_cold_embrace" or abilityName == "dazzle_shallow_grave") then
        local hTarget = HPMASummonAI:GetBestFriendlyTarget(hSpell, 0.6)
        if(hTarget ~= nil and HPMASummonAI:IsAlive(hTarget) and HPMASummonAI:CheckTargetNoModifier(hSpell, hTarget) == true) then
            return {ability = hSpell, type = "unit_target", target = hTarget}
        end

        return nil
    end

    if(abilityName == "alchemist_unstable_concoction") then
        local hTarget = hero:GetNearestEnemyHero(600, false)
        if hTarget ~= nil then
            return {ability = hSpell, type = "no_target", target = nil}
        end

        return nil
    end

    if(abilityName == "alchemist_unstable_concoction_throw") then
        local castRange = HPMASummonAI:GetSpellRange(hSpell)
        local hTarget = hero:GetNearestEnemyHero(castRange, false)
        if hTarget ~= nil then
            local checkModi = hero:FindModifierByName("modifier_alchemist_unstable_concoction")
            if checkModi ~= nil and checkModi:GetElapsedTime() > 3 then
                return {ability = hSpell, type = "unit_target", target = hTarget}
            end
        end

        return nil
    end

    if(abilityName == "mars_spear") then
        local hTarget = HPMASummonAI:FindEnemyByModifier(hSpell, "modifier_eul_cyclone")
        if(hTarget ~= nil and HPMASummonAI:IsAlive(hTarget)) then
            local cycloneBuff = hTarget:FindModifierByName("modifier_eul_cyclone")
            if NotNull(cycloneBuff) and cycloneBuff:GetRemainingTime()<= 0.25 then
                return {ability = hSpell, type = "point_target", target = hTarget:GetAbsOrigin()}
            end
        end
        return nil
    end

    if(abilityName == "ursa_earthshock") then
        local checkPoint = hero:GetAbsOrigin()
        checkPoint = checkPoint + hero:GetForwardVector() * 250
        if(HPMASummonAI:HasEnemyNearPosition(hero, checkPoint, 300)) then
            return {ability = hSpell, type = "no_target", target = nil}
        end
        return nil
    end

    if(abilityName == "weaver_shukuchi") then
        local heroPos = hero:GetAbsOrigin()
        if(hero:GetHealthPercent() <= 50 or HPMASummonAI:HasEnemyNearby(hero, 550)) then
            return {ability = hSpell, type = "no_target", target = nil}
        end
        return nil
    end

    if(abilityName == "weaver_time_lapse") then
        if(hero:HasScepter()) then
            local hTarget = HPMASummonAI:GetBestFriendlyTarget(hSpell, 0.5)
            if(hTarget ~= nil and HPMASummonAI:IsAlive(hTarget)) then
                return {ability = hSpell, type = "unit_target", target = hTarget}
            end
        else
            if(hero:GetHealthPercent() <= 50) then
                return {ability = hSpell, type = "no_target", target = nil}
            end
        end

        return nil
    end

    if(abilityName == "kunkka_ghostship") then
        local vTargetLoc = HPMASummonAI:GetBestAOEPointTarget(hSpell, DOTA_UNIT_TARGET_TEAM_ENEMY)
        if HPMASummonAI:IsValidPosition(vTargetLoc) then
            return {ability = hSpell, type = "point_target", target = vTargetLoc}
        end

        return nil
    end

    if bitContains(nTargetType, DOTA_UNIT_TARGET_TREE) then
        local treeTarget = HPMASummonAI:FindTreeTarget(hSpell)
        if treeTarget ~= nil then
            return {ability = hSpell, type = "tree_target", target = treeTarget}
        end
    elseif bitContains(nTargetTeam, DOTA_UNIT_TARGET_TEAM_CUSTOM) then
        if bitContains(nTargetFlags, DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO) then
            local hTarget = HPMASummonAI:GetBestCreepTarget(hSpell)
            if hTarget ~= nil and HPMASummonAI:IsAlive(hTarget) then
                return {ability = hSpell, type = "unit_target", target = hTarget}
            end
        else
            local hTarget = HPMASummonAI:GetBestTargetInRange(hSpell)
            if hTarget ~= nil and HPMASummonAI:IsAlive(hTarget) then
                return {ability = hSpell, type = "unit_target", target = hTarget}
            end
        end
    elseif bitContains(nTargetTeam, DOTA_UNIT_TARGET_TEAM_ENEMY) then
        if bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_NO_TARGET) then
            if HPMASummonAI:IsNoTargetSpellCastValid(hSpell, DOTA_UNIT_TARGET_TEAM_ENEMY) then
                return {ability = hSpell, type = "no_target", target = nil}
            end
        elseif bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_DIRECTIONAL) then
            local vTargetLoc = HPMASummonAI:GetBestDirectionalPointTarget(hSpell, DOTA_UNIT_TARGET_TEAM_ENEMY)
            if HPMASummonAI:IsValidPosition(vTargetLoc) then
                return {ability = hSpell, type = "point_target", target = vTargetLoc}
            end
        elseif bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_POINT) then
            local vTargetLoc = HPMASummonAI:GetBestAOEPointTarget(hSpell, DOTA_UNIT_TARGET_TEAM_ENEMY)
            if HPMASummonAI:IsValidPosition(vTargetLoc) then
                return {ability = hSpell, type = "point_target", target = vTargetLoc}
            end
        elseif bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) then
            if bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_AOE) then
                local hTarget = HPMASummonAI:GetBestTargetInRange(hSpell)
                if hTarget ~= nil and HPMASummonAI:IsAlive(hTarget) then
                    return {ability = hSpell, type = "unit_target", target = hTarget}
                end
            else
                if bitContains(nTargetType, DOTA_UNIT_TARGET_HERO) then
                    local hTarget = HPMASummonAI:GetBestTargetInRange(hSpell)
                    if hTarget ~= nil and HPMASummonAI:IsAlive(hTarget) then
                        return {ability = hSpell, type = "unit_target", target = hTarget}
                    end
                else
                    local hTarget = HPMASummonAI:GetBestCreepTarget(hSpell)
                    if hTarget ~= nil and HPMASummonAI:IsAlive(hTarget) then
                        return {ability = hSpell, type = "unit_target", target = hTarget}
                    end
                end
            end
        end
    elseif bitContains(nTargetTeam, DOTA_UNIT_TARGET_TEAM_FRIENDLY) then
        if bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_NO_TARGET) then
            if HPMASummonAI:IsNoTargetSpellCastValid(hSpell, DOTA_UNIT_TARGET_TEAM_FRIENDLY) then
                return {ability = hSpell, type = "no_target", target = nil}
            end
        elseif bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_POINT) then
            local vTargetLoc = HPMASummonAI:GetBestAOEPointTarget(hSpell, DOTA_UNIT_TARGET_TEAM_FRIENDLY)
            if HPMASummonAI:IsValidPosition(vTargetLoc) then
                return {ability = hSpell, type = "point_target", target = vTargetLoc}
            end
        else
            local hTarget = HPMASummonAI:GetBestFriendlyTarget(hSpell, 1.0)
            if hTarget ~= nil and HPMASummonAI:IsAlive(hTarget) then
                return {ability = hSpell, type = "unit_target", target = hTarget}
            end
        end
    else
        if bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_NO_TARGET) then
            if HPMASummonAI:IsNoTargetSpellCastValid(hSpell, DOTA_UNIT_TARGET_TEAM_ENEMY) then
                return {ability = hSpell, type = "no_target", target = nil}
            end
        elseif bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_POINT) then
            local vTargetLoc = HPMASummonAI:GetBestAOEPointTarget(hSpell, DOTA_UNIT_TARGET_TEAM_ENEMY)
            if HPMASummonAI:IsValidPosition(vTargetLoc) then
                return {ability = hSpell, type = "point_target", target = vTargetLoc}
            end
        else
            local hTarget = HPMASummonAI:GetBestTargetInRange(hSpell)
            if hTarget ~= nil and HPMASummonAI:IsAlive(hTarget) then
                return {ability = hSpell, type = "unit_target", target = hTarget}
            end
        end
    end
    
    return nil
end

function HPMASummonAI:ClosestEnemyAll(hero, teamId)
    if(hero == nil or hero:IsNull()) then
        return nil
    end

    local enemies = FindUnitsInRadius(teamId, hero:GetAbsOrigin(), nil, HPMASummonAI.CONTROL_RADIUS, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, true)

    if #enemies == 0 then
        return nil
    end
    
    local firstEnemy = nil
    local heroName = hero:GetName()
    
    for index = 1, #enemies do
        if(enemies[index]:IsInvisible() == false or HPMASummonAI:HasTargetTrueSight(hero, enemies[index])) then
            if(HPMASummonAI:IsValidPosition(enemies[index]:GetAbsOrigin()) and HPMASummonAI:IsAlive(enemies[index]) and enemies[index]:IsInvulnerable() == false and enemies[index]:IsAttackImmune() == false) then
                if(enemies[index]:GetName() ~= "npc_dota_techies_mines") then
                    firstEnemy = enemies[index]
                    break
                end
            end
        end
    end
    
    return firstEnemy
end

function HPMASummonAI:GetSpellRange(hSpell)
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

function HPMASummonAI:GetBestTargetInRange(hSpell, findFarthest)
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
    local radius = HPMASummonAI:GetSpellRange(hSpell)

    local needCheckModifier = table.contains(HPMASummonAI.CheckModifierPointTargetAbility, abilityName)

    local enemies = FindUnitsInRadius(teamId, hero:GetAbsOrigin(), hero, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, SUMMON_UNIT_FILTER, findWay, true)

    if #enemies == 0 then
        return nil
    end
    
    local firstEnemy = nil
    
    for index = 1, #enemies do
        if(enemies[index]:IsInvisible() == false or HPMASummonAI:HasTargetTrueSight(hero, enemies[index])) then
            if(HPMASummonAI:IsAlive(enemies[index]) and HPMASummonAI:IsValidTargetToCast(enemies[index])) then
                if(enemies[index]:IsMagicImmune() == false or castMagicImmuneTarget) then
                    if(needCheckModifier == false or HPMASummonAI:CheckTargetNoModifier(hSpell, enemies[index]) == true) then
                        firstEnemy = enemies[index]
                        break
                    end
                end
            end
        end 
    end
    
    return firstEnemy
end

function HPMASummonAI:CheckTargetNoModifier(hSpell, targetHero)
    if(hSpell == nil or targetHero == nil or targetHero:IsNull()) then
        return false
    end

    local abilityName = hSpell:GetName()
    local modifierName = "modifier_" .. hSpell:GetName()

    if(abilityName == "shadow_demon_demonic_purge") then
        modifierName = "modifier_shadow_demon_purge_slow"
    end

    if(abilityName == "void_spirit_resonant_pulse") then
        modifierName = "modifier_void_spirit_resonant_pulse_physical_buff"
    end

    if(abilityName == "item_solar_crest") then
        modifierName = "modifier_item_solar_crest_armor_addition"
    end

    if(abilityName == "item_sphere") then
        modifierName = "modifier_item_sphere_target"
    end

    if(abilityName == "item_lotus_orb") then
        modifierName = "modifier_item_lotus_orb_active"
    end

    if(abilityName == "item_spirit_vessel") then
       modifierName = "modifier_item_spirit_vessel_heal" 
    end

    if(abilityName == "item_urn_of_shadows") then
        modifierName = "modifier_item_urn_heal"
    end

    if(abilityName == "mirana_invis") then
        modifierName = "modifier_mirana_moonlight_shadow"
    end

    if(abilityName == "lycan_wolf_bite") then
        if(targetHero == hSpell:GetCaster() or targetHero:GetName() == "npc_dota_hero_lycan") then
            return false
        end

        modifierName = "modifier_lycan_wolf_bite_lifesteal"
    end

    if(targetHero:HasModifier(modifierName)) then
        return false
    end

    return true
end

function HPMASummonAI:GetBestFriendlyTarget(hSpell, minHpPercent)
    if(minHpPercent == nil) then
        minHpPercent = 1.0
    end

    local hero = hSpell:GetCaster()
    if(hero == nil or hero:IsNull()) then
        return nil
    end

    local friends = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(), hero,
    HPMASummonAI:GetSpellRange(hSpell), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, hSpell:GetAbilityTargetFlags(), 0, true)
    
    if #friends == 0 then
        return nil
    end
    
    local minHP = nil
    local target = nil
    for _, v in pairs(friends) do
        if(HPMASummonAI:IsAlive(v) and HPMASummonAI:IsValidTargetToCast(v)) then
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

function HPMASummonAI:GetNearestFriendWithoutBuff(hSpell)
    local hero = hSpell:GetCaster()

    local friends = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(), hero,
    HPMASummonAI:GetSpellRange(hSpell), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, hSpell:GetAbilityTargetFlags(), FIND_CLOSEST, true)
    
    if #friends == 0 then
        return nil
    end
    
    local target = nil
    for _, v in pairs(friends) do
        if v ~= hero and HPMASummonAI:IsAlive(v) and HPMASummonAI:IsValidTargetToCast(v) then
            if(HPMASummonAI:CheckTargetNoModifier(hSpell, v) == true) then
                target = v
                break
            end
        end
    end
    
    if(target == nil) then
        if(HPMASummonAI:CheckTargetNoModifier(hSpell, hero) == true) then
            return hero
        else
            return nil
        end
    else
        return target
    end
end

function HPMASummonAI:GetNearestFriendWithBuff(hero, range, modifierName)
    local friends = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(), hero,
        range, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, SUMMON_UNIT_FILTER, FIND_CLOSEST, true)
    
    if #friends == 0 then
        return nil
    end
    
    local target = nil
    for _, v in pairs(friends) do
        if v ~= hero and HPMASummonAI:IsAlive(v) and HPMASummonAI:IsValidTargetToCast(v) then
            if(v:HasModifier(modifierName) == true) then
                target = v
                break
            end
        end
    end
    
    return target
end

function HPMASummonAI:GetBestCreepTarget(hSpell)
    local enemies = FindUnitsInRadius(hSpell:GetCaster():GetTeamNumber(), hSpell:GetCaster():GetAbsOrigin(), hSpell:GetCaster(),
    HPMASummonAI:GetSpellRange(hSpell), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_CREEP, hSpell:GetAbilityTargetFlags(), FIND_CLOSEST, true)
    
    if #enemies == 0 then
        return nil
    end
    
    for _, v in pairs(enemies) do
        if(v:IsInvisible() == false or HPMASummonAI:HasTargetTrueSight(hSpell:GetCaster(), v)) then
            if(HPMASummonAI:IsValidPosition(v:GetAbsOrigin()) and HPMASummonAI:IsAlive(v)) then
                if(hSpell:GetName() ~= "item_hand_of_midas" or v:HasModifier("modifier_ghost_state") == false) then
                    return v
                end
            end
        end
    end
    
    return nil
end

function HPMASummonAI:GetNotImmueCreepTarget(hSpell)
    local enemies = FindUnitsInRadius(hSpell:GetCaster():GetTeamNumber(), hSpell:GetCaster():GetAbsOrigin(), hSpell:GetCaster(),
    HPMASummonAI:GetSpellRange(hSpell), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_CREEP, SUMMON_UNIT_FILTER, FIND_CLOSEST, true)
    
    if #enemies == 0 then
        return nil
    end
    
    for _, v in pairs(enemies) do
        if(v:IsInvisible() == false or HPMASummonAI:HasTargetTrueSight(hSpell:GetCaster(), v)) then
            if(HPMASummonAI:IsAlive(v) and v:IsMagicImmune() == false and v:IsInvulnerable() == false) then
                return v
            end
        end
    end
    
    return nil
end

function HPMASummonAI:GetSpellCastTime(hSpell)
    if(hSpell ~= nil and hSpell:IsNull() == false) then
        local flCastPoint = math.max(0.25, hSpell:GetCastPoint() + 0.25)
        
        return flCastPoint
    end
    return 0.25
end

function HPMASummonAI:FindTreeTarget(hSpell)
    local Trees = GridNav:GetAllTreesAroundPoint(hSpell:GetCaster():GetAbsOrigin(), HPMASummonAI:GetSpellRange(hSpell), false)
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

function HPMASummonAI:CastSpellNoTarget(hSpell)
    local caster = hSpell:GetCaster()
    if(caster == nil or caster:IsNull() or HPMASummonAI:IsAlive(caster) == false) then
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

    return HPMASummonAI:GetSpellCastTime(hSpell)
end

function HPMASummonAI:CastSpellUnitTarget(hSpell, hTarget)
    local caster = hSpell:GetCaster()
    if(caster == nil or caster:IsNull() or HPMASummonAI:IsAlive(caster) == false) then
        return 0.2
    end
    
    if(hTarget == nil or hTarget:IsNull() or HPMASummonAI:IsAlive(hTarget) == false) then
        return 0.2
    end

    if(hSpell == nil or hSpell:IsNull()) then
        return 0.2
    end

    if(HPMASummonAI:IsValidPosition(hTarget:GetAbsOrigin()) == false) then
        return 0.2
    end

    local abilityName = hSpell:GetName()
    if(hSpell.IsItem ~= nil and hSpell:IsItem() == false) then
        caster.LastSpellAbilityName = abilityName
    end

    caster:CastAbilityOnTarget(hTarget, hSpell, -1)
    
    return HPMASummonAI:GetSpellCastTime(hSpell)
end

function HPMASummonAI:CastSpellTreeTarget(hSpell, treeTarget)
    local caster = hSpell:GetCaster()
    if(caster == nil or caster:IsNull() or HPMASummonAI:IsAlive(caster) == false) then
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
    
    return HPMASummonAI:GetSpellCastTime(hSpell)
end

function HPMASummonAI:CastSpellPointTarget(hSpell, vLocation)
    local caster = hSpell:GetCaster()
    if(caster == nil or caster:IsNull() or HPMASummonAI:IsAlive(caster) == false) then
        return 0.2
    end
    
    if(HPMASummonAI:IsValidPosition(vLocation) == false) then
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

    caster:CastAbilityOnPosition(vLocation, hSpell, -1)

    return HPMASummonAI:GetSpellCastTime(hSpell)
end

function HPMASummonAI:IsNoTargetSpellCastValid(hSpell, targetTeamType)
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
    hSpell:GetCaster(), nAbilityRadius, targetTeamType, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, SUMMON_UNIT_FILTER, 0, true)
    
    if #units < nUnitsRequired then
        return false
    end
    
    return true
end

function HPMASummonAI:GetBestAOEPointTarget(hSpell, targetTeamType)
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

    local searchRadius = HPMASummonAI:GetSpellRange(hSpell) + nAbilityRadius

    local ignoreMagicImmune = false

    local vLocation = HPMASummonAI:GetBestAOELocation(hSpell, searchRadius, nUnitsRequired, ignoreMagicImmune, targetTeamType, nil)

    return vLocation
end

function HPMASummonAI:GetBestAOELocation(hSpell, searchRadius, unitsRequired, ignoreMagicImmune, targetTeamType, searchStartPoint)
    local hero = hSpell:GetCaster()
    if(hero == nil or hero:IsNull()) then
        return nil
    end

    local searchFromPoint = hero:GetAbsOrigin()
    if searchStartPoint ~= nil then
        searchFromPoint = searchStartPoint
    end 

    local targets = FindUnitsInRadius(hero:GetTeamNumber(), searchFromPoint, hero,
        searchRadius, targetTeamType, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, SUMMON_UNIT_FILTER, FIND_CLOSEST, true)

    if #targets == 0 then
        return nil
    end
    
    local validTargets = {}

    for _, v in pairs(targets) do
        if(v:IsInvisible() == false or HPMASummonAI:HasTargetTrueSight(hero, v)) then
            if(HPMASummonAI:IsAlive(v) and HPMASummonAI:IsValidTargetToCast(v)) then
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
        if HPMASummonAI:IsValidPosition(point1) then
            local units1 = FindUnitsInRadius(hero:GetTeamNumber(), point1, hero,
            nAbilityRadius, targetTeamType, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, SUMMON_UNIT_FILTER, FIND_CLOSEST, true)

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

function HPMASummonAI:GetBestDirectionalPointTarget(hSpell, targetTeamType)
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
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        targetTeamType,
        hSpell:GetCaster():GetAbsOrigin(),
        HPMASummonAI:GetSpellRange(hSpell),
        nAbilityRadius,
    nUnitsRequired)
    
    if HPMASummonAI:IsValidPosition(vLocation) == false then
        return nil
    end
    
    return vLocation
end

function HPMASummonAI:GetBestLinearTarget(hSpell, width)
    if(hSpell == nil or width == nil) then
        return nil
    end
    local caster = hSpell:GetCaster()
    local nUnitsRequired = 1
    local vLocation = GetTargetLinearLocation(hSpell:GetCaster():GetTeamNumber(),
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        hSpell:GetCaster():GetAbsOrigin(),
        HPMASummonAI:GetSpellRange(hSpell) * 0.75,
        width,
    nUnitsRequired)

    if HPMASummonAI:IsValidPosition(vLocation) == false then
        return nil
    end
    
    return vLocation
end

function HPMASummonAI:GetClosestEnemyTarget(hero, radius)
    if(hero == nil or hero:IsNull()) then
        return nil
    end

    if(radius == nil) then
        radius = 1000
    end

    local enemies = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(), hero,
    radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, SUMMON_UNIT_FILTER, FIND_CLOSEST, true)
    
    if #enemies == 0 then
        return nil
    end
    
    local target = nil
    for _, v in pairs(enemies) do
        if(v:IsInvisible() == false or HPMASummonAI:HasTargetTrueSight(hero, v)) then
            if(HPMASummonAI:IsAlive(v) and HPMASummonAI:IsValidTargetToCast(v)) then
                return v
            end
        end
    end
    
    return nil
end

function HPMASummonAI:GetFarestEnemyTarget(hero, radius)
    if(hero == nil or hero:IsNull()) then
        return nil
    end

    if(radius == nil) then
        radius = 1000
    end

    local enemies = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(), hero,
    radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, SUMMON_UNIT_FILTER, FIND_FARTHEST, true)
    
    if #enemies == 0 then
        return nil
    end
    
    local farestLength = 0
    local target = nil
    for _, v in pairs(enemies) do
        if(v:IsInvisible() == false or HPMASummonAI:HasTargetTrueSight(hero, v)) then
            if(HPMASummonAI:IsAlive(v) and HPMASummonAI:IsValidTargetToCast(v)) then
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

function HPMASummonAI:GetLowManaFriendlyTarget(hSpell, manaPercent)
    if(manaPercent == nil) then
        manaPercent = 100
    end

    local friends = FindUnitsInRadius(hSpell:GetCaster():GetTeamNumber(), hSpell:GetCaster():GetAbsOrigin(), hSpell:GetCaster(),
    HPMASummonAI:GetSpellRange(hSpell), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, UNIT_FILTER, 0, true)
    
    if #friends == 0 then
        return nil
    end
    
    local minMana = nil
    local target = nil
    for _, v in pairs(friends) do
        if(HPMASummonAI:IsAlive(v) and HPMASummonAI:IsValidTargetToCast(v)) then
            local mana = v:GetManaPercent()
            if mana < manaPercent and (minMana == nil or mana < minMana) then
                minMana = mana
                target = v
            end
        end
    end
    
    return target
end

function HPMASummonAI:FindEnemyByModifier(hSpell, modifierName)
    local hero = hSpell:GetCaster()
    if IsNull(hero) then
        return nil
    end
    local teamId = hero:GetTeamNumber()
    local radius = HPMASummonAI:GetSpellRange(hSpell)

    local enemies = FindUnitsInRadius(teamId, hero:GetAbsOrigin(), hero, radius, 
        DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, SUMMON_UNIT_FILTER, FIND_CLOSEST, true)
    if #enemies == 0 then
        return nil
    end
    
    for _, enemy in pairs(enemies) do
        local modifier = enemy:FindModifierByName(modifierName)
        if NotNull(modifier) then return enemy end
    end

    return nil
end

function HPMASummonAI:HasEnemyNearPosition(hero, pos, range)
    if(range == nil) then
        range = 850
    end
    local units = FindUnitsInRadius(hero:GetTeamNumber(), pos,
    hero, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, SUMMON_UNIT_FILTER, 0, true)
    
    local enemyCount = 0
    for _, v in pairs(units) do
        if HPMASummonAI:IsValidTargetToCast(v) then
            enemyCount = enemyCount + 1
        end
    end
    return enemyCount > 0
end

function HPMASummonAI:HasEnemyNearby(hero, range)
    if(range == nil) then
        range = 850
    end

    local units = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(),
    hero, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, SUMMON_UNIT_FILTER, 0, true)

    local enemyCount = 0
    for _, v in pairs(units) do
        if HPMASummonAI:IsValidTargetToCast(v) then
            enemyCount = enemyCount + 1
        end
    end
    return enemyCount > 0
end

function HPMASummonAI:FindTargetPlayer(teamNumber)
    local target = nil 
    for _, playerInfo in pairs(GameRules.XW.PlayerList) do
        local hero = playerInfo.Hero 
        if NotNull(hero) and hero:GetTeamNumber() ~= teamNumber then
            target = hero
            break
        end
    end
    return target
end