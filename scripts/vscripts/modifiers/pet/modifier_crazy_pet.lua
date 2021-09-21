modifier_crazy_pet = class({})

function modifier_crazy_pet:IsHidden() return false end
function modifier_crazy_pet:IsDebuff() return false end
function modifier_crazy_pet:IsPurgable() return true end
function modifier_crazy_pet:RemoveOnDeath() return true end

function modifier_crazy_pet:GetTexture()
    return "ability_custom_crazy_pet"
end

function modifier_crazy_pet:GetEffectName()
    return "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff.vpcf"
end

function modifier_crazy_pet:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_crazy_pet:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
    return funcs
end

function modifier_crazy_pet:OnCreated(params)
    if not IsServer() then return end

    self.bonus_attackspeed = params.bonus_attackspeed or 100
end

function modifier_crazy_pet:GetModifierAttackSpeedBonus_Constant()
    return self.bonus_attackspeed
end
