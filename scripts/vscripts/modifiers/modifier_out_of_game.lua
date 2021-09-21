modifier_out_of_game = class({})

local public = modifier_out_of_game

function public:IsDebuff()
	return false
end

function public:IsHidden()
	return true
end

function public:IsPurgable()
	return false
end

function public:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_DISARMED] = true,
	}

	return state
end

function public:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BONUS_DAY_VISION,
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
	}
	return funcs
end

function public:GetBonusDayVision()
	return -100000
end

function public:GetBonusNightVision()
	return -100000
end

function public:OnCreated()
	if IsServer() then
		self:GetParent():AddNoDraw()
	end
end

function public:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveNoDraw()
	end
end
