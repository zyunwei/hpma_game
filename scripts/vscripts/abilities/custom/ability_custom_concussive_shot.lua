ability_custom_concussive_shot = ability_custom_concussive_shot or class({})

function ability_custom_concussive_shot:OnSpellStart()
	local caster = self:GetCaster()
	if IsNull(caster) then
		return
	end
	local ability = self
	local sound_cast = "Hero_SkywrathMage.ConcussiveShot.Cast"
	local search_radius = ability:GetSpecialValueFor("search_radius")

	EmitSoundOn(sound_cast, caster)

	local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
										caster:GetAbsOrigin(),
										nil,
										search_radius,
										DOTA_UNIT_TARGET_TEAM_ENEMY,
										DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
										DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,
										FIND_CLOSEST,
										false)

	for _, enemy in pairs(enemies) do
		if NotNull(enemy) and IsAlive(enemy) then
			self:LaunchConcussiveShot(caster, enemy)
		end
	end
end

function ability_custom_concussive_shot:LaunchConcussiveShot(caster, target)
	local particle_projectile = "particles/units/heroes/hero_skywrath_mage/skywrath_mage_concussive_shot.vpcf"
	local concussive_projectile = {Target = target,
									Source = caster,
									Ability = self,
									EffectName = particle_projectile,
									iMoveSpeed = 800,
									bDodgeable = true, 
									bVisibleToEnemies = true,
									bReplaceExisting = false,
									bProvidesVision = true,
									iVisionRadius = 300,
									iVisionTeamNumber = caster:GetTeamNumber(),
									ExtraData = {}
	}

	ProjectileManager:CreateTrackingProjectile(concussive_projectile)  
end

function ability_custom_concussive_shot:OnProjectileHit_ExtraData(target, location, extra_data)
	if not IsServer() then return end

	local ability = self
	local caster = self:GetCaster()

	if IsNull(target) or IsNull(ability) or IsNull(caster) then
		return
	end
	
	local sound_impact = "Hero_SkywrathMage.ConcussiveShot.Target"
	EmitSoundOn(sound_impact, target)

    local damage = caster:GetIntellect() * ability:GetSpecialValueFor("damage_int") + ability:GetSpecialValueFor("base_damage")
    local damageTable = {
        victim = target,
        attacker = caster,
        damage = damage,
        damage_type = ability:GetAbilityDamageType(),
        ability = ability,
    }

    ApplyDamage(damageTable)
end
