ability_npc_tombstone = ability_npc_tombstone or class({})
LinkLuaModifier("modifier_npc_tombstone", "abilities/ability_npc_tombstone", LUA_MODIFIER_MOTION_NONE)

function ability_npc_tombstone:GetIntrinsicModifierName()
	return "modifier_npc_tombstone"
end

modifier_npc_tombstone = class({})

--------------------------------------------------------------------------------

function modifier_npc_tombstone:IsDebuff()
	return false
end

--------------------------------------------------------------------------------

function modifier_npc_tombstone:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_npc_tombstone:IsPurgable()
	return false
end

function modifier_npc_tombstone:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_AVOID_DAMAGE
	}
end

function modifier_npc_tombstone:GetModifierAvoidDamage()
    return 1
end

--------------------------------------------------------------------------------

function modifier_npc_tombstone:CheckState()
	return {
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}
end
