item_shoes_0204 = item_shoes_0204 or class({})
LinkLuaModifier("modifier_item_shoes_0204", "custom_items/shoes/item_shoes_0204", LUA_MODIFIER_MOTION_NONE)

function item_shoes_0204:GetIntrinsicModifierName() return "modifier_item_shoes_0204" end

modifier_item_shoes_0204 = class({})

function modifier_item_shoes_0204:IsHidden() return true end
function modifier_item_shoes_0204:IsDebuff() return false end
function modifier_item_shoes_0204:IsPurgable() return false end
function modifier_item_shoes_0204:RemoveOnDeath() return false end

function modifier_item_shoes_0204:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING,
        MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
    return funcs
end

function modifier_item_shoes_0204:OnCreated()
    self.bonus_movement_speed = 0
    self.bonus_status_resistance = 0
    self.bonus_armor = 0
    self.bonus_all_stats = 0
    
    local ability = self:GetAbility()
    if ability then
        self.bonus_movement_speed = ability:GetSpecialValueFor("bonus_movement_speed") or 0
        self.bonus_status_resistance = ability:GetSpecialValueFor("bonus_status_resistance") or 0
        self.bonus_armor = ability:GetSpecialValueFor("bonus_armor") or 0
        self.bonus_all_stats = ability:GetSpecialValueFor("bonus_all_stats") or 0
    end
end

function modifier_item_shoes_0204:GetModifierBonusStats_Strength()
    return self.bonus_all_stats
end

function modifier_item_shoes_0204:GetModifierBonusStats_Agility()
    return self.bonus_all_stats
end

function modifier_item_shoes_0204:GetModifierBonusStats_Intellect()
    return self.bonus_all_stats
end

function modifier_item_shoes_0204:GetModifierMoveSpeedBonus_Constant()
    return self.bonus_movement_speed
end

function modifier_item_shoes_0204:GetModifierStatusResistanceStacking()
    return self.bonus_status_resistance
end

function modifier_item_shoes_0204:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end
