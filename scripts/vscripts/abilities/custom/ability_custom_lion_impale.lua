ability_custom_lion_impale = class({})

function ability_custom_lion_impale:OnAbilityPhaseStart()
	return self:CheckPhaseStart()
end

function ability_custom_lion_impale:OnSpellStart()
	return self:CheckSpellStart()
end

function ability_custom_lion_impale:CastAbilityTarget(target)
	local caster = self:GetCaster()
	if IsAlive(target) == false or IsAlive(caster) == false then
		return
	end

	local particle_projectile = "particles/units/heroes/hero_lion/lion_spell_impale.vpcf"
	local sound_cast = "Hero_Lion.Impale"

	caster:EmitSound(sound_cast)

	local spike_speed = 1600
	local travel_distance = 1600 + caster:GetCastRangeBonus()
	local spikes_radius = self:GetSpecialValueFor("width")
	local direction = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
	local spikes_projectile = { Ability = self,
								EffectName = particle_projectile,
								vSpawnOrigin = caster:GetAbsOrigin(),
								fDistance = travel_distance,
								fStartRadius = spikes_radius,
								fEndRadius = spikes_radius,
								Source = caster,
								bHasFrontalCone = false,
								bReplaceExisting = false,
								iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,                          
								iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,                           
								bDeleteOnHit = false,
								vVelocity = direction * spike_speed * Vector(1, 1, 0),
								bProvidesVision = false,
								ExtraData = {},
							}
							
	ProjectileManager:CreateLinearProjectile(spikes_projectile)
end

function ability_custom_lion_impale:OnProjectileHit_ExtraData(target, location, extra_data)
	if not IsServer() then return end
	
	if IsNull(target) then
		return nil
	end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
	local ability = self
	local sound_impact = "Hero_Lion.ImpaleHitTarget"
	local particle_hit = "particles/units/heroes/hero_lion/lion_spell_impale_hit_spikes.vpcf"  
	local knock_up_height = 350
	local knock_up_time = 0.5

	local damage = ability:GetSpecialValueFor("damage")
	local stun_duration = ability:GetSpecialValueFor("stun_duration")

	local target_position = target:GetAbsOrigin()
	target_position.z = 0

	local particle_hit_fx = ParticleManager:CreateParticle(particle_hit, PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(particle_hit_fx, 0, target_position)
	ParticleManager:SetParticleControl(particle_hit_fx, 1, target_position)
	ParticleManager:SetParticleControl(particle_hit_fx, 2, target_position)
	ParticleManager:ReleaseParticleIndex(particle_hit_fx)

	caster:EmitSound(sound_impact)

	if target:TriggerSpellAbsorb(self) then
		return nil
	end

	target:AddNewModifier(caster, nil, "modifier_stunned", {duration = stun_duration * (1 - target:GetStatusResistance())})
	local knockbackProperties = {
		center_x = location.x,
		center_y = location.y,
		center_z = location.z,
		duration = knock_up_time * (1 - target:GetStatusResistance()),
		knockback_duration = knock_up_time * (1 - target:GetStatusResistance()),
		knockback_distance = 0,
		knockback_height = knock_up_height
	}

	target:AddNewModifier(target, nil, "modifier_knockback", knockbackProperties)

	Timers:CreateTimer(knock_up_time, function()
		if IsNull(target) == false then
			local damageTable = {victim = target,
								 attacker = caster,
								 damage = damage,
								 damage_type = DAMAGE_TYPE_MAGICAL,
								 ability = self
								}

			ApplyDamage(damageTable)
		end
	end)
end
