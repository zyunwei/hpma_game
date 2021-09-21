ability_custom_shadow_dance = ability_custom_shadow_dance or class({})

function ability_custom_shadow_dance:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        if IsNull(caster) then return end
        local modifierParams = {
            bonus_movement_speed_pct = self:GetSpecialValueFor("bonus_movement_speed_pct"),
            bonus_health_regen_pct = self:GetSpecialValueFor("bonus_health_regen_pct"),
            buff_duration = self:GetSpecialValueFor("duration"),
            trigger_health_pct = self:GetSpecialValueFor("trigger_health_pct")
        }
        if caster:HasModifier("modifier_anyingzhiwuxinfa") then
            modifierParams.buff_duration = modifierParams.buff_duration + 1
        end
        caster:AddNewModifier(caster, nil, "modifier_shadow_dance_trigger", modifierParams)
    end
end

LinkLuaModifier("modifier_shadow_dance_trigger", "abilities/custom/ability_custom_shadow_dance", LUA_MODIFIER_MOTION_NONE)

modifier_shadow_dance_trigger = class({})

function modifier_shadow_dance_trigger:IsHidden() return false end
function modifier_shadow_dance_trigger:IsDebuff() return false end
function modifier_shadow_dance_trigger:IsPurgable() return false end
function modifier_shadow_dance_trigger:RemoveOnDeath() return true end

function modifier_shadow_dance_trigger:GetTexture()
    return "ability_custom_shadow_dance"
end

function modifier_shadow_dance_trigger:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
end

function modifier_shadow_dance_trigger:OnCreated(params)
    if not IsServer() then return end
    self.bonus_movement_speed_pct = params.bonus_movement_speed_pct or 24
    self.bonus_health_regen_pct = params.bonus_health_regen_pct or 4
    self.buff_duration = params.buff_duration or 4
    self.trigger_health_pct = params.trigger_health_pct or 10
end

function modifier_shadow_dance_trigger:OnTakeDamage(keys)
    if not IsServer() then return end
    local attacker = keys.attacker
    local unit = keys.unit
    local parent = self:GetParent()
    if IsNull(attacker) or IsNull(unit) or IsNull(parent) then return end
    if unit ~= parent then return end

    if unit:GetHealthPercent() <= self.trigger_health_pct then
        local modifierParams = {
            bonus_movement_speed_pct = self.bonus_movement_speed_pct,
            bonus_health_regen_pct = self.bonus_health_regen_pct,
            duration = self.buff_duration
        }
        unit:EmitSound("Hero_Slark.ShadowDance")
        unit:AddNewModifier(unit, nil, "modifier_ability_custom_shadow_dance", modifierParams)
        self:Destroy()
    end
end

LinkLuaModifier("modifier_ability_custom_shadow_dance", "abilities/custom/ability_custom_shadow_dance", LUA_MODIFIER_MOTION_NONE)

modifier_ability_custom_shadow_dance = class({})

function modifier_ability_custom_shadow_dance:IsHidden() return false end
function modifier_ability_custom_shadow_dance:IsDebuff() return false end
function modifier_ability_custom_shadow_dance:IsPurgable() return false end
function modifier_ability_custom_shadow_dance:RemoveOnDeath() return true end

function modifier_ability_custom_shadow_dance:GetTexture()
    return "ability_custom_shadow_dance"
end

function modifier_ability_custom_shadow_dance:GetStatusEffectName()
	return "particles/status_fx/status_effect_slark_shadow_dance.vpcf"
end

function modifier_ability_custom_shadow_dance:IsAura()
    local parent = self:GetParent()
    if IsNull(parent) then return false end
    if parent:HasModifier("modifier_anyingzhiwuxinfa") then
        return true
    end
end

function modifier_ability_custom_shadow_dance:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_ability_custom_shadow_dance:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE 
end

function modifier_ability_custom_shadow_dance:GetAuraSearchType()
	return DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_OTHER
end

function modifier_ability_custom_shadow_dance:GetModifierAura()
	return "modifier_ability_custom_shadow_dance_aura"
end

function modifier_ability_custom_shadow_dance:GetAuraRadius()
	return 300
end

