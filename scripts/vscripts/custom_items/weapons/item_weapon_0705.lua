item_weapon_0705 = item_weapon_0705 or class({})
LinkLuaModifier("modifier_item_weapon_0705", "custom_items/weapons/item_weapon_0705", LUA_MODIFIER_MOTION_NONE)

function item_weapon_0705:GetIntrinsicModifierName() return "modifier_item_weapon_0705" end

modifier_item_weapon_0705 = class({})

function modifier_item_weapon_0705:IsHidden() return true end
function modifier_item_weapon_0705:IsDebuff() return false end
function modifier_item_weapon_0705:IsPurgable() return false end
function modifier_item_weapon_0705:RemoveOnDeath() return false end

function modifier_item_weapon_0705:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }
    return funcs
end

function modifier_item_weapon_0705:OnCreated()
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

function modifier_item_weapon_0705:GetModifierPreAttack_BonusDamage()
    return self.bonus_damage
end

function modifier_item_weapon_0705:GetModifierAttackRangeBonus()
    return self.bonus_attack_range
end

function modifier_item_weapon_0705:GetModifierBonusStats_Strength()
    if self:GetParent().GetPrimaryAttribute ~= nil and self:GetParent():GetPrimaryAttribute() == DOTA_ATTRIBUTE_STRENGTH then
        return self.bonus_primary
    else
        return 0
    end
end

function modifier_item_weapon_0705:GetModifierBonusStats_Agility()
    if self:GetParent().GetPrimaryAttribute ~= nil and self:GetParent():GetPrimaryAttribute() == DOTA_ATTRIBUTE_AGILITY then
        return self.bonus_primary
    else
        return 0
    end
end

function modifier_item_weapon_0705:GetModifierBonusStats_Intellect()
    if self:GetParent().GetPrimaryAttribute ~= nil and self:GetParent():GetPrimaryAttribute() == DOTA_ATTRIBUTE_INTELLECT then
        return self.bonus_primary
    else
        return 0
    end
end
