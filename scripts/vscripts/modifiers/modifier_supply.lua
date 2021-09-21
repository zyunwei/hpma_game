modifier_supply = class({})

local public = modifier_supply

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
	return "modifier_supply_hero_touching"
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