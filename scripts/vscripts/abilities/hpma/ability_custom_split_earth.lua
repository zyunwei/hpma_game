ability_custom_split_earth = ability_custom_split_earth or class({})

function ability_custom_split_earth:OnAbilityPhaseStart()
    return self:CheckPhaseStartWithMessage()
end

function ability_custom_split_earth:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function ability_custom_split_earth:OnSpellStart()
	if not self:CostCrystal() then
		return
	end

	local caster = self:GetCaster()
    if IsNull(caster) then
		return
	end

	local ability = self
	local target_point = self:GetCursorPosition()
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
