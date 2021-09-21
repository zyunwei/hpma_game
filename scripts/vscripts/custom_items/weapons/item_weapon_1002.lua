item_weapon_1002 = item_weapon_1002 or class({})
LinkLuaModifier("modifier_item_weapon_1002", "custom_items/weapons/item_weapon_1002", LUA_MODIFIER_MOTION_NONE)

function item_weapon_1002:GetIntrinsicModifierName() return "modifier_item_weapon_1002" end

modifier_item_weapon_1002 = class({})

function modifier_item_weapon_1002:IsHidden() return true end
function modifier_item_weapon_1002:IsDebuff() return false end
function modifier_item_weapon_1002:IsPurgable() return false end
function modifier_item_weapon_1002:RemoveOnDeath() return false end

function modifier_item_weapon_1002:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
    }
    return funcs
end

function modifier_item_weapon_1002:OnCreated()
    self.bonus_damage = 0

    local ability = self:GetAbility()
    if ability then
        self.bonus_damage = ability:GetSpecialValueFor("bonus_damage")
    end
end

function modifier_item_weapon_1002:GetModifierPreAttack_BonusDamage()
    return self.bonus_damage
end
