ability_custom_breathe_fire = ability_custom_breathe_fire or {}

function ability_custom_breathe_fire:OnAbilityPhaseStart()
	return self:CheckPhaseStart()
end

function ability_custom_breathe_fire:OnSpellStart()
	return self:CheckSpellStart()
end

function ability_custom_breathe_fire:CastAbilityTarget(target)
	local caster = self:GetCaster()
	if IsNull(caster) or IsNull(target) then
		return
	end

	local target_point = target:GetAbsOrigin()
	local speed = self:GetSpecialValueFor("speed")

	EmitSoundOn("Hero_DragonKnight.BreathFire", caster)

	local projectile = {
		Ability = self,
		EffectName = "particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		fDistance = self:GetSpecialValueFor("range"),
		fStartRadius = self:GetSpecialValueFor("start_radius"),
		fEndRadius = self:GetSpecialValueFor("end_radius"),
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,							
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,							
		bDeleteOnHit = false,
		vVelocity = (((target_point - caster:GetAbsOrigin()) * Vector(1, 1, 0)):Normalized()) * speed,
		bProvidesVision = false,							
	}

	ProjectileManager:CreateLinearProjectile(projectile)
end

function ability_custom_breathe_fire:OnProjectileHit(target, location)
	if not IsServer() then return end
	local caster = self:GetCaster()
	if IsNull(target) or IsNull(caster) then return end

	local damage = self:GetSpecialValueFor("damage")

	ApplyDamage({victim = target, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, attacker = caster, ability = self})
end
