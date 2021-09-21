ability_custom_eyes_in_the_forest = ability_custom_eyes_in_the_forest or class({})

LinkLuaModifier("modifier_eyes_in_the_forest", "abilities/custom/ability_custom_eyes_in_the_forest", LUA_MODIFIER_MOTION_NONE)

function ability_custom_eyes_in_the_forest:OnAbilityPhaseStart()
    return self:CheckPhaseStart()
end

function ability_custom_eyes_in_the_forest:OnSpellStart()
    return self:CheckSpellStart()
end

function ability_custom_eyes_in_the_forest:CastAbilityTarget(target)
    if GameRules.XW.DynamicVision == false then return end
    if IsNull(target) then return end
    local caster = self:GetCaster()
    if IsNull(caster) then return end
    local vision = self:GetSpecialValueFor("vision")
    local tree = CreateUnitByName("npc_dummy_unit_invisible", target:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
    tree:AddNewModifier(caster, nil, "modifier_eyes_in_the_forest", {vision = vision, target = target:entindex()})
end

modifier_eyes_in_the_forest = modifier_eyes_in_the_forest or class({})

function modifier_eyes_in_the_forest:OnCreated(params)
    if not IsServer() then return end
    local parent = self:GetParent()

    if IsNull(parent) then return end
    self.vision = params.vision or 800
    self.target = params.target or -1
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_treant/treant_eyesintheforest.vpcf", PATTACH_WORLDORIGIN, parent)
    ParticleManager:SetParticleControl(particle, 0, parent:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, parent:GetAbsOrigin())
    self:AddParticle(particle, false, false, -1, false, false)
    self:StartIntervalThink(FrameTime() * 3)
end

function modifier_eyes_in_the_forest:OnIntervalThink()
    local parent = self:GetParent()
    local tree = EntIndexToHScript(self.target)
    if IsNull(tree) or IsNull(parent) then return end
    if not tree:IsStanding() then
        self:Destroy()
        parent:ForceKill(false)
    else
        AddFOWViewer(parent:GetTeamNumber(), parent:GetAbsOrigin(), self.vision, FrameTime() * 3, false)
    end
end
