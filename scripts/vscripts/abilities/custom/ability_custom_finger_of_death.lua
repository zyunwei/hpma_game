ability_custom_finger_of_death = ability_custom_finger_of_death or class({})

function ability_custom_finger_of_death:OnAbilityPhaseStart()
    return self:CheckPhaseStart()
end

function ability_custom_finger_of_death:OnSpellStart()
    return self:CheckSpellStart()
end

function ability_custom_finger_of_death:CastAbilityTarget(target)
    if target == nil or IsNull(target) then return end

    self.damage_rate = self:GetSpecialValueFor("damage_rate")
    self.base_damage = self:GetSpecialValueFor("base_damage")
    local caster = self:GetCaster()
    if IsNull(caster) then return end

    local modifier = caster:FindModifierByName("modifier_moyejianxinfa")

    local sound_cast = "Hero_Lion.FingerOfDeath"
    EmitSoundOn(sound_cast, caster)

    if NotNull(modifier) then
        local radius = modifier:GetFingerOfDeathRadius()
        local enemies = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, 
        DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO , DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES, FIND_CLOSEST, false)
        for _, enemy in ipairs(enemies) do
            self:TakeEffect(enemy)
        end
    else
        self:TakeEffect(target)
    end
end

function ability_custom_finger_of_death:TakeEffect(target)
    local caster = self:GetCaster()
    if IsNull(target) or IsNull(caster) then return end

    local particle_finger = "particles/units/heroes/hero_lion/lion_spell_finger_of_death.vpcf"
    local particle_finger_fx = ParticleManager:CreateParticle(particle_finger, PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(particle_finger_fx, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_attack2", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(particle_finger_fx, 1, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_finger_fx, 2, target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle_finger_fx)

    Timers:CreateTimer(0.25, function()
        if IsNull(target) or IsNull(caster) or IsNull(self) then return end
        local sound_impact = "Hero_Lion.FingerOfDeathImpact"
        local damage = target:GetMaxHealth() * self.damage_rate / 100 + self.base_damage
        local damageTable = {
            victim = target,
			attacker = caster,
			damage = damage,
			damage_type = self:GetAbilityDamageType(),
        }

        EmitSoundOn(sound_impact, target)

        local affixAttr = self:GetCaster():GetCustomAttribute("finger_death")
        if affixAttr and affixAttr > 0 then
            damageTable.damage = damageTable.damage * (1 + affixAttr * 0.01)
        end
        
        ApplyDamage(damageTable)
    end)
end
