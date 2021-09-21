require 'client'
LinkLuaModifier("modifier_hero_base", "modifiers/hero_base_modifier", LUA_MODIFIER_MOTION_NONE)
modifier_hero_base = class({})

local public = modifier_hero_base
local CAST_TYPE_DEF = {
    AUTO_CAST_NO_TARGET = 1,
    AUTO_CAST_UNIT_HERO_FIRST = 2,
    AUTO_CAST_ATTACK_CAST = 3,
    AUTO_CAST_BEING_ATTACKED = 4,
    AUTO_CAST_ALLIES = 5,
    AUTO_CAST_CREEPS = 6
}

function public:IsHidden() return true end
function public:IsDebuff() return false end
function public:IsPurgable() return false end
function public:RemoveOnDeath() return false end

function public:OnCreated()
    --韧性
    self.stack_count = 0
    self.res_duration = 5

    -- 暴击
    self.crit_chance = 0
    self.crit_mult = 150
    self.crit_proc = false

    -- 物理伤害格挡
    self.damage_block = 0

    -- 闪避概率
    self.evasion = 0

    -- 无视闪避概率
    self.pierce_chance = 0
    self.pierce_proc = false

    -- 视野加成
    self.bonus_vision = 0

    -- 生命恢复增强
    self.hp_regen_amplify = 0

    -- 伤害增强
    self.outgoing_damage = 0

    -- 跳跃冷却
    self.jump_cooldown = 0

    -- 最大魔法回复
    self.mana_regen_pct = 0

    if not IsServer() then return end

    if IsNull(self) or self.GetParent == nil then return end
    local parent = self:GetParent()

    self.AttackCastAbilities = {}
    self.BeingAttackCastAbilities = {}

    if IsNull(parent) == false then
        self:StartIntervalThink(0.5)
    end
end

function public:OnIntervalThink()
    if not IsServer() then return end

    if IsNull(self) or self.GetParent == nil then
    	self:StartIntervalThink(-1) -- 结束循环
    	return
    end

    if not GameRules.XW.EnableMinor then
        return
    end

    local parent = self:GetParent()
    if IsNull(parent) then return end
    if parent:IsStunned() or parent:IsFrozen() or parent:IsSilenced() then
        if self.stun_start_time == nil then
            self.stun_start_time = GameManager:GetGameTime()
            self.stun_end_time = nil
        end
        local stunDuariton = math.floor(GameManager:GetGameTime() - self.stun_start_time)
        self.stack_count = math.floor(stunDuariton)
    else
        if self.stun_start_time ~= nil then
            self.stun_end_time = GameManager:GetGameTime()
        end
        self.stun_start_time = nil
        if self.stun_end_time and self.stun_end_time + self.res_duration < GameManager:GetGameTime() then
            self.stack_count = 0
        end
    end

    if IsAlive(parent) == false or parent.GetCustomAttribute == nil then
    	return
    end

    self.damage_block = parent:GetCustomAttribute("damage_block")
    self.evasion = parent:GetCustomAttribute("evasion")
    self.pierce_chance = parent:GetCustomAttribute("pierce_chance")
    self.bonus_vision = parent:GetCustomAttribute("bonus_vision")
    self.crit_mult = parent:GetCustomAttribute("crit_mult")
    self.hp_regen_amplify = parent:GetCustomAttribute("hp_regen_amplify")
    self.outgoing_damage = parent:GetCustomAttribute("outgoing_damage")
    self.jump_cooldown = parent:GetCustomAttribute("jump_cooldown")
    self.mana_regen_pct = parent:GetCustomAttribute("mana_regen_pct")

    if(parent:IsChanneling() or parent:IsStunned() or parent:IsFrozen() or parent:IsSilenced()) then
        return
    end

    local minorAbilities = {}
    for i = 0, 4 do
        local ability = parent:GetAbilityByIndex(i)
        if IsNull(ability) == false and string.find(ability:GetName(), "xxwar_empty_ability_") == nil then
            table.insert(minorAbilities, ability)
        end
    end

    table.clear(self.AttackCastAbilities)
    table.clear(self.BeingAttackCastAbilities)

    minorAbilities = table.shuffle(minorAbilities)
    -- for _, ability in pairs(minorAbilities) do
    -- 	if self:CheckAndCastAbility(parent, ability) then
    --         break
    --     end
    -- end

    for _, ability in pairs(minorAbilities) do
        if NotNull(ability) and ability:IsInAbilityPhase() == false then
            if ability:IsCooldownReady() == false then
                ability:SetActivated(false)
                ability:MinorAbilityUsed(false)
            end
        end
    end

    parent:UpdateMinorAbilityState()
