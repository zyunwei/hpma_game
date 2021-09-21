ability_custom_outlaw_maniac = ability_custom_outlaw_maniac or class({})

LinkLuaModifier("modifier_ability_custom_outlaw_maniac_buff", "abilities/custom/ability_custom_outlaw_maniac", LUA_MODIFIER_MOTION_NONE)

function ability_custom_outlaw_maniac:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
    local modifierParams = {
        duration = self:GetSpecialValueFor("duration"),
        bonus_damage_pct = self:GetSpecialValueFor("bonus_damage_pct"),
        bonus_magic_find = self:GetSpecialValueFor("bonus_magic_find")
    }
    caster:AddNewModifier(caster, nil, "modifier_ability_custom_outlaw_maniac_buff", modifierParams)

end

modifier_ability_custom_outlaw_maniac_buff = modifier_ability_custom_outlaw_maniac_buff or class({})

function modifier_ability_custom_outlaw_maniac_buff:IsHidden() return false end
function modifier_ability_custom_outlaw_maniac_buff:IsDebuff() return false end
function modifier_ability_custom_outlaw_maniac_buff:IsPurgable() return false end
function modifier_ability_custom_outlaw_maniac_buff:RemoveOnDeath() return true end

function modifier_ability_custom_outlaw_maniac_buff:GetEffectName()
    return "particles/units/heroes/hero_ogre_magi/ogre_magi_fire_shield_bubble_outer.vpcf"
end

-- function modifier_ability_custom_outlaw_maniac_buff:GetEffectAttachType()
--     return PATTACH_OVERHEAD_FOLLOW 
-- end

function modifier_ability_custom_outlaw_maniac_buff:GetTexture()
    return "ability_custom_outlaw_maniac"
end

function modifier_ability_custom_outlaw_maniac_buff:OnCreated(params)
    if not IsServer() then return end
    self.bonus_damage_pct = params.bonus_damage_pct or 20
    self.bonus_magic_find = params.bonus_magic_find or 20
end

function modifier_ability_custom_outlaw_maniac_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
    }
end

function modifier_ability_custom_outlaw_maniac_buff:GetModifierDamageOutgoing_Percentage()
    if not IsServer() then return end
    if NotNull(self:GetParent()) and self:GetParent():HasModifier("modifier_in_blockade") then
        return self.bonus_damage_pct
    end
end

function modifier_ability_custom_outlaw_maniac_buff:GetBonusMagicFind()
    if not IsServer() then return end
    if NotNull(self:GetParent()) and self:GetParent():HasModifier("modifier_in_blockade") then
        return self.bonus_magic_find
    end
end