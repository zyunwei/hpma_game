ability_custom_voodoo = ability_custom_voodoo or class({})

LinkLuaModifier("modifier_ability_custom_voodoo","abilities/custom/ability_custom_voodoo",LUA_MODIFIER_MOTION_NONE)

function ability_custom_voodoo:OnAbilityPhaseStart()
	return self:CheckPhaseStart()
end

function ability_custom_voodoo:OnSpellStart()
	return self:CheckSpellStart()
end

function ability_custom_voodoo:CastAbilityTarget(target)
	local caster = self:GetCaster()
	if IsNull(caster) then return end
    if IsNull(target) == false then
        local modifierParams = {
            duration = self:GetSpecialValueFor("voodoo_duration"),
			move_speed = self:GetSpecialValueFor("move_speed")
        }

        local affixAttr = self:GetCaster():GetCustomAttribute("hex_duration")
	    if affixAttr and affixAttr > 0 then
	        modifierParams.duration = modifierParams.duration + affixAttr
	    end

	    modifierParams.duration = modifierParams.duration * (1 - target:GetStatusResistance())

        target:AddNewModifier(caster, nil, "modifier_ability_custom_voodoo", modifierParams)
    end
end

modifier_ability_custom_voodoo = class({})

function modifier_ability_custom_voodoo:IsHidden() return true end
function modifier_ability_custom_voodoo:IsDebuff() return true end
function modifier_ability_custom_voodoo:IsPurgable() return false end
function modifier_ability_custom_voodoo:IsPurgeException() return true end
function modifier_ability_custom_voodoo:RemoveOnDeath() return true end

function modifier_ability_custom_voodoo:GetTexture()
	return "ability_custom_voodoo"
end

function modifier_ability_custom_voodoo:OnCreated(params)
	if not IsServer() then return end

	self.move_speed = params.move_speed or 100
	local parent = self:GetParent()
	if IsNull(parent) then return end

	EmitSoundOn("Hero_Lion.Voodoo", parent)

	local particle_hex = "particles/units/heroes/hero_lion/lion_spell_voodoo.vpcf"
	local particle_hex_fx = ParticleManager:CreateParticle(particle_hex, PATTACH_CUSTOMORIGIN, parent)
	ParticleManager:SetParticleControl(particle_hex_fx, 0, parent:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle_hex_fx)
end

function modifier_ability_custom_voodoo:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE
	}

	return funcs
end

function modifier_ability_custom_voodoo:GetModifierModelChange()
	return "models/props_gameplay/frog.vmdl"
end

function modifier_ability_custom_voodoo:IsHexDebuff()
	return true
end

function modifier_ability_custom_voodoo:CheckState()
	local state = {
        [MODIFIER_STATE_HEXED] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_MUTED] = true
    }
    return state
end

function modifier_ability_custom_voodoo:GetModifierMoveSpeedOverride()
	return self.move_speed
end