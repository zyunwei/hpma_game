ability_custom_kuihuabaodian = ability_custom_kuihuabaodian or class({})

function ability_custom_kuihuabaodian:OnAbilityPhaseStart()
	return self:CheckPhaseStart()
end

function ability_custom_kuihuabaodian:OnSpellStart()
	return self:CheckSpellStart()
end

function ability_custom_kuihuabaodian:CastAbilityTarget(target)
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end

	local mainModifierName = "modifier_ability_custom_kuihuabaodian"

	if caster:HasModifier(mainModifierName) then
		caster:RemoveModifierByName(mainModifierName)
	end

	local modifierParams = {
		crit_chance = self:GetSpecialValueFor("crit_chance"),
		crit_mult = self:GetSpecialValueFor("crit_mult"),
		duration = self:GetSpecialValueFor("duration")
	}

	local affixAttr = self:GetCaster():GetCustomAttribute("kuihua")
    if affixAttr and affixAttr > 0 then
    	modifierParams.crit_chance = modifierParams.crit_chance + affixAttr
    end

	caster:AddNewModifier(caster, nil, mainModifierName, modifierParams)
end

LinkLuaModifier("modifier_ability_custom_kuihuabaodian", "abilities/custom/ability_custom_kuihuabaodian", LUA_MODIFIER_MOTION_NONE)

modifier_ability_custom_kuihuabaodian = class({})

function modifier_ability_custom_kuihuabaodian:IsHidden() return false end
function modifier_ability_custom_kuihuabaodian:IsDebuff() return false end
function modifier_ability_custom_kuihuabaodian:IsPurgable() return false end
function modifier_ability_custom_kuihuabaodian:RemoveOnDeath() return true end

function modifier_ability_custom_kuihuabaodian:GetTexture()
	return "ability_custom_kuihuabaodian"
end

function modifier_ability_custom_kuihuabaodian:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_ability_custom_kuihuabaodian:OnCreated(params)
    self.crit_chance = 50
    self.crit_mult = 400
    if IsServer() then
    	if params then
    		self.crit_chance = params.crit_chance or self.crit_chance
    		self.crit_mult = params.crit_mult or self.crit_mult
    	end
    end
end

if IsServer() then
	function modifier_ability_custom_kuihuabaodian:GetModifierPreAttack_CriticalStrike(keys)
		if IsNull(keys.attacker) or IsNull(self:GetParent()) then return end
		if keys.attacker == self:GetParent() then
			self.critProc = false
			if RollPseudoRandomPercentage(self.crit_chance, 102, keys.attacker) then
				-- self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_EVENT, self:GetParent():GetSecondsPerAttack())
				local crit_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/jugg_crit_blur.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())

				ParticleManager:SetParticleControl(crit_pfx, 0, self:GetParent():GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(crit_pfx)

				self.critProc = true

				return self.crit_mult
			end
		end
	end

	function modifier_ability_custom_kuihuabaodian:OnAttackLanded(params)
		if IsNull(params.attacker) or IsNull(self:GetParent()) or IsNull(params.target) then return end
		if params.attacker == self:GetParent() then
			if self.critProc == true then
				local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_crit_tgt.vpcf", PATTACH_ABSORIGIN, params.target)
				ParticleManager:SetParticleControl(particle, 0, params.target:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(particle)

				self.critProc = false
			end
		end
	end
end
