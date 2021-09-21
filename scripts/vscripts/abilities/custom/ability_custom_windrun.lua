ability_custom_windrun = ability_custom_windrun or class({})

function ability_custom_windrun:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end

	local mainModifierName = "modifier_ability_custom_windrun"

	if caster:HasModifier(mainModifierName) then
		caster:RemoveModifierByName(mainModifierName)
	end

	local modifierParams = {
		chance = self:GetSpecialValueFor("chance"),
		bonus_agi = self:GetSpecialValueFor("bonus_agi"),
		duration = self:GetSpecialValueFor("duration")
	}

	local affixAttr = self:GetCaster():GetCustomAttribute("wind_agi")
    if affixAttr and affixAttr > 0 then
        modifierParams.bonus_agi = modifierParams.bonus_agi + affixAttr
    end

	caster:AddNewModifier(caster, nil, mainModifierName, modifierParams)
end

function ability_custom_windrun:OnFold()
	local caster = self:GetCaster()
	if IsNull(caster)  then return end

	if caster:HasModifier("modifier_lingboweibuxinfa") then
		CardGroupSystem:ReplaceCard(caster:GetPlayerID(), "ability_custom_windrun", "ability_custom_lingboweibu", true)
	end
end

LinkLuaModifier("modifier_ability_custom_windrun", "abilities/custom/ability_custom_windrun", LUA_MODIFIER_MOTION_NONE)

modifier_ability_custom_windrun = class({})

function modifier_ability_custom_windrun:IsHidden() return false end
function modifier_ability_custom_windrun:IsDebuff() return false end
function modifier_ability_custom_windrun:IsPurgable() return false end
function modifier_ability_custom_windrun:RemoveOnDeath() return true end

function modifier_ability_custom_windrun:GetTexture()
	return "ability_custom_windrun"
end


function modifier_ability_custom_windrun:GetEffectName()
    return "particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf"
end

function modifier_ability_custom_windrun:GetEffectAttachType()
    return PATTACH_CENTER_FOLLOW
end

function modifier_ability_custom_windrun:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
end

function modifier_ability_custom_windrun:GetModifierBonusStats_Agility()
	return self.bonus_agi
end

function modifier_ability_custom_windrun:OnCreated(params)
    self.chance = params.chance or 10
    self.bonus_agi = params.bonus_agi or 15
    if IsServer() then
		if NotNull(self:GetCaster()) then
			self:GetCaster():EmitSound("Ability.Windrun")
		end
    end
end

function modifier_ability_custom_windrun:GetModifierIncomingDamage_Percentage()
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

function modifier_ability_custom_windrun:OnDestroy()
	if not IsServer() then return end
	if NotNull(self:GetCaster()) then
		self:GetCaster():StopSound("Ability.Windrun")
	end
end
