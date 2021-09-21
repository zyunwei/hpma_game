ability_custom_justice_potential = ability_custom_justice_potential or class({})

LinkLuaModifier("modifier_ability_custom_justice_potential_buff", "abilities/custom/ability_custom_justice_potential", LUA_MODIFIER_MOTION_NONE)

function ability_custom_justice_potential:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
    local consume_health_pct = self:GetSpecialValueFor("consume_health_pct")
    local modifierParams = {
        bonus_health_regen_pct = self:GetSpecialValueFor("bonus_health_regen_pct"),
        bonus_movement_speed_pct = self:GetSpecialValueFor("bonus_movement_speed_pct"),
        bonus_damage = self:GetSpecialValueFor("bonus_damage"),
        duration = self:GetSpecialValueFor("duration"),
    }
    local damageTable = {
        victim = caster,
        attacker = caster,
        damage = caster:GetHealth() * consume_health_pct / 100,
        damage_type = DAMAGE_TYPE_PURE,
    }
    ApplyDamage(damageTable)

    caster:EmitSound("Hero_Huskar.Life_Break.Impact")

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_huskar/huskar_life_break.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(particle, 1, caster:GetOrigin())
    ParticleManager:ReleaseParticleIndex(particle)
    caster:AddNewModifier(caster, nil, "modifier_ability_custom_justice_potential_buff", modifierParams)

end

modifier_ability_custom_justice_potential_buff = modifier_ability_custom_justice_potential_buff or class({})

function modifier_ability_custom_justice_potential_buff:IsHidden() return false end
function modifier_ability_custom_justice_potential_buff:IsDebuff() return false end
function modifier_ability_custom_justice_potential_buff:IsPurgable() return false end
function modifier_ability_custom_justice_potential_buff:RemoveOnDeath() return true end

function modifier_ability_custom_justice_potential_buff:GetEffectName()
    return "particles/units/heroes/hero_huskar/huskar_inner_vitality.vpcf"
end

function modifier_ability_custom_justice_potential_buff:GetEffectAttachType()
    return PATTACH_CENTER_FOLLOW
end

function modifier_ability_custom_justice_potential_buff:GetTexture()
    return "ability_custom_justice_potential"
end

function modifier_ability_custom_justice_potential_buff:OnCreated(params)
    self.bonus_health_regen_pct = params.bonus_health_regen_pct or 8
    self.bonus_movement_speed_pct = params.bonus_movement_speed_pct or 30
    self.bonus_damage = params.bonus_damage or 5
end

function modifier_ability_custom_justice_potential_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
end

function modifier_ability_custom_justice_potential_buff:GetModifierMoveSpeedBonus_Percentage()
    return self.bonus_movement_speed_pct
end

function modifier_ability_custom_justice_potential_buff:GetModifierHealthRegenPercentage()
	return self.bonus_health_regen_pct
end

function modifier_ability_custom_justice_potential_buff:GetModifierPreAttack_BonusDamage()
    local parent = self:GetParent()
    if IsNull(parent) then return end
    return (100 - parent:GetHealthPercent()) * self.bonus_damage
end