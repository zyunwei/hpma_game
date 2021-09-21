modifier_ganjiangjianxinfa = class({})

function modifier_ganjiangjianxinfa:IsHidden() return false end
function modifier_ganjiangjianxinfa:IsDebuff() return false end
function modifier_ganjiangjianxinfa:IsPurgable() return false end
function modifier_ganjiangjianxinfa:RemoveOnDeath() return false end

function modifier_ganjiangjianxinfa:GetTexture()
	return "ability_custom_battle_trance"
end

function modifier_ganjiangjianxinfa:OnCreated(params)
    self.crystal_cost_reduce = params.crystal_cost_reduce or 2
	self.bonus_duration = params.bonus_duration or 2
end

function modifier_ganjiangjianxinfa:GetCrystalCostReduce()
    return self.crystal_cost_reduce
end

function modifier_ganjiangjianxinfa:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOOLTIP
	}
end

function modifier_ganjiangjianxinfa:OnTooltip()
	return self.crystal_cost_reduce
end

function modifier_ganjiangjianxinfa:GetBonusDuration()
	return self.bonus_duration
end
