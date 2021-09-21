item_weapon_0902 = item_weapon_0902 or class({})
LinkLuaModifier("modifier_item_weapon_0902", "custom_items/weapons/item_weapon_0902", LUA_MODIFIER_MOTION_NONE)

function item_weapon_0902:GetIntrinsicModifierName() return "modifier_item_weapon_0902" end

modifier_item_weapon_0902 = class({})

function modifier_item_weapon_0902:IsHidden() return true end
function modifier_item_weapon_0902:IsDebuff() return false end
function modifier_item_weapon_0902:IsPurgable() return false end
function modifier_item_weapon_0902:RemoveOnDeath() return false end

function modifier_item_weapon_0902:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
    }
    return funcs
end

function modifier_item_weapon_0902:OnCreated()
    self.bonus_damage = 0

    local ability = self:GetAbility()
    if ability then
        self.bonus_damage = ability:GetSpecialValueFor("bonus_damage")
    end
end

function modifier_item_weapon_0902:GetModifierPreAttack_BonusDamage()
    return self.bonus_damage
end
