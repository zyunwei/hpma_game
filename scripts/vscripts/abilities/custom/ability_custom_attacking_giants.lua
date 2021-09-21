ability_custom_attacking_giants = ability_custom_attacking_giants or class({})

function ability_custom_attacking_giants:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end

	local mainModifierName = "modifier_ability_custom_attacking_giants"

	if caster:HasModifier(mainModifierName) then
		caster:RemoveModifierByName(mainModifierName)
	end

	local modifierParams = {
		stun_duration = self:GetSpecialValueFor("stun_duration"),
		damage_str_multiple = self:GetSpecialValueFor("damage_str_multiple"),
		duration = self:GetSpecialValueFor("duration"),
        radius = self:GetSpecialValueFor("radius"),
        model_scale = self:GetSpecialValueFor("model_scale"),
        bonus_str = self:GetSpecialValueFor("bonus_str"),
        bonus_move_speed = self:GetSpecialValueFor("bonus_move_speed"),
	}

	caster:AddNewModifier(caster, nil, mainModifierName, modifierParams)
end

LinkLuaModifier("modifier_ability_custom_attacking_giants", "abilities/custom/ability_custom_attacking_giants", LUA_MODIFIER_MOTION_NONE)

modifier_ability_custom_attacking_giants = class({})

function modifier_ability_custom_attacking_giants:IsHidden() return false end
function modifier_ability_custom_attacking_giants:IsDebuff() return false end
function modifier_ability_custom_attacking_giants:IsPurgable() return false end
function modifier_ability_custom_attacking_giants:RemoveOnDeath() return true end

function modifier_ability_custom_attacking_giants:GetTexture()
	return "ability_custom_attacking_giants"
end

function modifier_ability_custom_attacking_giants:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MODEL_SCALE,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
	}
end

function modifier_ability_custom_attacking_giants:OnCreated(params)
    if not IsServer() then return end
    self.stun_duration = params.stun_duration or 2
    self.damage_str_multiple = params.damage_str_multiple or 50
    self.radius = params.radius or 400
    self.model_scale = params.model_scale or 60
    self.bonus_str = params.bonus_str or 40
    self.bonus_move_speed = params.bonus_move_speed or 60
    self.effect_enemy = {}
    self:StartIntervalThink(0.5)
end

function modifier_ability_custom_attacking_giants:GetModifierModelScale()
    return self.model_scale
end

function modifier_ability_custom_attacking_giants:OnIntervalThink()
    if not IsServer() then return end
    if IsNull(self:GetParent()) or IsNull(self:GetCaster()) then return end
    local damage = self:GetCaster():GetStrength() * self.damage_str_multiple
    local nearby_enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(),
        nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES, FIND_ANY_ORDER, false)
    for _, enemy in pairs(nearby_enemies) do
        if NotNull(enemy) and not table.contains(self.effect_enemy, enemy:entindex()) then
            ApplyDamage({victim = enemy, attacker = self:GetCaster(), ability = nil, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
            enemy:AddNewModifier( self:GetCaster(), self, "modifier_stunned", { duration = self.stun_duration * (1 - enemy:GetStatusResistance()) } )
            local direction = (enemy:GetOrigin() - self:GetParent():GetOrigin()):Normalized() 
            local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_mars/mars_shield_bash_crit.vpcf", PATTACH_WORLDORIGIN, nil )
            ParticleManager:SetParticleControl( effect_cast, 0, enemy:GetOrigin() )
            ParticleManager:SetParticleControl( effect_cast, 1, enemy:GetOrigin() )
            ParticleManager:SetParticleControlForward( effect_cast, 1, direction )
            ParticleManager:ReleaseParticleIndex( effect_cast )
            EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), "Hero_Mars.Shield.Cast", self:GetCaster() )
            table.insert(self.effect_enemy, enemy:entindex())
        end
    end

end

function modifier_ability_custom_attacking_giants:GetModifierBonusStats_Strength()
    return self.bonus_str
end

function modifier_ability_custom_attacking_giants:GetModifierMoveSpeedBonus_Constant()
    return self.bonus_move_speed
end

function modifier_ability_custom_attacking_giants:CheckState()
    return {[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
end