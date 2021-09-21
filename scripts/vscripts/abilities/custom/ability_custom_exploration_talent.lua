ability_custom_exploration_talent = ability_custom_exploration_talent or class({})

function ability_custom_exploration_talent:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        if IsNull(caster) then return end
        local modifierParams = {
            bonus_magic_find = self:GetSpecialValueFor("bonus_magic_find"),
            duration = self:GetSpecialValueFor("duration")
        }

        local affixAttr = self:GetCaster():GetCustomAttribute("tanxian")
        if affixAttr and affixAttr > 0 then
            modifierParams.bonus_magic_find = modifierParams.bonus_magic_find + affixAttr
        end

        caster:AddNewModifier(caster, nil, "modifier_exploration_talent", modifierParams)
    end
end

LinkLuaModifier("modifier_exploration_talent", "abilities/custom/ability_custom_exploration_talent", LUA_MODIFIER_MOTION_NONE)

modifier_exploration_talent = class({})

local modifier_exploration_talent = modifier_exploration_talent

function modifier_exploration_talent:IsHidden() return false end
function modifier_exploration_talent:IsDebuff() return false end
function modifier_exploration_talent:IsPurgable() return false end
function modifier_exploration_talent:RemoveOnDeath() return true end

function modifier_exploration_talent:GetTexture()
    return "ability_custom_exploration_talent"
end

function modifier_exploration_talent:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP,
    }
end

function modifier_exploration_talent:OnCreated(params)
    self.bonus_magic_find = params.bonus_magic_find or 25
    if IsServer() then
        if IsNull(self:GetParent()) then return end
        self:GetParent():ModifyCustomAttribute("magic_find", "magic_find", self.bonus_magic_find)
    end
end

function modifier_exploration_talent:OnTooltip()
    return self.bonus_magic_find
end

function modifier_exploration_talent:OnDestroy()
    if IsServer() then
        if IsNull(self:GetParent()) then return end
        self:GetParent():ModifyCustomAttribute("magic_find", "magic_find", -self.bonus_magic_find)
    end
end