end

function public:CheckAndCastAbility(hero, ability)
	if IsNull(ability) or ability:IsPassive() or ability:IsActivated() == false then
		return false
	end
    
    -- local canCast = ability:IsFullyCastable() and ability:IsCooldownReady() and ability:IsInAbilityPhase() == false
    -- if canCast == false then
    --     return false
    -- end

    -- if ability:CheckCostCrystal() == false then
    --     return false
    -- end

    local cast_type = ability:GetSpecialValueFor("cast_type")

	if cast_type == CAST_TYPE_DEF.AUTO_CAST_NO_TARGET or cast_type == CAST_TYPE_DEF.AUTO_CAST_BEING_ATTACKED then
        -- 直接使用
        local healthPercent = ability:GetSpecialValueFor("trigger_health_percent")
        if healthPercent == nil or healthPercent == 0 then
            healthPercent = 100
        end
        if hero:GetHealthPercent() <= healthPercent then 
            if ability:CostCrystal() then
                hero:CastAbilityImmediately(ability, hero:GetPlayerID())
                ability:MinorAbilityUsed(false)
                return true
            end
        end
    elseif cast_type == CAST_TYPE_DEF.AUTO_CAST_UNIT_HERO_FIRST or cast_type == CAST_TYPE_DEF.AUTO_CAST_ATTACK_CAST then
        -- 英雄在附近时，留给英雄使用，技能要实现CastAbilityTarget(target, params)方法
        local castImmunity = false
        local kvData = ability:GetAbilityKeyValues()
        if kvData and kvData.SpellImmunityType == "SPELL_IMMUNITY_ENEMIES_YES" then
            castImmunity = true
        end

        local healthPercent = ability:GetSpecialValueFor("trigger_health_percent")
        if healthPercent == nil or healthPercent == 0 then
            healthPercent = 100
        end

        local radius = ability:GetCastRange(vec3_invalid, nil)
        if radius < 1500 then
            radius = 1500
        end
        local heroTarget = hero:GetNearestEnemyHero(radius, true)
        if heroTarget ~= nil then
            if healthPercent < 100 then
                heroTarget = hero:GetHealthPercentEnemyHero(radius, castImmunity, healthPercent)
                if heroTarget == nil then
                    return false
                end
            end

            if heroTarget:IsMagicImmune() and castImmunity == false then
                return false
            end

            if ability:CostCrystal() then
                ability:CastAbilityTarget(heroTarget, nil)
                ability:StartCooldownByReduction(ability:GetCooldown(1))
                ability:MinorAbilityUsed(false)
                return true
            end
        else
            local target = hero:GetNearestEnemy(radius, castImmunity, healthPercent)
            if IsAlive(target) and ability:CostCrystal() then
                ability:CastAbilityTarget(target, nil)
                ability:StartCooldownByReduction(ability:GetCooldown(1))
                ability:MinorAbilityUsed(false)
                return true
            end
        end
    elseif cast_type == CAST_TYPE_DEF.AUTO_CAST_ATTACK_CAST then
        -- 对攻击目标使用，技能要实现CastAbilityTarget(target, params)方法
        table.insert(self.AttackCastAbilities, ability:GetEntityIndex())
        return false
    elseif cast_type == CAST_TYPE_DEF.AUTO_CAST_BEING_ATTACKED then
        -- 被攻击时使用
        table.insert(self.BeingAttackCastAbilities, ability:GetEntityIndex())
        return false
    elseif cast_type == CAST_TYPE_DEF.AUTO_CAST_ALLIES then
        -- 对友军使用，技能要实现CastAbilityTarget(target, params)方法
        -- 判断不重复释放时，技能要实现GetTargetModifier()方法
        local radius = ability:GetCastRange(vec3_invalid, nil)
        local target_modifier = nil
        if ability.GetTargetModifier ~= nil then
            target_modifier = ability:GetTargetModifier()
        end
        local heroTarget = hero:GetLowHealthAlliesHero(radius, target_modifier)
        if heroTarget ~= nil and ability:CostCrystal() then
            ability:CastAbilityTarget(heroTarget, nil)
            ability:StartCooldownByReduction(ability:GetCooldown(1))
            ability:MinorAbilityUsed(false)
            return true
        end

        return true
    elseif cast_type == CAST_TYPE_DEF.AUTO_CAST_CREEPS then
        local exceptAncients = false
        local targetType = DOTA_UNIT_TARGET_CREEP
        if ability:GetSpecialValueFor("except_ancients") == 1 then
            exceptAncients = true
        end
        if ability:GetAbilityTargetType() ~= DOTA_UNIT_TARGET_NONE then
            targetType = ability:GetAbilityTargetType()
        end
        local target = nil
        local radius = ability:GetCastRange(vec3_invalid, nil)
        if targetType == DOTA_UNIT_TARGET_TREE then
            target = hero:GetTreeInRadius(radius)
        else
           target = hero:GetCreepInRadius(radius, exceptAncients)
        end

        if NotNull(target) and ability:CostCrystal() then
            ability:CastAbilityTarget(target, nil)
            ability:StartCooldownByReduction(ability:GetCooldown(1))
            ability:MinorAbilityUsed(false)
            return true
        else
            ability:StartCooldownByReduction(ability:GetCooldown(1))
            ability:MinorAbilityUsed()
            return false
        end
	end

    return false
