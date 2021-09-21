item_weapon_0905 = item_weapon_0905 or class({})
LinkLuaModifier("modifier_item_weapon_0905", "custom_items/weapons/item_weapon_0905", LUA_MODIFIER_MOTION_NONE)

function item_weapon_0905:GetIntrinsicModifierName() return "modifier_item_weapon_0905" end

modifier_item_weapon_0905 = class({})

function modifier_item_weapon_0905:IsHidden() return true end
function modifier_item_weapon_0905:IsDebuff() return false end
function modifier_item_weapon_0905:IsPurgable() return false end
function modifier_item_weapon_0905:RemoveOnDeath() return false end

function modifier_item_weapon_0905:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS
    }
    return funcs
end

function modifier_item_weapon_0905:OnCreated()
    self.bonus_damage = 0
    self.bonus_attack_speed = 0
    self.bonus_attack_range = 0

    local ability = self:GetAbility()
    if ability then
        self.bonus_damage = ability:GetSpecialValueFor("bonus_damage")
        self.bonus_attack_speed = ability:GetSpecialValueFor("bonus_attack_speed")
        self.bonus_attack_range = ability:GetSpecialValueFor("bonus_attack_range")
    end
end

function modifier_item_weapon_0905:GetModifierPreAttack_BonusDamage()
    return self.bonus_damage
end

function modifier_item_weapon_0905:GetModifierAttackSpeedBonus_Constant()
    return self.bonus_attack_speed
end

function modifier_item_weapon_0905:GetModifierAttackRangeBonus()
    return self.bonus_attack_range
end
