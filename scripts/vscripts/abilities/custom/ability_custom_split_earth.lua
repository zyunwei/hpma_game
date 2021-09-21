ability_custom_split_earth = ability_custom_split_earth or class({})

function ability_custom_split_earth:OnAbilityPhaseStart()
	return self:CheckPhaseStart()
end

function ability_custom_split_earth:OnSpellStart()
	return self:CheckSpellStart()
end

function ability_custom_split_earth:CastAbilityTarget(target)
	local caster = self:GetCaster()
	if IsNull(caster) or IsNull(target) then
		return
	end

	local ability = self
	local target_point = target:GetAbsOrigin()
	local cast_sound = "Hero_Leshrac.Split_Earth"
	local particle_spikes = "particles/units/heroes/hero_leshrac/leshrac_split_earth.vpcf"

	local radius = ability:GetSpecialValueFor("radius")
	local duration = ability:GetSpecialValueFor("duration")
	local damage = ability:GetSpecialValueFor("damage")

	GridNav:DestroyTreesAroundPoint(target_point, radius, true)

	EmitSoundOnLocationWithCaster(target_point, cast_sound, caster)

	local particle_spikes_fx = ParticleManager:CreateParticle(particle_spikes, PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(particle_spikes_fx, 0, target_point)
    ParticleManager:SetParticleControl(particle_spikes_fx, 1, Vector(radius, radius, radius))
	ParticleManager:ReleaseParticleIndex(particle_spikes_fx)

	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target_point, nil, radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_DAMAGE_FLAG_NONE, FIND_ANY_ORDER, false)

	for _, enemy in pairs(enemies) do
		if NotNull(enemy) and IsAlive(enemy) then
			enemy:AddNewModifier(caster, ability, "modifier_stunned", {duration = duration * (1 - enemy:GetStatusResistance())})

			local damageTable = { victim = enemy, attacker = caster, damage = damage,
				damage_type = ability:GetAbilityDamageType(), ability = ability
			}

			ApplyDamage(damageTable)
		end
	end
end
