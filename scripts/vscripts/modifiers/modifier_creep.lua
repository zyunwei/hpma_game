modifier_creep = class({})

function modifier_creep:IsDebuff()
	return false
end

function modifier_creep:IsHidden()
	return true
end

function modifier_creep:IsPurgable()
	return false
end

function modifier_creep:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE,
    }
end

function modifier_creep:OnCreated(params)
    self.bonus_health_pct = 15
    self.bonus_damage_pct = 0.1
    self.bonus_gold_pct = 0.1
    self.bonus_exp_pct = 0.1
    self:SetStackCount(params.stack_count)
end

function modifier_creep:GetModifierPreAttack_BonusDamage()
    local parent = self:GetParent()
    if IsNull(parent) then return end
    return parent:GetDamageMax() * self.bonus_damage_pct * self:GetStackCount()
end

function modifier_creep:GetModifierExtraHealthPercentage()
    return self.bonus_health_pct * self:GetStackCount()
end

function modifier_creep:OnStackCountChanged(old)
    if not IsServer() then return end
    local unit = self:GetParent()
    if IsNull(unit) then return end
    self.origin_min_gold_bounty = unit:GetMinimumGoldBounty()
    self.origin_max_gold_bounty = unit:GetMaximumGoldBounty()
    unit:SetMinimumGoldBounty(self.origin_min_gold_bounty * math.pow((1 + self.bonus_gold_pct), self:GetStackCount()))
    unit:SetMaximumGoldBounty(self.origin_min_gold_bounty * math.pow((1 + self.bonus_gold_pct), self:GetStackCount()))

    self.origin_xp = unit:GetDeathXP()
    unit:SetDeathXP(self.origin_xp * math.pow((1 + self.bonus_exp_pct), self:GetStackCount()))
end