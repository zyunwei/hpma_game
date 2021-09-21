modifier_treasure_hero_touching = class({})

local public = modifier_treasure_hero_touching

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

function public:OnCreated(keys)
	if IsServer() then
		if self == nil or self:IsNull() then
			return
		end

		local caster = self:GetCaster()
		local hero = self:GetParent()
		TreasuresCtrl:OnTouching(caster, hero)

		if IsNull(caster) or IsNull(hero) then
			return
		end

		CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "xxwar_touch_treasure", {unit=caster:GetEntityIndex()})
	end
end

function public:OnDestroy(keys)
	if IsServer() then
		if IsNull(self) then return end
		local hero = self:GetParent()
		if IsNull(hero) then return end
        CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "xxwar_touch_treasure_close", {})
	end
end
