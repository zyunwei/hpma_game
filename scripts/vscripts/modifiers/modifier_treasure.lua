modifier_treasure = class({})

local public = modifier_treasure

--------------------------------------------------------------------------------

function public:IsDebuff()
	return false
end

--------------------------------------------------------------------------------

function public:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function public:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function public:IsAura()
	return true
end

--------------------------------------------------------------------------------

function public:GetModifierAura()
	return "modifier_treasure_hero_touching"
end

--------------------------------------------------------------------------------

function public:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_BOTH
end

--------------------------------------------------------------------------------

function public:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

--------------------------------------------------------------------------------

function public:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS
end

--------------------------------------------------------------------------------

function public:GetAuraRadius()
	return 150
end

--------------------------------------------------------------------------------

function public:GetAuraEntityReject( hEntity )
	if IsServer() then
		if not hEntity:IsHero() then return true end

		if self:GetParent() == hEntity then
			return true
		end
	end

	return false
end

--------------------------------------------------------------------------------

function public:CheckState()
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
--------------------------------------------------------------------------------