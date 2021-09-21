item_weapon_0803 = item_weapon_0803 or class({})
LinkLuaModifier("modifier_item_weapon_0803", "custom_items/weapons/item_weapon_0803", LUA_MODIFIER_MOTION_NONE)

function item_weapon_0803:GetIntrinsicModifierName() return "modifier_item_weapon_0803" end

modifier_item_weapon_0803 = class({})

function modifier_item_weapon_0803:IsHidden() return true end
function modifier_item_weapon_0803:IsDebuff() return false end
function modifier_item_weapon_0803:IsPurgable() return false end
function modifier_item_weapon_0803:RemoveOnDeath() return false end

function modifier_item_weapon_0803:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }
    return funcs
end

function modifier_item_weapon_0803:OnCreated()
    self.bonus_primary = 0
    self.bonus_attack_speed = 0

    local ability = self:GetAbility()
    if ability then
        self.bonus_primary = ability:GetSpecialValueFor("bonus_primary")
        self.bonus_attack_speed = ability:GetSpecialValueFor("bonus_attack_speed")
    end
end

function modifier_item_weapon_0803:GetModifierAttackSpeedBonus_Constant()
    return self.bonus_attack_speed
end

function modifier_item_weapon_0803:GetModifierBonusStats_Strength()
    if self:GetParent().GetPrimaryAttribute ~= nil and self:GetParent():GetPrimaryAttribute() == DOTA_ATTRIBUTE_STRENGTH then
        return self.bonus_primary
    else
        return 0
    end
end

function modifier_item_weapon_0803:GetModifierBonusStats_Agility()
    if self:GetParent().GetPrimaryAttribute ~= nil and self:GetParent():GetPrimaryAttribute() == DOTA_ATTRIBUTE_AGILITY then
        return self.bonus_primary
    else
        return 0
    end
end

function modifier_item_weapon_0803:GetModifierBonusStats_Intellect()
    if self:GetParent().GetPrimaryAttribute ~= nil and self:GetParent():GetPrimaryAttribute() == DOTA_ATTRIBUTE_INTELLECT then
        return self.bonus_primary
    else
        return 0
    end
end
