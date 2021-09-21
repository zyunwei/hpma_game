item_weapon_0901 = item_weapon_0901 or class({})
LinkLuaModifier("modifier_item_weapon_0901", "custom_items/weapons/item_weapon_0901", LUA_MODIFIER_MOTION_NONE)

function item_weapon_0901:GetIntrinsicModifierName() return "modifier_item_weapon_0901" end

modifier_item_weapon_0901 = class({})

function modifier_item_weapon_0901:IsHidden() return true end
function modifier_item_weapon_0901:IsDebuff() return false end
function modifier_item_weapon_0901:IsPurgable() return false end
function modifier_item_weapon_0901:RemoveOnDeath() return false end

function modifier_item_weapon_0901:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
    }
    return funcs
end

function modifier_item_weapon_0901:OnCreated()
    self.bonus_damage = 0

    local ability = self:GetAbility()
    if ability then
        self.bonus_damage = ability:GetSpecialValueFor("bonus_damage")
    end
end

function modifier_item_weapon_0901:GetModifierPreAttack_BonusDamage()
    return self.bonus_damage
end