end

function public:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_EXP_RATE_BOOST,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
        MODIFIER_PROPERTY_EVASION_CONSTANT,
        MODIFIER_EVENT_ON_ATTACK_RECORD,
        MODIFIER_PROPERTY_BONUS_DAY_VISION,
        MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
        MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
        MODIFIER_PROPERTY_MANA_REGEN_PERCENTAGE,
        MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
	}
end

function public:GetActivityTranslationModifiers()
    local parent = self:GetParent()
    if parent:GetMoveSpeedModifier(parent:GetBaseMoveSpeed(), false) >= 450 then
        return "high"
    end
end

function public:GetModifierStatusResistanceStacking()
    return self.stack_count * 10
end

function public:GetModifierPercentageManaRegen()
    return self.mana_regen_pct
end

function public:GetModifierPercentageCooldown(keys)
    if not IsServer() then return 0 end
    if NotNull(keys.ability) and keys.ability:GetName() == "ability_xxwar_jump" then
        return self.jump_cooldown
    end
end

function public:GetModifierTotalDamageOutgoing_Percentage()
    return self.outgoing_damage
end

function public:GetModifierHPRegenAmplify_Percentage()
    return self.hp_regen_amplify
end

function public:GetBonusDayVision()
    return self.bonus_vision
end

function public:GetBonusNightVision()
    return self.bonus_vision
end

function public:OnAttackRecord(keys)
    if not IsServer() then return end

    if keys.attacker == self:GetParent() then
        if self.pierce_proc then
            self.pierce_proc = false
        end
    
        if RollPseudoRandomPercentage(self.pierce_chance, 101, keys.attacker) then
            self.pierce_proc = true
        end
    end
end

function public:CheckState()
    local state = {}
    if not IsServer() then return state end

    if self.pierce_proc then
        state = {[MODIFIER_STATE_CANNOT_MISS] = true}
    end

    return state
end

function public:GetModifierPhysical_ConstantBlock()
    return self.damage_block
end

function public:GetModifierEvasion_Constant()
    return self.evasion
end

function public:GetModifierSpellAmplify_Percentage()
    if not IsServer() then return 0 end

    local parent = self:GetParent()
	if parent == nil or parent:IsNull() or parent.GetIntellect == nil then
        return 0
    end
    
    return parent:GetIntellect() * 0.25
end

