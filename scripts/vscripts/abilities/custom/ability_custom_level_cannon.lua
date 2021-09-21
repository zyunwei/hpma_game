ability_custom_level_cannon = ability_custom_level_cannon or class({})

function ability_custom_level_cannon:OnAbilityPhaseStart()
    return self:CheckPhaseStart()
end

function ability_custom_level_cannon:OnSpellStart()
    return self:CheckSpellStart()
end

function ability_custom_level_cannon:CastAbilityTarget(target, params)
	if not IsServer() then return end

	local caster = self:GetCaster()
    if IsNull(caster) or IsNull(target) then return end
    local damage = self:GetSpecialValueFor("damage")
    local radius = self:GetSpecialValueFor("radius")
    local stun_duration = self:GetSpecialValueFor("stun_duration")
    local position = target:GetAbsOrigin()
    local damage_type = self:GetAbilityDamageType()

	local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        position,
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD,
        FIND_ANY_ORDER,
        false
    )

    for _, enemy in pairs(enemies) do
        if not enemy:IsMagicImmune() then
            if enemy.IsRealHero ~= nil and enemy:IsRealHero() and enemy:GetLevel() % 3 == 0 then
                damage = damage * 3
            end
            EmitSoundOn("Hero_DoomBringer.LvlDeath", caster)
            local particle_area_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_doom_bringer/doom_bringer_lvl_death.vpcf", PATTACH_WORLDORIGIN, target)
            ParticleManager:SetParticleControl(particle_area_fx, 0, enemy:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(particle_area_fx)
            Timers:CreateTimer(0.3, function()
                if NotNull(enemy) and enemy:IsAlive() then
                    ApplyDamage({
                        victim = enemy,
                        attacker = caster,
                        damage_type = damage_type,
                        damage = damage
                    })
                    enemy:AddNewModifier( self:GetCaster(), self, "modifier_stunned", { duration = stun_duration * (1 - enemy:GetStatusResistance()) } )
                end
            end
            )
        end
    end
end
