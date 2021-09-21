ability_custom_tenacity = ability_custom_tenacity or class({})

function ability_custom_tenacity:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end

	local mainModifierName = "modifier_ability_custom_tenacity"

	if caster:HasModifier(mainModifierName) then
		caster:RemoveModifierByName(mainModifierName)
	end

	local modifierParams = {
		duration = self:GetSpecialValueFor("duration"),
        bonus_armor = self:GetSpecialValueFor("bonus_armor"),
	}

	caster:AddNewModifier(caster, nil, mainModifierName, modifierParams)
end

LinkLuaModifier("modifier_ability_custom_tenacity", "abilities/custom/ability_custom_tenacity", LUA_MODIFIER_MOTION_NONE)

modifier_ability_custom_tenacity = class({})

function modifier_ability_custom_tenacity:IsHidden() return false end
function modifier_ability_custom_tenacity:IsDebuff() return false end
function modifier_ability_custom_tenacity:IsPurgable() return false end
function modifier_ability_custom_tenacity:RemoveOnDeath() return true end

function modifier_ability_custom_tenacity:GetTexture()
	return "ability_custom_tenacity"
end

function modifier_ability_custom_tenacity:GetEffectName()
    return "particles/dev/library/base_ranged_attack_detail.vpcf"
end

function modifier_ability_custom_tenacity:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACKED,
	}
end

function modifier_ability_custom_tenacity:OnCreated(params)
    if not IsServer() then return end
    self.bonus_armor = params.bonus_armor or 0.1
    self:SetStackCount(1)
end

function modifier_ability_custom_tenacity:OnAttacked(keys)
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = keys.target
    if IsNull(parent) or IsNull(target) then return end
    if parent ~= target then return end

    target:ModifyCustomAttribute("armor", "modifier_ability_custom_tenacity", self.bonus_armor)
    self:IncrementStackCount()
end

