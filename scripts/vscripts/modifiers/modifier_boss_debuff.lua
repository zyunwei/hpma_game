modifier_boss_debuff = class({})

local public = modifier_boss_debuff

function public:IsHidden()
	return false
end

function public:IsDebuff()
	return true
end

function public:IsPurgable()
	return false
end

function public:IsPurgeException()
	return true
end

function public:IsStunDebuff()
	return false
end

function public:AllowIllusionDuplicate()
	return false
end

function public:OnCreated()
    if IsServer() then
        self.damageRate = 1.05
        self:SetStackCount(1)
        self:StartIntervalThink(1.0)
    end
end

function public:OnIntervalThink()
    self:IncrementStackCount()
end

function public:GetTexture()
    return "item_heavens_halberd"
end

function public:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function public:GetModifierIncomingDamage_Percentage()
    return math.pow(self.damageRate, self:GetStackCount()) * 100 - 100
end