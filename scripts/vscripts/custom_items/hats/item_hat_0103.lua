item_hat_0103 = item_hat_0103 or class({})
LinkLuaModifier("modifier_item_hat_0103", "custom_items/hats/item_hat_0103", LUA_MODIFIER_MOTION_NONE)

function item_hat_0103:GetIntrinsicModifierName() return "modifier_item_hat_0103" end

modifier_item_hat_0103 = class({})

function modifier_item_hat_0103:IsHidden() return true end
function modifier_item_hat_0103:IsDebuff() return false end
function modifier_item_hat_0103:IsPurgable() return false end
function modifier_item_hat_0103:RemoveOnDeath() return false end

function modifier_item_hat_0103:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING,
        MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
        MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE,
    }
    return funcs
end

function modifier_item_hat_0103:OnCreated()
    self.bonus_all_stats = 0
    self.bonus_status_resistance = 0
    self.bonus_health_percent = 0
    self.bonus_spell_range = 0

    local ability = self:GetAbility()
    if ability then
        self.bonus_all_stats = ability:GetSpecialValueFor("bonus_all_stats") or 0
        self.bonus_status_resistance = ability:GetSpecialValueFor("bonus_status_resistance") or 0
        self.bonus_health_percent = ability:GetSpecialValueFor("bonus_health_percent") or 0
        self.bonus_spell_range = ability:GetSpecialValueFor("bonus_spell_range") or 0
    end
end

function modifier_item_hat_0103:GetModifierBonusStats_Strength()
    return self.bonus_all_stats
end

function modifier_item_hat_0103:GetModifierBonusStats_Agility()
    return self.bonus_all_stats
end

function modifier_item_hat_0103:GetModifierBonusStats_Intellect()
    return self.bonus_all_stats
end

function modifier_item_hat_0103:GetModifierCastRangeBonusStacking()
    return self.bonus_spell_range
end

function modifier_item_hat_0103:GetModifierStatusResistanceStacking()
    return self.bonus_status_resistance
end

function modifier_item_hat_0103:GetModifierExtraHealthPercentage()
    return self.bonus_health_percent
end
