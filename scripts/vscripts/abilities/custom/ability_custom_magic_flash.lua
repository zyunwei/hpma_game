ability_custom_magic_flash = ability_custom_magic_flash or class({})

function ability_custom_magic_flash:OnAbilityPhaseStart()
    return self:CheckPhaseStart()
end

function ability_custom_magic_flash:OnSpellStart()
    return self:CheckSpellStart()
end

function ability_custom_magic_flash:CastAbilityTarget(target, params)
	if not IsServer() then return end

	local caster = self:GetCaster()
    if IsNull(target) or IsNull(caster) then return end

    EmitSoundOn("Hero_ObsidianDestroyer.ArcaneOrb", caster)

	local projectile_info = {
		Target = target,
		Source = caster,
		Ability = self,
        EffectName = "particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_arcane_orb.vpcf",
        iMoveSpeed = 600,
        bDodgeable = false,
        vSpawnOrigin = caster:GetAbsOrigin(),
        bHasFrontalCone = false,
        bVisibleToEnemies = true,
		bReplaceExisting = false,
        bProvidesVision = false,
    }

    ProjectileManager:CreateTrackingProjectile(projectile_info)
end

function ability_custom_magic_flash:OnProjectileHit(target, location)
    if not IsServer() then return end
	local caster = self:GetCaster()
    if IsNull(target) or IsNull(caster) then return end
    if target:IsMagicImmune() then return end
    local mana_damage_multiple = self:GetSpecialValueFor("mana_damage_multiple")
    local damage = caster:GetMaxMana() * mana_damage_multiple / 100
    local damage_type = self:GetAbilityDamageType()
    ApplyDamage({
        victim = target,
        attacker = caster,
        damage_type = damage_type,
        damage = damage
    })
    local particle_hit_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_arcane_orb_hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(particle_hit_fx, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_hit_fx, 1, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_hit_fx, 3, target:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle_hit_fx)
end