ability_custom_starstorm = ability_custom_starstorm or class({})

function ability_custom_starstorm:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
    local modifierParams = {
        duration = self:GetSpecialValueFor("duration"),
        radius = self:GetSpecialValueFor("radius"),
        damage = self:GetSpecialValueFor("damage")
    }
    caster:AddNewModifier(caster, nil, "modifier_ability_custom_starstorm_buff", modifierParams)

    local sound_cast = "Ability.Starfall"
    EmitSoundOn(sound_cast, caster)
end

LinkLuaModifier("modifier_ability_custom_starstorm_buff", "abilities/custom/ability_custom_starstorm", LUA_MODIFIER_MOTION_NONE)

modifier_ability_custom_starstorm_buff = modifier_ability_custom_starstorm_buff or class({})

function modifier_ability_custom_starstorm_buff:IsHidden() return false end
function modifier_ability_custom_starstorm_buff:IsDebuff() return false end
function modifier_ability_custom_starstorm_buff:IsPurgable() return false end
function modifier_ability_custom_starstorm_buff:RemoveOnDeath() return true end

function modifier_ability_custom_starstorm_buff:GetTexture()
    return "ability_custom_starstorm"
end

function modifier_ability_custom_starstorm_buff:GetEffectName()
    return "particles/units/heroes/hero_mirana/mirana_moonlight_owner.vpcf"
end

function modifier_ability_custom_starstorm_buff:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW 
end

function modifier_ability_custom_starstorm_buff:OnCreated(params)
    if not IsServer() then return end
    self.damage = params.damage or 200
    self.radius = params.radius or 800
    self:StartIntervalThink(1)
end

function modifier_ability_custom_starstorm_buff:OnIntervalThink()
	local particle_starfall = "particles/units/heroes/hero_mirana/mirana_starfall_attack.vpcf"
	local hit_delay = 0.25
	local sound_impact = "Ability.StarfallImpact"
    local caster = self:GetCaster()
    if IsNull(caster) then return end
    local position = caster:GetAbsOrigin()

	local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
        position,
		nil,
		self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
		FIND_ANY_ORDER,
		false)

    for _,enemy in pairs(enemies) do
        if NotNull(enemy) and not enemy:IsMagicImmune() then
            local particle_starfall_fx = ParticleManager:CreateParticle(particle_starfall, PATTACH_ABSORIGIN_FOLLOW, enemy)
            ParticleManager:SetParticleControl(particle_starfall_fx, 0, enemy:GetAbsOrigin())
            ParticleManager:SetParticleControl(particle_starfall_fx, 1, enemy:GetAbsOrigin())
            ParticleManager:SetParticleControl(particle_starfall_fx, 3, enemy:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(particle_starfall_fx)

            Timers:CreateTimer(hit_delay, function()
                if NotNull(enemy) and NotNull(caster) and not enemy:IsMagicImmune() then

                    EmitSoundOn(sound_impact, enemy)

                    local damageTable = {
                        victim = enemy,
                        damage = self.damage,
                        damage_type = DAMAGE_TYPE_MAGICAL,
                        attacker = caster,
                    }
                    ApplyDamage(damageTable)
                end
            end)
        end
    end
end