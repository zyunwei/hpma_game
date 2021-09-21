item_weapon_0802 = item_weapon_0802 or class({})
LinkLuaModifier("modifier_item_weapon_0802", "custom_items/weapons/item_weapon_0802", LUA_MODIFIER_MOTION_NONE)

function item_weapon_0802:GetIntrinsicModifierName() return "modifier_item_weapon_0802" end

modifier_item_weapon_0802 = class({})

function modifier_item_weapon_0802:IsHidden() return true end
function modifier_item_weapon_0802:IsDebuff() return false end
function modifier_item_weapon_0802:IsPurgable() return false end
function modifier_item_weapon_0802:RemoveOnDeath() return false end

function modifier_item_weapon_0802:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }
    return funcs
end

function modifier_item_weapon_0802:OnCreated()
    self.bonus_primary = 0

    local ability = self:GetAbility()
    if ability then
        self.bonus_primary = ability:GetSpecialValueFor("bonus_primary")
    end
end

function modifier_item_weapon_0802:GetModifierBonusStats_Strength()
    if self:GetParent().GetPrimaryAttribute ~= nil and self:GetParent():GetPrimaryAttribute() == DOTA_ATTRIBUTE_STRENGTH then
        return self.bonus_primary
    else
        return 0
    end
end

function modifier_item_weapon_0802:GetModifierBonusStats_Agility()
    if self:GetParent().GetPrimaryAttribute ~= nil and self:GetParent():GetPrimaryAttribute() == DOTA_ATTRIBUTE_AGILITY then
        return self.bonus_primary
    else
        return 0
    end
end

function modifier_item_weapon_0802:GetModifierBonusStats_Intellect()
    if self:GetParent().GetPrimaryAttribute ~= nil and self:GetParent():GetPrimaryAttribute() == DOTA_ATTRIBUTE_INTELLECT then
        return self.bonus_primary
    else
        return 0
    end
end
