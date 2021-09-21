ability_npc_unit = ability_npc_unit or class({})
LinkLuaModifier("modifier_npc_unit", "abilities/ability_npc_unit", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_npc_hero_touching", "abilities/ability_npc_unit", LUA_MODIFIER_MOTION_NONE)

function ability_npc_unit:GetIntrinsicModifierName()
	return "modifier_npc_unit"
end

modifier_npc_unit = class({})

--------------------------------------------------------------------------------

function modifier_npc_unit:IsDebuff()
	return false
end

--------------------------------------------------------------------------------

function modifier_npc_unit:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_npc_unit:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_npc_unit:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_npc_unit:GetModifierAura()
	return "modifier_npc_hero_touching"
end

--------------------------------------------------------------------------------

function modifier_npc_unit:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_BOTH
end

--------------------------------------------------------------------------------

function modifier_npc_unit:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

--------------------------------------------------------------------------------

function modifier_npc_unit:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS
end

--------------------------------------------------------------------------------

function modifier_npc_unit:GetAuraRadius()
	return 150
end

function modifier_npc_unit:OnCreated()
	if IsServer() then
		local parent = self:GetParent()
		if IsNull(parent) == false then
			local parentPos = parent:GetAbsOrigin()
			local particlePos = parentPos + Vector(0, 0, 200)
			self.arrow_particle_index = ParticleManager:CreateParticle(ParticleRes.NpcArrow, PATTACH_ABSORIGIN_FOLLOW, parent)
			ParticleManager:SetParticleControl(self.arrow_particle_index, 0, particlePos)
		end
	end
end

function modifier_npc_unit:OnDestroy()
	if IsServer() then
		if self.arrow_particle_index then
			ParticleManager:DestroyParticle(self.arrow_particle_index, false)
			ParticleManager:ReleaseParticleIndex(self.arrow_particle_index)
		end
	end
end

--------------------------------------------------------------------------------

function modifier_npc_unit:GetAuraEntityReject( hEntity )
	if IsServer() then
		if not hEntity:IsHero() then return true end

		if self:GetParent() == hEntity then
			return true
		end
	end

	return false
end

function modifier_npc_unit:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_AVOID_DAMAGE
	}
end

function modifier_npc_unit:GetModifierAvoidDamage()
    return 1
end     

--------------------------------------------------------------------------------

function modifier_npc_unit:CheckState()
	return {
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}
end

--------------------------------------------------------------------------------


modifier_npc_hero_touching = modifier_npc_hero_touching or class({})

--------------------------------------------------------------------------------

function modifier_npc_hero_touching:IsDebuff()
	return false
end

--------------------------------------------------------------------------------

function modifier_npc_hero_touching:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_npc_hero_touching:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
function modifier_npc_hero_touching:OnDestroy(keys)
	if IsServer() then
		if IsNull(self) then
			return
		end

		local npc = self:GetCaster()
		local hero = self:GetParent()

		if IsNull(npc) or IsNull(hero) then
			return
		end

		CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "xxwar_touch_npc_close", {unit=npc:GetEntityIndex()})
	end
end