function modifier_ability_custom_shadow_dance:OnCreated(params)
    if IsServer() then
        local parent = self:GetParent()
        if IsNull(parent) then return end
        self.bonus_movement_speed_pct = params.bonus_movement_speed_pct or 24
        self.bonus_health_regen_pct = params.bonus_health_regen_pct or 4
        self.shadow_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_shadow_dance_dummy.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
        ParticleManager:SetParticleControlEnt(self.shadow_particle, 1, parent, PATTACH_POINT_FOLLOW, nil, parent:GetAbsOrigin(), true)
        self:AddParticle(self.shadow_particle, false, false, -1, false, false)


        local visual_unit = CreateUnitByName("npc_dota_slark_visual", parent:GetAbsOrigin(), true, parent, parent, parent:GetTeamNumber())
		visual_unit:AddNewModifier(parent, nil, "modifier_custom_slark_visual", {})
		visual_unit:AddNewModifier(parent, nil, "modifier_kill", {duration = self:GetDuration() + 0.5})

        self.shadow_dummy_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_shadow_dance_dummy.vpcf", PATTACH_ABSORIGIN_FOLLOW, visual_unit)
		ParticleManager:SetParticleControlEnt(self.shadow_dummy_particle, 1, visual_unit, PATTACH_POINT_FOLLOW, nil, visual_unit:GetAbsOrigin(), true)
		self:AddParticle(self.shadow_dummy_particle, false, false, -1, false, false)
    end
end

function modifier_ability_custom_shadow_dance:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
	}
end

function modifier_ability_custom_shadow_dance:GetModifierInvisibilityLevel()
	return 1
end

function modifier_ability_custom_shadow_dance:GetActivityTranslationModifiers()
	return "shadow_dance"
end

function modifier_ability_custom_shadow_dance:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE]			= true,
		[MODIFIER_STATE_TRUESIGHT_IMMUNE]	= true,
        [MODIFIER_STATE_UNTARGETABLE]       = true,
        [MODIFIER_STATE_UNSELECTABLE]       = true,
	}
end

function modifier_ability_custom_shadow_dance:GetModifierMoveSpeedBonus_Percentage()
    return self.bonus_movement_speed_pct
end

function modifier_ability_custom_shadow_dance:GetModifierHealthRegenPercentage()
	return self.bonus_health_regen_pct
end

LinkLuaModifier("modifier_custom_slark_visual", "abilities/custom/ability_custom_shadow_dance", LUA_MODIFIER_MOTION_NONE)

modifier_custom_slark_visual = class({})

function modifier_custom_slark_visual:IsPurgable()	return false end

function modifier_custom_slark_visual:RemoveOnDeath()	return true end

function modifier_custom_slark_visual:OnCreated()
	if not IsServer() then return end

	self:StartIntervalThink(FrameTime())
end

function modifier_custom_slark_visual:OnIntervalThink()
    local caster = self:GetCaster()
    local parent = self:GetParent()
    if IsNull(parent) or IsNull(caster) then return end
	parent:SetAbsOrigin(caster:GetAbsOrigin())
end

function modifier_custom_slark_visual:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE]				= false,
		[MODIFIER_STATE_NO_HEALTH_BAR]			= true,
		[MODIFIER_STATE_NO_UNIT_COLLISION]		= true,
		[MODIFIER_STATE_INVULNERABLE]			= true,
		[MODIFIER_STATE_LOW_ATTACK_PRIORITY]	= true,
		[MODIFIER_STATE_UNSELECTABLE]			= true,
		[MODIFIER_STATE_UNTARGETABLE]			= true,
		[MODIFIER_STATE_NOT_ON_MINIMAP]			= true
	}
end

LinkLuaModifier("modifier_ability_custom_shadow_dance_aura", "abilities/custom/ability_custom_shadow_dance", LUA_MODIFIER_MOTION_NONE)

modifier_ability_custom_shadow_dance_aura = class({})

function modifier_ability_custom_shadow_dance_aura:IsPurgable()	return false end

function modifier_ability_custom_shadow_dance_aura:RemoveOnDeath()	return true end

function modifier_ability_custom_shadow_dance_aura:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE]			= true,
		[MODIFIER_STATE_TRUESIGHT_IMMUNE]	= true
	}
end

function modifier_ability_custom_shadow_dance_aura:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
	}
end

function modifier_ability_custom_shadow_dance_aura:GetModifierInvisibilityLevel()
	return 1
end

function modifier_ability_custom_shadow_dance_aura:GetActivityTranslationModifiers()
	return "shadow_dance"
end

function modifier_ability_custom_shadow_dance_aura:GetTexture()
    return "ability_custom_shadow_dance"
end