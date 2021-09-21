modifier_bulaochangchun	= class({})
modifier_bulaochangchun_permanent_buff		= class({})

function modifier_bulaochangchun:IsHidden() return false end
function modifier_bulaochangchun:IsDebuff() return false end
function modifier_bulaochangchun:IsPurgable() return false end
function modifier_bulaochangchun:RemoveOnDeath() return false end

function modifier_bulaochangchun:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH
	}
end

function modifier_bulaochangchun:GetTexture()
	return "ability_custom_battle_trance"
end

function modifier_bulaochangchun:OnDeath(keys)
	if not IsServer() then return end
	local hero = self:GetParent()
	local attacker = keys.attacker
	local target = keys.unit
	if IsNull(hero) or IsNull(attacker) or IsNull(target) then return end
    if hero.IsIllusion == nil or hero:IsIllusion() then return end

	if attacker ~= hero then return end
    if hero.IsAlive == nil or hero:IsAlive() == false then return end

	if attacker:GetTeam() == target:GetTeam() then return end

	local permanent_buff_name = "modifier_bulaochangchun_permanent_buff"
	local permanent_buff = hero:FindModifierByName(permanent_buff_name)
	if permanent_buff == nil then
		permanent_buff = hero:AddNewModifier(hero, nil, permanent_buff_name, {})
	end

	if permanent_buff ~= nil then
		permanent_buff:IncrementStackCount()
	end
end

function modifier_bulaochangchun_permanent_buff:IsHidden() return false end
function modifier_bulaochangchun_permanent_buff:IsDebuff() return false end
function modifier_bulaochangchun_permanent_buff:IsPurgable() return false end
function modifier_bulaochangchun_permanent_buff:RemoveOnDeath() return false end
function modifier_bulaochangchun_permanent_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_TOOLTIP,
	}
end

function modifier_bulaochangchun_permanent_buff:GetTexture()
	return "item_consumable_1403"
end

function modifier_bulaochangchun_permanent_buff:GetModifierHealthBonus()
	return self:GetStackCount() * 20
end

function modifier_bulaochangchun_permanent_buff:OnTooltip()
	return self:GetStackCount() * 20
end
