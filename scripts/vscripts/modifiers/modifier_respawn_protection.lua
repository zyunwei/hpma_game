modifier_respawn_protection = class({})

local public = modifier_respawn_protection

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
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_DISARMED] = true,
	}

	return state
end

function public:GetEffectName()
	return "particles/items_fx/black_king_bar_avatar.vpcf"
end

function public:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function public:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_AVOID_DAMAGE,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
	}
	return decFuncs
end

function public:GetModifierAvoidDamage()
	return 1
end

function public:GetModifierDamageOutgoing_Percentage(keys)
	return -100
end

function public:GetModifierMoveSpeed_Absolute()
    return 1000
end
