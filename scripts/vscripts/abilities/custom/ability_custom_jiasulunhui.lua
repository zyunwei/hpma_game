ability_custom_jiasulunhui = ability_custom_jiasulunhui or class({})

function ability_custom_jiasulunhui:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
    local modifierParams = {
        cooldown_reduction = self:GetSpecialValueFor("cooldown_reduction"),
    }

    local affixAttr = self:GetCaster():GetCustomAttribute("pet_cooldown")
    if affixAttr and affixAttr > 0 then
        modifierParams.cooldown_reduction = modifierParams.cooldown_reduction + affixAttr
    end

    caster:AddNewModifier(caster, nil, "modifier_ability_custom_jiasulunhui_buff", modifierParams)
end

function ability_custom_jiasulunhui:OnFold()
	local caster = self:GetCaster()
	if IsNull(caster)  then return end

	if caster:HasModifier("modifier_tongyuxinfa") then
		CardGroupSystem:ReplaceCard(caster:GetPlayerID(), "ability_custom_jiasulunhui", "ability_custom_tongyu", true)
	end
end

LinkLuaModifier("modifier_ability_custom_jiasulunhui_buff", "abilities/custom/ability_custom_jiasulunhui", LUA_MODIFIER_MOTION_NONE)

modifier_ability_custom_jiasulunhui_buff = modifier_ability_custom_jiasulunhui_buff or class({})

function modifier_ability_custom_jiasulunhui_buff:IsHidden() return false end
function modifier_ability_custom_jiasulunhui_buff:IsDebuff() return false end
function modifier_ability_custom_jiasulunhui_buff:IsPurgable() return false end
function modifier_ability_custom_jiasulunhui_buff:RemoveOnDeath() return true end

function modifier_ability_custom_jiasulunhui_buff:GetTexture()
    return "ability_custom_jiasulunhui"
end

function modifier_ability_custom_jiasulunhui_buff:GetEffectName()
    return "particles/units/heroes/hero_lone_druid/lone_druid_rabid_buff_speed_ring.vpcf"
end

function modifier_ability_custom_jiasulunhui_buff:GetEffectAttachType()
    return PATTACH_CENTER_FOLLOW
end

function modifier_ability_custom_jiasulunhui_buff:OnCreated(params)
    self.cooldown_reduction = params.cooldown_reduction or 15
end


function modifier_ability_custom_jiasulunhui_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_PROPERTY_COOLDOWN_REDUCTION_CONSTANT
    }
end

function modifier_ability_custom_jiasulunhui_buff:GetModifierCooldownReduction_Constant(keys)
    if not IsServer() then return end
    local ability = keys.ability

    if NotNull(ability) and string.find(ability:GetName(), "ability_custom_call_summon")  then
        return self.cooldown_reduction
    end

    return 0
end

function modifier_ability_custom_jiasulunhui_buff:OnTooltip()
    return self.cooldown_reduction
end