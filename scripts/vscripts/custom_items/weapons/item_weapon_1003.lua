item_weapon_1003 = item_weapon_1003 or class({})
LinkLuaModifier("modifier_item_weapon_1003", "custom_items/weapons/item_weapon_1003", LUA_MODIFIER_MOTION_NONE)

function item_weapon_1003:GetIntrinsicModifierName() return "modifier_item_weapon_1003" end

modifier_item_weapon_1003 = class({})

function modifier_item_weapon_1003:IsHidden() return true end
function modifier_item_weapon_1003:IsDebuff() return false end
function modifier_item_weapon_1003:IsPurgable() return false end
function modifier_item_weapon_1003:RemoveOnDeath() return false end

function modifier_item_weapon_1003:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
    return funcs
end

function modifier_item_weapon_1003:OnCreated()
    self.bonus_damage = 0
    self.bonus_attack_speed = 0

    local ability = self:GetAbility()
    if ability then
        self.bonus_damage = ability:GetSpecialValueFor("bonus_damage")
        self.bonus_attack_speed = ability:GetSpecialValueFor("bonus_attack_speed")
    end
end

function modifier_item_weapon_1003:GetModifierPreAttack_BonusDamage()
    return self.bonus_damage
end

function modifier_item_weapon_1003:GetModifierAttackSpeedBonus_Constant()
    return self.bonus_attack_speed
end
