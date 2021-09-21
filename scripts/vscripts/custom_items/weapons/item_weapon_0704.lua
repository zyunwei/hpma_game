item_weapon_0704 = item_weapon_0704 or class({})
LinkLuaModifier("modifier_item_weapon_0704", "custom_items/weapons/item_weapon_0704", LUA_MODIFIER_MOTION_NONE)

function item_weapon_0704:GetIntrinsicModifierName() return "modifier_item_weapon_0704" end

modifier_item_weapon_0704 = class({})

function modifier_item_weapon_0704:IsHidden() return true end
function modifier_item_weapon_0704:IsDebuff() return false end
function modifier_item_weapon_0704:IsPurgable() return false end
function modifier_item_weapon_0704:RemoveOnDeath() return false end

function modifier_item_weapon_0704:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }
    return funcs
end

function modifier_item_weapon_0704:OnCreated()
    self.bonus_damage = 0
    self.bonus_attack_range = 0
    self.bonus_primary = 0

    local ability = self:GetAbility()
    if ability then
        self.bonus_damage = ability:GetSpecialValueFor("bonus_damage")
        self.bonus_attack_range = ability:GetSpecialValueFor("bonus_attack_range")
        self.bonus_primary = ability:GetSpecialValueFor("bonus_primary")
    end
end

function modifier_item_weapon_0704:GetModifierPreAttack_BonusDamage()
    return self.bonus_damage
end

function modifier_item_weapon_0704:GetModifierAttackRangeBonus()
    return self.bonus_attack_range
end

function modifier_item_weapon_0704:GetModifierBonusStats_Strength()
    if self:GetParent().GetPrimaryAttribute ~= nil and self:GetParent():GetPrimaryAttribute() == DOTA_ATTRIBUTE_STRENGTH then
        return self.bonus_primary
    else
        return 0
    end
end

function modifier_item_weapon_0704:GetModifierBonusStats_Agility()
    if self:GetParent().GetPrimaryAttribute ~= nil and self:GetParent():GetPrimaryAttribute() == DOTA_ATTRIBUTE_AGILITY then
        return self.bonus_primary
    else
        return 0
    end
end

function modifier_item_weapon_0704:GetModifierBonusStats_Intellect()
    if self:GetParent().GetPrimaryAttribute ~= nil and self:GetParent():GetPrimaryAttribute() == DOTA_ATTRIBUTE_INTELLECT then
        return self.bonus_primary
    else
        return 0
    end
end
