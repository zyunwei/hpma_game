ability_npc_teleport = ability_npc_teleport or class({})
LinkLuaModifier("modifier_npc_teleport", "abilities/ability_npc_teleport", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_teleport_hero_touching", "abilities/ability_npc_teleport", LUA_MODIFIER_MOTION_NONE)

function ability_npc_teleport:GetIntrinsicModifierName()
	return "modifier_npc_teleport"
end

modifier_npc_teleport = class({})

--------------------------------------------------------------------------------

function modifier_npc_teleport:IsDebuff()
	return false
end

--------------------------------------------------------------------------------

function modifier_npc_teleport:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_npc_teleport:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_npc_teleport:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_npc_teleport:GetModifierAura()
	return "modifier_teleport_hero_touching"
end

--------------------------------------------------------------------------------

function modifier_npc_teleport:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_BOTH
end

--------------------------------------------------------------------------------

function modifier_npc_teleport:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

--------------------------------------------------------------------------------

function modifier_npc_teleport:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS
end

--------------------------------------------------------------------------------

function modifier_npc_teleport:GetAuraRadius()
	return 150
end

--------------------------------------------------------------------------------

function modifier_npc_teleport:GetAuraEntityReject( hEntity )
	if IsServer() then
		if not hEntity:IsHero() then return true end

		if self:GetParent() == hEntity then
			return true
		end
	end

	return false
end

function modifier_npc_teleport:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_AVOID_DAMAGE
	}
end

function modifier_npc_teleport:GetModifierAvoidDamage()
    return 1
end

--------------------------------------------------------------------------------

function modifier_npc_teleport:CheckState()
	return {
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}
end

--------------------------------------------------------------------------------


modifier_teleport_hero_touching = modifier_teleport_hero_touching or class({})

--------------------------------------------------------------------------------

function modifier_teleport_hero_touching:IsDebuff()
	return false
end

--------------------------------------------------------------------------------

function modifier_teleport_hero_touching:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_teleport_hero_touching:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_teleport_hero_touching:OnDestroy(keys)
	if IsServer() then
		if IsNull(self) then
			return
		end

		local npc = self:GetCaster()
		local hero = self:GetParent()

		if IsNull(npc) or IsNull(hero) then
			return
		end

		CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "xxwar_close_teleport", {unit=npc:GetEntityIndex()})
	end
end
