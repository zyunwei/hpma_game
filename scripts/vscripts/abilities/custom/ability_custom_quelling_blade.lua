ability_custom_quelling_blade = ability_custom_quelling_blade or class({})

function ability_custom_quelling_blade:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        if IsNull(caster) then return end
        local modifierParams = {
            crit_mult = self:GetSpecialValueFor("crit_mult"),
            chance = self:GetSpecialValueFor("chance"),
            duration = self:GetSpecialValueFor("duration"),
            kill_trigger = self:GetSpecialValueFor("kill_trigger")
        }

        caster:AddNewModifier(caster, nil, "modifier_quelling_blade", modifierParams)
    end
end

LinkLuaModifier("modifier_quelling_blade", "abilities/custom/ability_custom_quelling_blade", LUA_MODIFIER_MOTION_NONE)

modifier_quelling_blade = class({})

local modifier_quelling_blade = modifier_quelling_blade

function modifier_quelling_blade:IsHidden() return false end
function modifier_quelling_blade:IsDebuff() return false end
function modifier_quelling_blade:IsPurgable() return false end
function modifier_quelling_blade:RemoveOnDeath() return true end

function modifier_quelling_blade:GetTexture()
    return "ability_custom_quelling_blade"
end

function modifier_quelling_blade:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_DEATH,
    }
end

function modifier_quelling_blade:OnDeath(keys)
    local attacker = keys.attacker
    local caster = self:GetCaster()
    local unit = keys.unit
    if IsNull(attacker) or IsNull(caster) or IsNull(unit) then return end
    if attacker == caster then
        self:IncrementStackCount()
        if self:GetStackCount() % self.kill_trigger == 0 then
            EquipCtrl:UpgradeEquip(caster)
        end
    end
end

function modifier_quelling_blade:OnCreated(params)
    self.crit_mult = 200
    if IsServer() then
        if params then
            self.crit_mult = params.crit_mult or self.crit_mult
            self.chance = params.chance
            self.kill_trigger = params.kill_trigger
        end
    end
end

function modifier_quelling_blade:GetModifierPreAttack_CriticalStrike(params)
    if not IsServer() then return 0 end
    if IsNull(params.attacker) or IsNull(self:GetParent()) then return end
    if params.attacker == self:GetParent() then
        if IsNull(params.target) == false and params.target:GetTeam() == DOTA_TEAM_NEUTRALS then
            return self.crit_mult
        end
        return 0
    end
end

function modifier_quelling_blade:OnAttackLanded(keys)
    if not IsServer() then return end
    local attacker = keys.attacker
    local target = keys.target
    local parent = self:GetParent()
    if IsNull(attacker) or IsNull(target) or IsNull(parent) then return end
    if attacker ~= parent then return end
    if not target:IsHero() and not target.IsBoss and RollPercentage(self.chance) then
        target:Kill(nil, parent)
    end
end

function modifier_quelling_blade:OnTooltip()
    return self.crit_mult
end
