ability_custom_treasure_hunter = ability_custom_treasure_hunter or class({})

function ability_custom_treasure_hunter:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        if IsNull(caster) then return end
        local modifierParams = {
            chance = self:GetSpecialValueFor("chance"),
            duration = self:GetSpecialValueFor("duration")
        }
        caster:EmitSound("Hero_Slark.ShadowDance")
        caster:AddNewModifier(caster, nil, "modifier_ability_custom_treasure_hunter", modifierParams)

    end
end

LinkLuaModifier("modifier_ability_custom_treasure_hunter", "abilities/custom/ability_custom_treasure_hunter", LUA_MODIFIER_MOTION_NONE)

modifier_ability_custom_treasure_hunter = class({})

function modifier_ability_custom_treasure_hunter:IsHidden() return false end
function modifier_ability_custom_treasure_hunter:IsDebuff() return false end
function modifier_ability_custom_treasure_hunter:IsPurgable() return false end
function modifier_ability_custom_treasure_hunter:RemoveOnDeath() return true end

function modifier_ability_custom_treasure_hunter:GetTexture()
    return "ability_custom_treasure_hunter"
end

function modifier_ability_custom_treasure_hunter:OnCreated(params)
    if not IsServer() then return end
    self.chance = params.chance or 50
end

function modifier_ability_custom_treasure_hunter:GetChance()
    return self.chance
end