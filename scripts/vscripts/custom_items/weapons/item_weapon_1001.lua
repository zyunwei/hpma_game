item_weapon_1001 = item_weapon_1001 or class({})
LinkLuaModifier("modifier_item_weapon_1001", "custom_items/weapons/item_weapon_1001", LUA_MODIFIER_MOTION_NONE)

function item_weapon_1001:GetIntrinsicModifierName() return "modifier_item_weapon_1001" end

modifier_item_weapon_1001 = class({})

function modifier_item_weapon_1001:IsHidden() return true end
function modifier_item_weapon_1001:IsDebuff() return false end
function modifier_item_weapon_1001:IsPurgable() return false end
function modifier_item_weapon_1001:RemoveOnDeath() return false end

function modifier_item_weapon_1001:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
    }
    return funcs
end

function modifier_item_weapon_1001:OnCreated()
    self.bonus_damage = 0

    local ability = self:GetAbility()
    if ability then
        self.bonus_damage = ability:GetSpecialValueFor("bonus_damage")
    end
end

function modifier_item_weapon_1001:GetModifierPreAttack_BonusDamage()
    return self.bonus_damage
end
