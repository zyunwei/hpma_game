ability_custom_shivas_guard = ability_custom_shivas_guard or class({})

LinkLuaModifier("modifier_custom_shivas_guard_debuff", "abilities/custom/ability_custom_shivas_guard", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_custom_frost_armor", "abilities/custom/ability_custom_frost_armor", LUA_MODIFIER_MOTION_HORIZONTAL)

LinkLuaModifier("modifier_custom_frost_armor_slow", "abilities/custom/ability_custom_frost_armor", LUA_MODIFIER_MOTION_HORIZONTAL)

function ability_custom_shivas_guard:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if IsNull(caster)  then return end
    local params = {
        armor_bonus = self:GetSpecialValueFor("armor_bonus"),
        magical_resistance = self:GetSpecialValueFor("magical_resistance"),
        slow_duration = self:GetSpecialValueFor("slow_duration"),
        slow_movement_speed = self:GetSpecialValueFor("slow_movement_speed"),
        slow_attack_speed = self:GetSpecialValueFor("slow_attack_speed"),
		duration = self:GetSpecialValueFor("duration")
    }

    caster:AddNewModifier(caster, nil, "modifier_custom_frost_armor", params)

    EmitSoundOn("Hero_Lich.FrostArmor", caster)

    local ability = self

    local blast_final_radius = ability:GetSpecialValueFor("blast_final_radius")
    local blast_debuff_duration = ability:GetSpecialValueFor("blast_debuff_duration")
    local blast_speed_per_second = ability:GetSpecialValueFor("blast_speed_per_second")

    local blast_vision_radius = ability:GetSpecialValueFor("blast_vision_radius")
    local blast_vision_duration = ability:GetSpecialValueFor("blast_vision_duration")
    local blast_damage = ability:GetSpecialValueFor("blast_damage")

	local blast_movement_speed_debuff = ability:GetSpecialValueFor("blast_movement_speed_debuff")
    local blast_attack_speed_debuff = ability:GetSpecialValueFor("blast_attack_speed_debuff")
	local blast_attack_heal_debuff = ability:GetSpecialValueFor("blast_attack_heal_debuff")

    
 	local shivas_guard_particle = ParticleManager:CreateParticle("particles/items2_fx/shivas_guard_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(shivas_guard_particle, 1, Vector(blast_final_radius, blast_final_radius / blast_speed_per_second, blast_speed_per_second))

    caster:EmitSound("DOTA_Item.ShivasGuard.Activate")

    caster.shivas_guard_current_blast_radius = 0

    local affixAttr = caster:GetCustomAttribute("shivas")
    if affixAttr and affixAttr > 0 then
        blast_damage = blast_damage * (1 + affixAttr * 0.01)
    end

	Timers:CreateTimer({
        endTime = 0.03,
        callback = function()
            if IsNull(ability) or IsNull(caster) then
                return nil
            end

            ability:CreateVisibilityNode(caster:GetAbsOrigin(), blast_vision_radius, blast_vision_duration)
            caster.shivas_guard_current_blast_radius = caster.shivas_guard_current_blast_radius + (blast_speed_per_second * 0.03)
            local nearby_enemy_units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, caster.shivas_guard_current_blast_radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
            	DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES, FIND_ANY_ORDER, false)
            for i, unit in ipairs(nearby_enemy_units) do
                if NotNull(unit) and IsAlive(unit) and not unit:HasModifier("modifier_custom_shivas_guard_debuff") then
                    ApplyDamage({victim = unit, attacker = caster, damage = blast_damage, damage_type = DAMAGE_TYPE_MAGICAL})

                    if IsAlive(unit) then
                        local shivas_guard_impact_particle = ParticleManager:CreateParticle("particles/items2_fx/shivas_guard_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, individual_unit)
                        ParticleManager:SetParticleControl(shivas_guard_impact_particle, 1, unit:GetAbsOrigin())

                        local resistance = unit:GetStatusResistance()
                        local modifierParams = {
                            duration = blast_debuff_duration * (1 - resistance),
                            blast_movement_speed_debuff = blast_movement_speed_debuff,
                            blast_attack_speed_debuff = blast_attack_speed_debuff,
                            blast_attack_heal_debuff = blast_attack_heal_debuff
                        }

                        unit:AddNewModifier(caster, ability, "modifier_custom_shivas_guard_debuff", modifierParams)
                    end
                end
            end

            if caster.shivas_guard_current_blast_radius < blast_final_radius then
                return 0.03
            else
                caster.shivas_guard_current_blast_radius = 0
                return nil
            end
        end
    })
end

modifier_custom_shivas_guard_debuff = class({})

function modifier_custom_shivas_guard_debuff:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
        MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE
    }

    return funcs
end

function modifier_custom_shivas_guard_debuff:IsHidden() return false end
function modifier_custom_shivas_guard_debuff:IsDebuff() return true end
function modifier_custom_shivas_guard_debuff:IsPurgable() return true end
function modifier_custom_shivas_guard_debuff:RemoveOnDeath() return true end
function modifier_custom_shivas_guard_debuff:GetTexture()
    return "ability_custom_shivas_guard"
end

function modifier_custom_shivas_guard_debuff:OnCreated(params)
	self.blast_movement_speed_debuff = 0
    self.blast_attack_speed_debuff = 0
    self.blast_attack_heal_debuff = 0

    if not IsServer() then return end

	self.blast_movement_speed_debuff = params.blast_movement_speed_debuff
	self.blast_attack_speed_debuff = params.blast_attack_speed_debuff
	self.blast_attack_heal_debuff = params.blast_attack_heal_debuff
end

function modifier_custom_shivas_guard_debuff:GetEffectName() 
	return "particles/status_fx/status_effect_frost.vpcf"
end

function modifier_custom_shivas_guard_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_custom_shivas_guard_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.blast_movement_speed_debuff
end

function modifier_custom_shivas_guard_debuff:GetModifierHealAmplify_PercentageTarget()
	return self.blast_attack_heal_debuff
end

function modifier_custom_shivas_guard_debuff:GetModifierAttackSpeedBonus_Constant()
	return self.blast_attack_speed_debuff
end

function modifier_custom_shivas_guard_debuff:GetModifierHPRegenAmplify_Percentage()
	return self.blast_attack_heal_debuff
end
