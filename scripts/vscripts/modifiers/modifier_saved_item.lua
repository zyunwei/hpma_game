modifier_saved_item = class({})

local public = modifier_saved_item

function public:IsDebuff() return false end
function public:IsHidden() return true end
function public:IsPurgable() return false end
function public:RemoveOnDeath() return false end

function public:OnCreated(params)
    self.str = params.str or 0
    self.agi = params.agi or 0
    self.int = params.int or 0
    self.armor = params.armor or 0
    self.magic_armor = params.magic_armor or 0
    self.spell_amp = params.spell_amp or 0
end

function public:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
	}
	return decFuncs
end

function public:GetModifierBonusStats_Strength()
	return self.str
end

function public:GetModifierBonusStats_Agility()
	return self.agi
end

function public:GetModifierBonusStats_Intellect()
	return self.int
end

function public:GetModifierPhysicalArmorBonus()
	return self.armor
end

function public:GetModifierMagicalResistanceBonus()
	return self.magic_armor
end

function public:GetModifierSpellAmplify_Percentage()
	return self.spell_amp
end