function public:GetModifierPreAttack_CriticalStrike(keys)
    if not IsServer() then return end
    if IsNull(keys.attacker) or IsNull(self:GetParent()) then return end
    if keys.attacker == self:GetParent() then
        self.crit_proc = false
        if RollPseudoRandomPercentage(self.crit_chance, 103, keys.attacker) then
            -- self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_EVENT, self:GetParent():GetSecondsPerAttack())
            local crit_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/jugg_crit_blur.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())

            ParticleManager:SetParticleControl(crit_pfx, 0, self:GetParent():GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(crit_pfx)

            self.crit_proc = true

            return self.crit_mult
        end
    end
end

function public:OnAttackLanded(keys)
    if not IsServer() then return end

	local parent = self:GetParent()
	local attacker = keys.attacker
	local target = keys.target
	if IsNull(parent) or IsNull(attacker) or IsNull(target) then return end

    -- 攻击时释放
    if attacker == parent then
        if parent.GetCustomAttribute ~= nil then
            -- 分裂攻击
            local cleaveDamage = parent:GetCustomAttribute('cleave')
            if cleaveDamage and cleaveDamage > 0 then
                local attackDamage = parent:GetAttackDamage() * cleaveDamage / 100
                local cleave_particle = "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave_crit_b.vpcf"
                local attackRange = parent:Script_GetAttackRange()
                DoCleaveAttack(attacker, target, nil, attackDamage, attackRange, attackRange + 210, 700, cleave_particle)
            end

            -- 腐蚀护甲
            local corruption = parent:GetCustomAttribute('corruption')
            if corruption and corruption > 0 then
                target:AddNewModifier(attacker, nil, "modifier_corruption", { duration = 7, armor_reduction = corruption})
            end

            -- 暴击
            local crit = parent:GetCustomAttribute('crit_chance')
            if crit and crit > 0 then
                self.crit_chance = crit
            else
                self.crit_chance = 0
            end

            if self.crit_proc == true then
                local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_crit_tgt.vpcf", PATTACH_ABSORIGIN, target)
                ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
                ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin())
                ParticleManager:SetParticleControl(particle, 3, target:GetAbsOrigin())

                ParticleManager:ReleaseParticleIndex(particle)

                self.crit_proc = false
            end

            -- 击晕
            local stun = parent:GetCustomAttribute('stun')
            if stun and stun > 0 and RollPercentage(stun) then
                target:AddNewModifier(attacker, nil, "modifier_stunned", { duration = 1 * (1 - target:GetStatusResistance()) })
            end
        end

        local castAbIndex = table.random(self.AttackCastAbilities)
        local castAb = EntIndexToHScript(castAbIndex or -1)
        if NotNull(castAb) then
            if target:IsMagicImmune() then
                local kvData = castAb:GetAbilityKeyValues()
                if kvData and kvData.SpellImmunityType == "SPELL_IMMUNITY_ENEMIES_NO" then
                    return
                end
            end

            if castAb.CostCrystal ~= nil and castAb:CostCrystal() and castAb.CastAbilityTarget ~= nil then
                castAb:CastAbilityTarget(target, keys)
                castAb:StartCooldownByReduction(castAb:GetCooldown(1))
                castAb:MinorAbilityUsed(false)
                table.remove(self.AttackCastAbilities, castAbIndex)
            end
        end
    end

    -- 被攻击时释放
    if target == parent then
        -- 两英雄战斗时播放音乐
        -- if IsAlive(attacker) and attacker.IsRealHero ~= nil and attacker:IsRealHero() then
        --     local playerInfo = GameRules.XW:GetPlayerInfo(parent:GetPlayerID())
        --     if playerInfo ~= nil and IsAlive(playerInfo.Hero) and playerInfo.LastPlayFightMusicTime + 15 < GameManager:GetGameTime() then
        --         if GameRules.XW:IsDeveloper(parent:GetPlayerID()) == false then
        --             EmitSoundOnLocationForAllies(playerInfo.Hero:GetAbsOrigin(), "XXWAR.XIAODAOHUI", playerInfo.Hero)
        --             playerInfo.LastPlayFightMusicTime = GameManager:GetGameTime()
        --         end
        --     end
        -- end

        -- 攻击反弹
        local attack_return = parent:GetCustomAttribute('attack_return')
        if attack_return and attack_return > 0 then
            local damage = keys.original_damage * attack_return * 0.01
            ApplyDamage({attacker = parent, victim = keys.attacker, damage_type = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_REFLECTION, damage = damage})
        end

        local castAbIndex = table.random(self.BeingAttackCastAbilities)
        local castAb = EntIndexToHScript(castAbIndex or -1)
        if NotNull(castAb) then
            if(parent:IsChanneling() or parent:IsStunned() or parent:IsFrozen() or parent:IsSilenced()) then
                return
            end

            if castAb.CostCrystal ~= nil and castAb:CostCrystal() then
                if castAb:GetSpecialValueFor("attacked_by_hero") == 0 or (attacker.IsRealHero ~= nil and attacker:IsRealHero()) then
                    parent:CastAbilityImmediately(castAb, parent:GetPlayerID())
                    castAb:MinorAbilityUsed(false)
                    table.remove(self.BeingAttackCastAbilities, castAbIndex)
                end
            end
        end
    end
end

