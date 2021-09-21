require 'client'
ability_creep_enhancement = ability_creep_enhancement or class({})
LinkLuaModifier("modifier_ability_creep_enhancement", "abilities/ability_creep_enhancement", LUA_MODIFIER_MOTION_NONE)

function ability_creep_enhancement:GetIntrinsicModifierName()
	return "modifier_ability_creep_enhancement"
end

function ability_creep_enhancement:OnUpgrade()
    if IsServer() then
        local creep = self:GetCaster()
        if IsNull(creep) == false then
            local modifier = creep:FindModifierByName("modifier_ability_creep_enhancement")
            if modifier ~= nil then
                modifier:Reset()
                modifier:SetStackCount(self:GetLevel())
            end
        end
    end
end

modifier_ability_creep_enhancement = class({})

function modifier_ability_creep_enhancement:IsDebuff()
	return false
end

function modifier_ability_creep_enhancement:IsHidden()
	return false
end

function modifier_ability_creep_enhancement:IsPurgable()
	return false
end

function modifier_ability_creep_enhancement:IsAura()
	return false
end

function modifier_ability_creep_enhancement:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE,
    }
end

function modifier_ability_creep_enhancement:OnCreated(keys)
    self:UpdateBonus()
end

function modifier_ability_creep_enhancement:UpdateBonus()
    local ability = self:GetAbility()
    if NotNull(ability) then
        self.health_bouns = ability:GetSpecialValueFor("health_bouns") * 100
        self.attack_damage = ability:GetSpecialValueFor("attack_damage")
        self.armor_bouns = ability:GetSpecialValueFor("armor_bouns")
        self.magical_resistance_bouns = ability:GetSpecialValueFor("magical_resistance_bouns")
        self.gold_bounty_bouns = ability:GetSpecialValueFor("gold_bounty_bouns")
        self.xp_bounty_bouns = ability:GetSpecialValueFor("xp_bounty_bouns")
    end

    if IsServer() then
        local unit = self:GetParent()
        if IsNull(unit) then return end
        self.origin_min_gold_bounty = unit:GetMinimumGoldBounty()
        self.origin_max_gold_bounty = unit:GetMaximumGoldBounty()
        unit:SetMinimumGoldBounty(self.origin_min_gold_bounty * (1 + self.gold_bounty_bouns))
        unit:SetMaximumGoldBounty(self.origin_max_gold_bounty * (1 + self.gold_bounty_bouns))

        self.origin_xp = unit:GetDeathXP()
        unit:SetDeathXP(self.origin_xp * (1 + self.xp_bounty_bouns))
        self:ForceRefresh()
    end
end

function modifier_ability_creep_enhancement:OnStackCountChanged()
    self:UpdateBonus()
end

function modifier_ability_creep_enhancement:OnDestroy()
    if IsServer() == false then
        return
    end
    local unit = self:GetParent()
    if IsNull(unit) then return end
    unit:SetMinimumGoldBounty(self.origin_min_gold_bounty)
    unit:SetMaximumGoldBounty(self.origin_max_gold_bounty)
    unit:SetDeathXP(self.origin_xp)
end

function modifier_ability_creep_enhancement:GetTexture()
    return "item_quelling_blade"
end

function modifier_ability_creep_enhancement:GetModifierPhysicalArmorBonus()
    return self.armor_bouns
end

function modifier_ability_creep_enhancement:GetModifierMagicalResistanceBonus()
    return self.magical_resistance_bouns
end

function modifier_ability_creep_enhancement:GetModifierPreAttack_BonusDamage()
    return self.attack_damage
end

function modifier_ability_creep_enhancement:GetModifierExtraHealthPercentage()
    return self.health_bouns
end

function modifier_ability_creep_enhancement:Reset()
    if IsServer() == false then
        return
    end
    local unit = self:GetParent()
    if IsNull(unit) then return end
    unit:SetMinimumGoldBounty(self.origin_min_gold_bounty)
    unit:SetMaximumGoldBounty(self.origin_max_gold_bounty)
    unit:SetDeathXP(self.origin_xp)
end
