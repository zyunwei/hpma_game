item_shoes_0401 = item_shoes_0401 or class({})
LinkLuaModifier("modifier_item_shoes_0401", "custom_items/shoes/item_shoes_0401", LUA_MODIFIER_MOTION_NONE)

function item_shoes_0401:GetIntrinsicModifierName() return "modifier_item_shoes_0401" end

modifier_item_shoes_0401 = class({})

function modifier_item_shoes_0401:IsHidden() return true end
function modifier_item_shoes_0401:IsDebuff() return false end
function modifier_item_shoes_0401:IsPurgable() return false end
function modifier_item_shoes_0401:RemoveOnDeath() return false end

function modifier_item_shoes_0401:DeclareFunctions()
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

function modifier_item_shoes_0401:OnCreated()
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

function modifier_item_shoes_0401:GetModifierBonusStats_Strength()
    return self.bonus_all_stats
end

function modifier_item_shoes_0401:GetModifierBonusStats_Agility()
    return self.bonus_all_stats
end

function modifier_item_shoes_0401:GetModifierBonusStats_Intellect()
    return self.bonus_all_stats
end

function modifier_item_shoes_0401:GetModifierMoveSpeedBonus_Constant()
    return self.bonus_movement_speed
end

function modifier_item_shoes_0401:GetModifierStatusResistanceStacking()
    return self.bonus_status_resistance
end

function modifier_item_shoes_0401:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end
