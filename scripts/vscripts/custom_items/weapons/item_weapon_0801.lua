item_weapon_0801 = item_weapon_0801 or class({})
LinkLuaModifier("modifier_item_weapon_0801", "custom_items/weapons/item_weapon_0801", LUA_MODIFIER_MOTION_NONE)

function item_weapon_0801:GetIntrinsicModifierName() return "modifier_item_weapon_0801" end

modifier_item_weapon_0801 = class({})

function modifier_item_weapon_0801:IsHidden() return true end
function modifier_item_weapon_0801:IsDebuff() return false end
function modifier_item_weapon_0801:IsPurgable() return false end
function modifier_item_weapon_0801:RemoveOnDeath() return false end

function modifier_item_weapon_0801:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }
    return funcs
end

function modifier_item_weapon_0801:OnCreated()
    self.bonus_primary = 0
    
    local ability = self:GetAbility()
    if ability then
        self.bonus_primary = ability:GetSpecialValueFor("bonus_primary")
    end
end

function modifier_item_weapon_0801:GetModifierBonusStats_Strength()
    if self:GetParent().GetPrimaryAttribute ~= nil and self:GetParent():GetPrimaryAttribute() == DOTA_ATTRIBUTE_STRENGTH then
        return self.bonus_primary
    else
        return 0
    end
end

function modifier_item_weapon_0801:GetModifierBonusStats_Agility()
    if self:GetParent().GetPrimaryAttribute ~= nil and self:GetParent():GetPrimaryAttribute() == DOTA_ATTRIBUTE_AGILITY then
        return self.bonus_primary
    else
        return 0
    end
end

function modifier_item_weapon_0801:GetModifierBonusStats_Intellect()
    if self:GetParent().GetPrimaryAttribute ~= nil and self:GetParent():GetPrimaryAttribute() == DOTA_ATTRIBUTE_INTELLECT then
        return self.bonus_primary
    else
        return 0
    end
end
