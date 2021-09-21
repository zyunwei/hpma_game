modifier_provides_vision = class({})

local public = modifier_provides_vision

function public:IsHidden()
	return true
end

function public:IsPurgable()
	return false
end

function public:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
	}

	return funcs
end

function public:GetModifierProvidesFOWVision()
	return 1
end

function public:CheckState()
	return {
		[MODIFIER_STATE_PROVIDES_VISION] = true
	}
end

function public:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime() * 3)
end

function public:OnIntervalThink()
	if not IsServer() then return end

	for teamId, _ in pairs(GameManager.StartPosList) do
		AddFOWViewer(teamId, self:GetParent():GetAbsOrigin(), 300, FrameTime() * 3, false)
    end
end
