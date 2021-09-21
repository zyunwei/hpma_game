ability_custom_chronosphere = ability_custom_chronosphere or class({})

function ability_custom_chronosphere:OnAbilityPhaseStart()
    return self:CheckPhaseStart()
end

function ability_custom_chronosphere:OnSpellStart()
    return self:CheckSpellStart()
end

function ability_custom_chronosphere:CastAbilityTarget(target)
    if NotNull(target) then
        local caster = self:GetCaster()
        if IsNull(caster) then return end
        local modifierParams = {
            duration = self:GetSpecialValueFor("duration"),
            radius = self:GetSpecialValueFor("radius"),
        }

        local sound_cast = "Hero_FacelessVoid.Chronosphere"
        caster:EmitSound(sound_cast)

        CreateModifierThinker(caster, nil, "modifier_custom_chronosphere", modifierParams, target:GetAbsOrigin(), caster:GetTeam(), false)
    end
end

LinkLuaModifier("modifier_custom_chronosphere", "abilities/custom/ability_custom_chronosphere", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_custom_chronosphere_debuff", "abilities/custom/ability_custom_chronosphere", LUA_MODIFIER_MOTION_NONE)

modifier_custom_chronosphere = class({})

function modifier_custom_chronosphere:IsPurgable() return false end
function modifier_custom_chronosphere:IsHidden() return true end
function modifier_custom_chronosphere:IsAura() return true end

function modifier_custom_chronosphere:GetAuraEntityReject(target)
    if IsNull(target) or IsNull(self:GetCaster()) then return end
    if target ~= self:GetCaster() then
        return false
    else
        return true
    end
end

function modifier_custom_chronosphere:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY 
end

function modifier_custom_chronosphere:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE 
end

function modifier_custom_chronosphere:GetAuraSearchType()
	return DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BUILDING + DOTA_UNIT_TARGET_OTHER 
end

function modifier_custom_chronosphere:GetModifierAura()
	return "modifier_custom_chronosphere_debuff"
end

function modifier_custom_chronosphere:GetAuraRadius()
	return self.radius
end

function modifier_custom_chronosphere:OnCreated(params)
    if not IsServer() then return end
    self.radius = params.radius
    self.parent = self:GetParent()
    if IsNull(self.parent) then return end
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_chronosphere.vpcf", PATTACH_WORLDORIGIN, self.parent)
    ParticleManager:SetParticleControl(particle, 0, self.parent:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(self.radius, self.radius, self.radius))
    self:AddParticle(particle, false, false, -1, false, false)
end

modifier_custom_chronosphere_debuff = class({})

function modifier_custom_chronosphere_debuff:IsPurgable() return false end
function modifier_custom_chronosphere_debuff:IsHidden() return false end
function modifier_custom_chronosphere_debuff:IsDebuff() return true end

function modifier_custom_chronosphere_debuff:GetTexture()
    return "ability_custom_chronosphere"
end

function modifier_custom_chronosphere_debuff:CheckState()
    return {
		[MODIFIER_STATE_MUTED] = true,
		[MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_FROZEN] = true,
        [MODIFIER_STATE_ROOTED] = true,
    }
end