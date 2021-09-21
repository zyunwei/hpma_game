
modifier_aghanim_passive = class({})

-----------------------------------------------------------------------------------------

function modifier_aghanim_passive:IsHidden()
	return true
end

-----------------------------------------------------------------------------------------

function modifier_aghanim_passive:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_aghanim_passive:GetPriority()
	return MODIFIER_PRIORITY_ULTRA + 10000
end

-----------------------------------------------------------------------------------------

function modifier_aghanim_passive:CheckState()
	local state =
	{
		[MODIFIER_STATE_HEXED] = false,
		[MODIFIER_STATE_ROOTED] = false,
		[MODIFIER_STATE_SILENCED] = false,
		[MODIFIER_STATE_STUNNED] = false,
		[MODIFIER_STATE_FROZEN] = false,
		[MODIFIER_STATE_FEARED] = false,
		[MODIFIER_STATE_CANNOT_BE_MOTION_CONTROLLED] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	}
	
	return state
end

--------------------------------------------------------------------------------

function modifier_aghanim_passive:OnCreated( kv )
	self.status_resist = self:GetAbility():GetSpecialValueFor( "status_resist" )
end

--------------------------------------------------------------------------------

function modifier_aghanim_passive:OnRefresh( kv )
	self.status_resist = self:GetAbility():GetSpecialValueFor( "status_resist" )
end

-----------------------------------------------------------------------------------------

function modifier_aghanim_passive:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MIN_HEALTH,
		MODIFIER_EVENT_ON_DEATH_PREVENTED,
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
	}
	return funcs
end

--------------------------------------------------------------------------------

function modifier_aghanim_passive:GetModifierStatusResistanceStacking( params )
	return self.status_resist 
end
