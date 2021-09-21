ability_custom_lingboweibu = ability_custom_lingboweibu or class({})

function ability_custom_lingboweibu:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end

	local mainModifierName = "modifier_ability_custom_lingboweibu"

	if caster:HasModifier(mainModifierName) then
		caster:RemoveModifierByName(mainModifierName)
	end

	local modifierParams = {
		chance = self:GetSpecialValueFor("chance"),
		bonus_agi = self:GetSpecialValueFor("bonus_agi"),
		duration = self:GetSpecialValueFor("duration"),
        bonus_movement_speed_pct = self:GetSpecialValueFor("bonus_movement_speed_pct"),
	}

	local affixAttr = self:GetCaster():GetCustomAttribute("wind_agi")
    if affixAttr and affixAttr > 0 then
        modifierParams.bonus_agi = modifierParams.bonus_agi + affixAttr
    end

	caster:AddNewModifier(caster, nil, mainModifierName, modifierParams)
end

LinkLuaModifier("modifier_ability_custom_lingboweibu", "abilities/custom/ability_custom_lingboweibu", LUA_MODIFIER_MOTION_NONE)

modifier_ability_custom_lingboweibu = class({})

function modifier_ability_custom_lingboweibu:IsHidden() return false end
function modifier_ability_custom_lingboweibu:IsDebuff() return false end
function modifier_ability_custom_lingboweibu:IsPurgable() return false end
function modifier_ability_custom_lingboweibu:RemoveOnDeath() return true end

function modifier_ability_custom_lingboweibu:GetTexture()
	return "ability_custom_lingboweibu"
end


function modifier_ability_custom_lingboweibu:GetEffectName()
    return "particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf"
end

function modifier_ability_custom_lingboweibu:GetEffectAttachType()
    return PATTACH_CENTER_FOLLOW
end

function modifier_ability_custom_lingboweibu:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_ability_custom_lingboweibu:GetModifierBonusStats_Agility()
	return self.bonus_agi
end

function modifier_ability_custom_lingboweibu:OnCreated(params)
    self.chance = params.chance or 10
    self.bonus_agi = params.bonus_agi or 15
    self.bonus_movement_speed_pct = params.bonus_movement_speed_pct or 40
    if IsServer() then
		if NotNull(self:GetCaster()) then
			self:GetCaster():EmitSound("Ability.Windrun")
		end
    end
end

function modifier_ability_custom_lingboweibu:GetModifierIncomingDamage_Percentage()
    if not IsServer() then return end
	local caster = self:GetParent()
	if IsNull(caster) then return end
    if RollPercentage(self.chance) then
        local backtrack_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_backtrack.vpcf", PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(backtrack_fx, 0, caster:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(backtrack_fx)
        return -100
    end
end

function modifier_ability_custom_lingboweibu:OnDestroy()
	if not IsServer() then return end
	if NotNull(self:GetCaster()) then
		self:GetCaster():StopSound("Ability.Windrun")
	end
end

function modifier_ability_custom_lingboweibu:GetModifierMoveSpeedBonus_Percentage()
    return self.bonus_movement_speed_pct
end
