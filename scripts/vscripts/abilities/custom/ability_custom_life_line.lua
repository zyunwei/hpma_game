ability_custom_life_line = ability_custom_life_line or class({})

LinkLuaModifier("modifier_ability_custom_life_line", "abilities/custom/ability_custom_life_line", LUA_MODIFIER_MOTION_NONE)

modifier_ability_custom_life_line = class({})

function ability_custom_life_line:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end

	local mainModifierName = "modifier_ability_custom_life_line"

	if caster:HasModifier(mainModifierName) then
		caster:RemoveModifierByName(mainModifierName)
	end

	local modifierParams = {
		attack_speed = self:GetSpecialValueFor("attack_speed"),
		lifesteal_percent = self:GetSpecialValueFor("lifesteal_percent"),
		duration = self:GetSpecialValueFor("duration")
	}

	caster:AddNewModifier(caster, nil, mainModifierName, modifierParams)
end

function modifier_ability_custom_life_line:IsHidden() return false end
function modifier_ability_custom_life_line:IsDebuff() return false end
function modifier_ability_custom_life_line:IsPurgable() return false end
function modifier_ability_custom_life_line:RemoveOnDeath() return true end

function modifier_ability_custom_life_line:GetTexture()
	return "ability_custom_life_line"
end

function modifier_ability_custom_life_line:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
end

function modifier_ability_custom_life_line:OnCreated(params)
	self.attack_speed = 140
    self.lifesteal_percent = 30

	if not IsServer() then return end

    self.attack_speed = params.attack_speed
    self.lifesteal_percent = params.lifesteal_percent
end

function modifier_ability_custom_life_line:GetModifierAttackSpeedBonus_Constant()
    return self.attack_speed
end

function modifier_ability_custom_life_line:GetModifierLifesteal()
    return self.lifesteal_percent
end
