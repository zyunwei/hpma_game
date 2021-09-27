ability_custom_shadow_word = ability_custom_shadow_word or class({})
LinkLuaModifier("modifier_custom_shadow_word", "abilities/hpma/ability_custom_shadow_word", LUA_MODIFIER_MOTION_NONE)

function ability_custom_shadow_word:OnAbilityPhaseStart()
    return self:CheckPhaseStartWithMessage()
end

function ability_custom_shadow_word:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function ability_custom_shadow_word:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local target_point = self:GetCursorPosition()
	local sound_target = "Hero_Warlock.ShadowWord"
	local particle_aoe = "particles/hero/warlock/warlock_shadow_word_aoe_a.vpcf"
	local modifier_word = "modifier_custom_shadow_word"
	local radius = ability:GetSpecialValueFor("radius")
	local duration = ability:GetSpecialValueFor("duration")

	EmitSoundOn(sound_target, caster)

	local particle_aoe_fx = ParticleManager:CreateParticle(particle_aoe, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(particle_aoe_fx, 0, target_point)
	ParticleManager:SetParticleControl(particle_aoe_fx, 1, Vector(radius, 0, 0))
	ParticleManager:SetParticleControl(particle_aoe_fx, 2, target_point)
	ParticleManager:ReleaseParticleIndex(particle_aoe_fx)

	local units = FindUnitsInRadius(caster:GetTeamNumber(),
		target_point,
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_BOTH,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false)

	for _, unit in pairs(units) do
		unit:AddNewModifier(caster, ability, modifier_word, {duration = duration})
	end

	Timers:CreateTimer(duration, function()
		StopSoundOn(sound_target, caster)
	end)
end

modifier_custom_shadow_word = class({})

function modifier_custom_shadow_word:OnCreated()
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.parent = self:GetParent()
	self.sound_good = "Hero_Warlock.ShadowWordCastGood"
	self.sound_bad = "Hero_Warlock.ShadowWordCastBad"
	self.particle_good = "particles/units/heroes/hero_warlock/warlock_shadow_word_buff.vpcf"
	self.particle_bad = "particles/units/heroes/hero_warlock/warlock_shadow_word_debuff.vpcf"
	
	if not self.ability then return end

	self.tick_value = self.ability:GetSpecialValueFor("tick_value")
	self.tick_interval = self.ability:GetSpecialValueFor("tick_interval")

	if self.parent:GetTeamNumber() == self.caster:GetTeamNumber() then
		self.good_guy = true
	else
		self.good_guy = false
	end

	if IsServer() then
		if self.good_guy then
			EmitSoundOn(self.sound_good, self.parent)
		else
			EmitSoundOn(self.sound_bad, self.parent)
		end

		if self.good_guy then
			self.particle_good_fx = ParticleManager:CreateParticle(self.particle_good, PATTACH_ABSORIGIN_FOLLOW, self.parent)
			ParticleManager:SetParticleControl(self.particle_good_fx, 0, self.parent:GetAbsOrigin())
			ParticleManager:SetParticleControl(self.particle_good_fx, 2, self.parent:GetAbsOrigin())
			self:AddParticle(self.particle_good_fx, false, false, -1, false, false)
		else
			self.particle_bad_fx = ParticleManager:CreateParticle(self.particle_bad, PATTACH_ABSORIGIN_FOLLOW, self.parent)
			ParticleManager:SetParticleControl(self.particle_bad_fx, 0, self.parent:GetAbsOrigin())
			ParticleManager:SetParticleControl(self.particle_bad_fx, 2, self.parent:GetAbsOrigin())
			self:AddParticle(self.particle_bad_fx, false, false, -1, false, false)
		end

		self:StartIntervalThink(self.tick_interval)
	end
end

function modifier_custom_shadow_word:IsHidden() return false end
function modifier_custom_shadow_word:IsPurgable() return true end
function modifier_custom_shadow_word:IgnoreTenacity()	return true end


function modifier_custom_shadow_word:IsDebuff()
	if self.good_guy then
		return false
	end

	return true
end

function modifier_custom_shadow_word:OnIntervalThink()
	if self.good_guy then
		self.parent:Heal(self.tick_value, self.caster)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, self.parent, self.tick_value, nil)
	else
		local damageTable = {victim = self.parent,
			attacker = self.caster,
			damage = self.tick_value,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self.ability
		}

		ApplyDamage(damageTable)
	end
end

function modifier_custom_shadow_word:OnDestroy()
	-- Stop the appropriate sound event
	if self.good_guy then
		StopSoundOn(self.sound_good, self.parent)
	else
		StopSoundOn(self.sound_bad, self.parent)
	end
end