function public:OnTakeDamage(keys)
    if not IsServer() then return end
    if IsNull(keys.attacker) or IsAlive(keys.attacker) == false or IsNull(keys.unit) then return end

    local parent = self:GetParent()
    if IsAlive(parent) == false or keys.attacker ~= self:GetParent() then return end

    -- 物理攻击吸血
    if keys.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
        if parent.GetLifesteal ~= nil and parent:GetLifesteal() > 0 then
            local damage = keys.damage
            local lifesteal_particle = "particles/generic_gameplay/generic_lifesteal.vpcf"

            self.lifesteal_pfx = ParticleManager:CreateParticle(lifesteal_particle, PATTACH_ABSORIGIN_FOLLOW, parent)
            ParticleManager:SetParticleControl(self.lifesteal_pfx, 0, parent:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(self.lifesteal_pfx)

            if keys.unit:IsIllusion() and keys.unit.GetPhysicalArmorValue and GetReductionFromArmor then
                damage = keys.original_damage * (1 - GetReductionFromArmor(keys.unit:GetPhysicalArmorValue(false)))
            end

            parent:Heal(damage * parent:GetLifesteal() * 0.01, parent)
            SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, parent, damage * parent:GetLifesteal() * 0.01, nil)
        end
    --技能吸血
    elseif keys.damage_category == DOTA_DAMAGE_CATEGORY_SPELL then
        if parent.GetSpellLifesteal and parent:GetSpellLifesteal() > 0 and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) ~= DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL then
            local damage = keys.damage
			self.lifesteal_pfx = ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
			ParticleManager:SetParticleControl(self.lifesteal_pfx, 0, parent:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(self.lifesteal_pfx)
			
			if keys.unit:IsIllusion() then
				if keys.damage_type == DAMAGE_TYPE_PHYSICAL and keys.unit.GetPhysicalArmorValue and GetReductionFromArmor then
					damage = keys.original_damage * (1 - GetReductionFromArmor(keys.unit:GetPhysicalArmorValue(false)))
				elseif keys.damage_type == DAMAGE_TYPE_MAGICAL and keys.unit.GetMagicalArmorValue then
					damage = keys.original_damage * (1 - GetReductionFromArmor(keys.unit:GetMagicalArmorValue()))
				elseif keys.damage_type == DAMAGE_TYPE_PURE then
					damage = keys.original_damage
				end
			end
			
			keys.attacker:Heal(math.max(damage, 0) * parent:GetSpellLifesteal() * 0.01, parent)
            SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, parent, math.max(damage, 0) * parent:GetSpellLifesteal() * 0.01, nil)
        end
    end
end

function public:GetModifierPercentageExpRateBoost()
    if not IsServer() then return 0 end

    local parent = self:GetParent()
    if IsNull(parent) or parent.GetPlayerID == nil then return end
    local playerId = parent:GetPlayerID()

    local boostRate = #CallHeroPool:GetPlayerPets(playerId) * 40
    return boostRate
end

function public:GetModifierSpellLifesteal()
    if not IsServer() then return 0 end

    local parent = self:GetParent()
    if IsNull(parent) or parent.GetPrimaryAttribute == nil then return 0 end

    if parent:GetPrimaryAttribute() == DOTA_ATTRIBUTE_INTELLECT then
        return 10
    end

    return 0
end

function public:DoSplitAttack(caster, target, ability, count)
    if IsNull(caster) or IsNull(target) then
        return
    end

    local caster_location = caster:GetAbsOrigin()
    local target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
    local target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
    local target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    local attack_target = caster:GetAttackTarget()

    local radius = caster:Script_GetAttackRange()
    local projectile_speed = caster:GetProjectileSpeed()
    local split_shot_projectile = caster:GetRangedProjectileName()

    local split_shot_targets = FindUnitsInRadius(caster:GetTeam(), caster_location, ability, radius, target_team, target_type, target_flags, FIND_CLOSEST, false)

    for _,v in pairs(split_shot_targets) do
        if NotNull(v) and v ~= attack_target and v.GetUnitName then
            local unitName = v:GetName()
            if unitName ~= "npc_dota_techies_mines" then
                local projectile_info = 
                {
                    EffectName = split_shot_projectile,
                    Ability = ability,
                    vSpawnOrigin = caster_location,
                    Target = v,
                    Source = caster,
                    bHasFrontalCone = false,
                    iMoveSpeed = projectile_speed,
                    bReplaceExisting = false,
                    bProvidesVision = false
                }
                ProjectileManager:CreateTrackingProjectile(projectile_info)
                count = count - 1   
            end
        end
        if max_targets == 0 then break end
    end
end