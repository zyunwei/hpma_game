item_weapon_0702 = item_weapon_0702 or class({})
LinkLuaModifier("modifier_item_weapon_0702", "custom_items/weapons/item_weapon_0702", LUA_MODIFIER_MOTION_NONE)

function item_weapon_0702:GetIntrinsicModifierName() return "modifier_item_weapon_0702" end

modifier_item_weapon_0702 = class({})

function modifier_item_weapon_0702:IsHidden() return true end
function modifier_item_weapon_0702:IsDebuff() return false end
function modifier_item_weapon_0702:IsPurgable() return false end
function modifier_item_weapon_0702:RemoveOnDeath() return false end

function modifier_item_weapon_0702:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
    }
    return funcs
end

function modifier_item_weapon_0702:OnCreated()
    self.bonus_damage = 0

    local ability = self:GetAbility()
    if ability then
        self.bonus_damage = ability:GetSpecialValueFor("bonus_damage")
    end
end

function modifier_item_weapon_0702:GetModifierPreAttack_BonusDamage()
    return self.bonus_damage
end
