ability_collection_unit = ability_collection_unit or class({})
LinkLuaModifier("modifier_ability_collection_unit", "abilities/ability_collection_unit", LUA_MODIFIER_MOTION_NONE)

function ability_collection_unit:GetIntrinsicModifierName()
	return "modifier_ability_collection_unit"
end

modifier_ability_supply_opened = modifier_ability_supply_opened or class({})
LinkLuaModifier("modifier_ability_supply_opened", "abilities/ability_collection_unit", LUA_MODIFIER_MOTION_NONE)

ability_supply_opened = ability_supply_opened or class({})
function ability_supply_opened:GetIntrinsicModifierName()
	return "modifier_ability_supply_opened"
end

function modifier_ability_supply_opened:CheckState()
	if IsServer() then
		local state = { 
			[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,
			[MODIFIER_STATE_UNSELECTABLE] = true,
			[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		}
		return state
	end
end

modifier_ability_collection_unit = modifier_ability_collection_unit or class({})

function modifier_ability_collection_unit:OnCreated()
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()

	if IsServer() then
		self.glow_enabled = false

		local unitName = self.caster:GetUnitName()
		if unitName ~= "npc_radar" and unitName ~= "npc_treasure_chest" then
			self:StartIntervalThink(0.5)
		end
	end
end

function modifier_ability_collection_unit:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_AVOID_DAMAGE
	}
end

function modifier_ability_collection_unit:OnIntervalThink()
	if IsServer() then
		if IsNull(self.caster) then return end
		local enemies = FindUnitsInRadius(
			self.caster:GetTeamNumber(),
			self.caster:GetAbsOrigin(),
			self.caster,
			1000,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS,
			0,
			true
		)

		if #enemies <= 0 and self.glow_enabled then
			ParticleManager:DestroyParticle(self.particle_glow_fx, false)
			ParticleManager:ReleaseParticleIndex(self.particle_glow_fx)
			self.glow_enabled = false
		elseif #enemies > 0 and self.glow_enabled == false then
			self.particle_glow_fx = ParticleManager:CreateParticle(ParticleRes.Collection, PATTACH_OVERHEAD_FOLLOW, self.caster)
			ParticleManager:SetParticleControl(self.particle_glow_fx, 0, self.caster:GetAbsOrigin())
			self.glow_enabled = true
		end
	end
end

function modifier_ability_collection_unit:GetModifierAvoidDamage()
    return 1
end

function modifier_ability_collection_unit:CheckState()
	if IsServer() then
		local state = {
			[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,
			[MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true,
			[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		}
		return state
	end
end

function modifier_ability_collection_unit:IsPurgable()
	return false
end

function modifier_ability_collection_unit:IsHidden()
	return true
end

function modifier_ability_collection_unit:IsDebuff()
	return false
end

function modifier_ability_collection_unit:OnDestroy()
	if self.particle_glow_fx then
		ParticleManager:DestroyParticle(self.particle_glow_fx, false)
		ParticleManager:ReleaseParticleIndex(self.particle_glow_fx)
	end
end