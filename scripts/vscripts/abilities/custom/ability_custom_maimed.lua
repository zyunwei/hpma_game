ability_custom_maimed = ability_custom_maimed or class({})

LinkLuaModifier("modifier_ability_custom_maimed_buff", "abilities/custom/ability_custom_maimed", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_custom_maimed_debuff", "abilities/custom/ability_custom_maimed", LUA_MODIFIER_MOTION_NONE)

function ability_custom_maimed:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
    local modifierParams = {
        radius = self:GetSpecialValueFor("radius"),
        duration = self:GetSpecialValueFor("duration"),
    }
    caster:AddNewModifier(caster, self, "modifier_ability_custom_maimed_buff", modifierParams)
end

modifier_ability_custom_maimed_buff = class({})

function modifier_ability_custom_maimed_buff:IsHidden() return false end
function modifier_ability_custom_maimed_buff:IsDebuff() return false end
function modifier_ability_custom_maimed_buff:IsPurgable() return false end
function modifier_ability_custom_maimed_buff:RemoveOnDeath() return true end

function modifier_ability_custom_maimed_buff:IsAura()
	return true
end

function modifier_ability_custom_maimed_buff:GetModifierAura()
	return "modifier_ability_custom_maimed_debuff"
end

function modifier_ability_custom_maimed_buff:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_ability_custom_maimed_buff:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP
end

function modifier_ability_custom_maimed_buff:GetAuraRadius()
	return self.radius
end

function modifier_ability_custom_maimed_buff:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_ability_custom_maimed_buff:GetTexture()
    return "ability_custom_maimed"
end

function modifier_ability_custom_maimed_buff:GetEffectName()
    return "particles/units/heroes/hero_leshrac/leshrac_scepter_nihilism_caster.vpcf"
end

function modifier_ability_custom_maimed_buff:OnCreated(params)
    if not IsServer() then return end
    self.radius = params.radius or 800
end

modifier_ability_custom_maimed_debuff = class({})

function modifier_ability_custom_maimed_debuff:IsHidden() return false end
function modifier_ability_custom_maimed_debuff:IsDebuff() return false end
function modifier_ability_custom_maimed_debuff:IsPurgable() return false end
function modifier_ability_custom_maimed_debuff:RemoveOnDeath() return true end

function modifier_ability_custom_maimed_debuff:OnCreated()
    self.damage_reduce_pct = 30
    if not IsServer() then return end
    local ability = self:GetAbility()
    if IsNull(ability) then return end
    self.move_speed_slow = ability:GetSpecialValueFor("move_speed_slow") or 40
    self.damage_reduce_pct = ability:GetSpecialValueFor("damage_reduce_pct") or 30
end

function modifier_ability_custom_maimed_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end

function modifier_ability_custom_maimed_debuff:GetTexture()
    return "ability_custom_maimed"
end

function modifier_ability_custom_maimed_debuff:GetEffectName()
    return "particles/econ/items/lifestealer/ls_ti9_immortal/ls_ti9_open_wounds_swoop_parent.vpcf"
end

function modifier_ability_custom_maimed_debuff:GetModifierMoveSpeedBonus_Percentage()
    if IsServer() then
        return -self.move_speed_slow
    end
end

function modifier_ability_custom_maimed_debuff:GetModifierDamageOutgoing_Percentage()
    if IsServer() then
        return -self.damage_reduce_pct
    end
end