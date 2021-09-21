ability_custom_refraction = ability_custom_refraction or class({})

LinkLuaModifier("modifier_ability_custom_refraction", "abilities/custom/ability_custom_refraction", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_custom_refraction_damage", "abilities/custom/ability_custom_refraction", LUA_MODIFIER_MOTION_NONE)

function ability_custom_refraction:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster)  then return end

	local modifierParams = {
		instances = self:GetSpecialValueFor("instances"),
		duration = self:GetSpecialValueFor("duration"),
		bonus_damage = self:GetSpecialValueFor("bonus_damage"),
	}

    local affixAttr = self:GetCaster():GetCustomAttribute("refraction")
    if affixAttr and affixAttr > 0 then
        modifierParams.instances = modifierParams.instances + affixAttr
    end

	local modifiers = {"modifier_ability_custom_refraction", "modifier_ability_custom_refraction_damage"}
	for _, modifierName in pairs(modifiers) do
		if caster:HasModifier(modifierName) then
			caster:RemoveModifierByName(modifierName)
		end
		caster:AddNewModifier(caster, nil, modifierName, modifierParams)
	end

	caster:EmitSound("Hero_TemplarAssassin.Refraction")
end

modifier_ability_custom_refraction = class({})
function modifier_ability_custom_refraction:IsHidden() return false end
function modifier_ability_custom_refraction:IsDebuff() return false end
function modifier_ability_custom_refraction:IsPurgable() return false end
function modifier_ability_custom_refraction:RemoveOnDeath() return true end
function modifier_ability_custom_refraction:GetTexture()
    return "ability_custom_refraction"
end
function modifier_ability_custom_refraction:GetPriority()
	return MODIFIER_PRIORITY_ULTRA
end

function modifier_ability_custom_refraction:OnCreated(params)
	if not IsServer() then return end
	if IsNull(self:GetParent()) then return end

	if self.refraction_particle then
		ParticleManager:DestroyParticle(self.refraction_particle, false)
		ParticleManager:ReleaseParticleIndex(self.refraction_particle)
	end

	self.refraction_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_refraction.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(self.refraction_particle, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	self:AddParticle(self.refraction_particle, false, false, -1, true, false)
	self.damage_threshold = 5

	self:SetStackCount(params.instances)
end

function modifier_ability_custom_refraction:OnStackCountChanged()
	if self:GetStackCount() <= 0 then
		self:Destroy()
	end
end

function modifier_ability_custom_refraction:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}
end

function modifier_ability_custom_refraction:GetModifierIncomingDamage_Percentage(keys)
	if IsNull(self:GetParent()) then return end
	if NotNull(keys.attacker) and keys.damage and keys.damage >= self.damage_threshold and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS then
		self:GetParent():EmitSound("Hero_TemplarAssassin.Refraction.Absorb")

		local warp_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_refract_plasma_contact_warp.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:ReleaseParticleIndex(warp_particle)

		local hit_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_refract_hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(hit_particle, 2, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(hit_particle)

		self:DecrementStackCount()
		return -100
	end
end

modifier_ability_custom_refraction_damage = class({})
function modifier_ability_custom_refraction_damage:IsHidden() return false end
function modifier_ability_custom_refraction_damage:IsDebuff() return false end
function modifier_ability_custom_refraction_damage:IsPurgable() return false end
function modifier_ability_custom_refraction_damage:RemoveOnDeath() return true end
function modifier_ability_custom_refraction_damage:GetTexture()
    return "ability_custom_refraction"
end

function modifier_ability_custom_refraction_damage:OnCreated(params)
	if not IsServer() then return end

	if IsNull(self:GetParent()) then return end

	if self.damage_particle then
		ParticleManager:DestroyParticle(self.damage_particle, false)
		ParticleManager:ReleaseParticleIndex(self.damage_particle)
	end

	self.damage_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_refraction_dmg.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(self.damage_particle, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.damage_particle, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetParent():GetAbsOrigin(), true)
	self:AddParticle(self.damage_particle, false, false, -1, true, false)

	self.bonus_damage = params.bonus_damage
	self:SetStackCount(params.instances)
end

function modifier_ability_custom_refraction_damage:OnStackCountChanged()
	if self:GetStackCount() <= 0 then
		self:Destroy()
	end
end

function modifier_ability_custom_refraction_damage:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_ability_custom_refraction_damage:GetModifierPreAttack_BonusDamage()
	return self.bonus_damage
end

function modifier_ability_custom_refraction_damage:OnAttackLanded(keys)
	if IsNull(keys.attacker) or IsNull(keys.target) or IsNull(self:GetParent()) then return end
	if keys.attacker == self:GetParent() and keys.target:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
		keys.target:EmitSound("Hero_TemplarAssassin.Refraction.Damage")
		self:DecrementStackCount()
	end
end
