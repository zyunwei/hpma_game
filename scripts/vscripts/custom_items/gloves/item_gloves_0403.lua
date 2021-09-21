item_gloves_0403 = item_gloves_0403 or class({})
LinkLuaModifier("modifier_item_gloves_0403", "custom_items/gloves/item_gloves_0403", LUA_MODIFIER_MOTION_NONE)

function item_gloves_0403:GetIntrinsicModifierName() return "modifier_item_gloves_0403" end

modifier_item_gloves_0403 = class({})

function modifier_item_gloves_0403:IsHidden() return true end
function modifier_item_gloves_0403:IsDebuff() return false end
function modifier_item_gloves_0403:IsPurgable() return false end
function modifier_item_gloves_0403:RemoveOnDeath() return false end

function modifier_item_gloves_0403:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

function modifier_item_gloves_0403:OnCreated()
    self.bonus_attack_speed = 0
    self.bonus_spell_amplify = 0
    self.bonus_hit_hp = 0
    self.bonus_hit_mp = 0

    local ability = self:GetAbility()
    if ability then
        self.bonus_attack_speed = ability:GetSpecialValueFor("bonus_attack_speed") or 0
        self.bonus_spell_amplify = ability:GetSpecialValueFor("bonus_spell_amplify") or 0
        self.bonus_hit_hp = ability:GetSpecialValueFor("bonus_hit_hp") or 0
        self.bonus_hit_mp = ability:GetSpecialValueFor("bonus_hit_mp") or 0
    end
end

function modifier_item_gloves_0403:GetModifierAttackSpeedBonus_Constant()
    return self.bonus_attack_speed
end

function modifier_item_gloves_0403:GetModifierSpellAmplify_Percentage()
    return self.bonus_spell_amplify
end

function modifier_item_gloves_0403:OnAttackLanded(keys)
    if not IsServer() then return end

    local parent = self:GetParent()
    local attacker = keys.attacker
    local target = keys.target
    if IsNull(parent) or IsNull(attacker) or IsNull(target) then return end

    if attacker == parent then
        if self.bonus_hit_hp > 0 then
            parent:Heal(self.bonus_hit_hp, nil)
        end

        if self.bonus_hit_mp > 0 then
            parent:GiveMana(self.bonus_hit_mp)
        end
    end
end
