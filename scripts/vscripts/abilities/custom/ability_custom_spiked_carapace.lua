ability_custom_spiked_carapace = ability_custom_spiked_carapace or class({})

LinkLuaModifier("modifier_ability_custom_spiked_carapace", "abilities/custom/ability_custom_spiked_carapace", LUA_MODIFIER_MOTION_NONE)

function ability_custom_spiked_carapace:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if IsNull(caster)  then return end

	local mainModifierName = "modifier_ability_custom_spiked_carapace"

	if caster:HasModifier(mainModifierName) then
		caster:RemoveModifierByName(mainModifierName)
	end

	local modifierParams = {
		stun_duration = self:GetSpecialValueFor("stun_duration"),
		duration = self:GetSpecialValueFor("spiked_carapace_duration"),
		trigger_interval = self:GetSpecialValueFor("trigger_interval"),
	}

	caster:AddNewModifier(caster, nil, mainModifierName, modifierParams)

    local sound_cast = "Hero_NyxAssassin.SpikedCarapace"
    EmitSoundOn(sound_cast, caster)
end

modifier_ability_custom_spiked_carapace = class({})
function modifier_ability_custom_spiked_carapace:IsHidden() return false end
function modifier_ability_custom_spiked_carapace:IsDebuff() return false end
function modifier_ability_custom_spiked_carapace:IsPurgable() return false end
function modifier_ability_custom_spiked_carapace:RemoveOnDeath() return true end
function modifier_ability_custom_spiked_carapace:GetTexture()
    return "ability_custom_spiked_carapace"
end

function modifier_ability_custom_spiked_carapace:GetStatusEffectName()
	return "particles/units/heroes/hero_nyx_assassin/status_effect_nyx_assassin_spiked_carapace.vpcf"
end

function modifier_ability_custom_spiked_carapace:OnCreated(params)
	if not IsServer() then return end

	self.stun_duration = params.stun_duration
	self.trigger_interval = params.trigger_interval
	self.caster = self:GetCaster()

	self.particle_spikes_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_spiked_carapace.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self.caster)
	ParticleManager:SetParticleControlEnt(self.particle_spikes_fx, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true)
	self:AddParticle(self.particle_spikes_fx, false, false, -1, false, false)

	self.enemiesHit = {}
end

function modifier_ability_custom_spiked_carapace:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}
end

function modifier_ability_custom_spiked_carapace:GetModifierIncomingDamage_Percentage(keys)
	local attacker = keys.attacker
	local parent = self:GetParent()
	if IsAlive(attacker) == false or IsAlive(parent) == false then return end

	if keys.damage and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
		if not attacker:IsBuilding() and attacker:GetTeamNumber() ~= parent:GetTeamNumber() then
			local damage = keys.original_damage
		    local attackerIndex = attacker:entindex()
            local gameTime = GameRules:GetGameTime()

			if not attacker:IsMagicImmune() and not attacker:IsInvulnerable() then
				local skip_damage = false
				if self.enemiesHit[attackerIndex] then
                    if gameTime - self.enemiesHit[attackerIndex] < self.trigger_interval then
			            skip_damage = true
			        end
				end
				if not skip_damage then
					if self.enemiesHit ~= nil then
                        self.enemiesHit[attackerIndex] = gameTime
					end
					ApplyDamage({
						victim			= attacker,
						attacker		= parent,
						damage			= damage,
						damage_type		= keys.damage_type,
						damage_flags 	= DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_REFLECTION,
						ability			= nil
					})

					attacker:AddNewModifier(parent, nil, "modifier_stunned", {duration = self.stun_duration * (1 - attacker:GetStatusResistance())})
					return -100
				end
			end
		end
	end
end
