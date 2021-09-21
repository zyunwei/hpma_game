ability_custom_superior_intelligence = ability_custom_superior_intelligence or class({})

function ability_custom_superior_intelligence:OnAbilityPhaseStart()
    return self:CheckPhaseStart()
end

function ability_custom_superior_intelligence:OnSpellStart()
    return self:CheckSpellStart()
end

function ability_custom_superior_intelligence:CastAbilityTarget(target, params)
	if not IsServer() then return end

	local caster = self:GetCaster()
    if IsNull(caster) or IsNull(target) then return end
    local int_damage_multiple = self:GetSpecialValueFor("int_damage_multiple")
    local radius = self:GetSpecialValueFor("radius")
    local position = target:GetAbsOrigin()
    local int = caster:GetIntellect()
    local damage = int * int_damage_multiple
    local damage_type = self:GetAbilityDamageType()
    EmitSoundOn("Hero_ObsidianDestroyer.SanityEclipse.Cast", caster)
    EmitSoundOnLocationWithCaster(position, "Hero_ObsidianDestroyer.SanityEclipse", target)

    local particle_area_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_sanity_eclipse_area.vpcf", PATTACH_WORLDORIGIN, target)
	ParticleManager:SetParticleControl(particle_area_fx, 0, position)
	ParticleManager:SetParticleControl(particle_area_fx, 1, Vector(radius, 1, 1))
	ParticleManager:SetParticleControl(particle_area_fx, 2, Vector(radius, 1, 1))
	ParticleManager:SetParticleControl(particle_area_fx, 3, position)
	ParticleManager:ReleaseParticleIndex(particle_area_fx)

	local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        position,
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        FIND_ANY_ORDER,
        false
    )

    for _, enemy in pairs(enemies) do
        if NotNull(enemy) and not enemy:IsMagicImmune() then
            local enemyInt = 0
            local realDamage = damage
            local isRealHero = enemy.IsRealHero ~= nil and enemy:IsRealHero()
            if not isRealHero then
                realDamage = damage / 2
            end

            if isRealHero then
                enemyInt = enemy:GetIntellect()
            end

            if enemyInt < int then
                local particle_damage_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_sanity_eclipse_damage.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
                ParticleManager:SetParticleControl(particle_damage_fx, 0, enemy:GetAbsOrigin())
                ParticleManager:ReleaseParticleIndex(particle_damage_fx)
                ApplyDamage({
                    victim = enemy,
                    attacker = caster,
                    damage_type = damage_type,
                    damage = realDamage
                })
            end
        end
    end
end
