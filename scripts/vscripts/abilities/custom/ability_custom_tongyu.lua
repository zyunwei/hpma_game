ability_custom_tongyu = ability_custom_tongyu or class({})

function ability_custom_tongyu:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
    local modifierParams = {
        cooldown_reduction = self:GetSpecialValueFor("cooldown_reduction"),
        bonus_duration = self:GetSpecialValueFor("bonus_duration"),
    }

    local affixAttr = self:GetCaster():GetCustomAttribute("pet_cooldown")
    if affixAttr and affixAttr > 0 then
        modifierParams.cooldown_reduction = modifierParams.cooldown_reduction + affixAttr
    end

    caster:AddNewModifier(caster, nil, "modifier_ability_custom_tongyu_buff", modifierParams)
end

LinkLuaModifier("modifier_ability_custom_tongyu_buff", "abilities/custom/ability_custom_tongyu", LUA_MODIFIER_MOTION_NONE)

modifier_ability_custom_tongyu_buff = modifier_ability_custom_tongyu_buff or class({})

function modifier_ability_custom_tongyu_buff:IsHidden() return false end
function modifier_ability_custom_tongyu_buff:IsDebuff() return false end
function modifier_ability_custom_tongyu_buff:IsPurgable() return false end
function modifier_ability_custom_tongyu_buff:RemoveOnDeath() return true end

function modifier_ability_custom_tongyu_buff:GetTexture()
    return "ability_custom_tongyu"
end

function modifier_ability_custom_tongyu_buff:GetEffectName()
    return "particles/units/heroes/hero_lone_druid/lone_druid_rabid_buff_speed_ring.vpcf"
end

function modifier_ability_custom_tongyu_buff:GetEffectAttachType()
    return PATTACH_CENTER_FOLLOW
end

function modifier_ability_custom_tongyu_buff:OnCreated(params)
    self.cooldown_reduction = params.cooldown_reduction or 15
    self.bonus_duration = params.bonus_duration or 5
end

function modifier_ability_custom_tongyu_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_PROPERTY_COOLDOWN_REDUCTION_CONSTANT
    }
end

function modifier_ability_custom_tongyu_buff:GetModifierCooldownReduction_Constant(keys)
    if not IsServer() then return end
    local ability = keys.ability

    if NotNull(ability) and string.find(ability:GetName(), "ability_custom_call_summon")  then
        return self.cooldown_reduction
    end

    return 0
end

function modifier_ability_custom_tongyu_buff:OnTooltip()
    return self.cooldown_reduction
end

function modifier_ability_custom_tongyu_buff:GetBonusDuartion()
    return self.bonus_duration
end