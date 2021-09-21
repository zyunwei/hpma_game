modifier_heal_amplify_percentage = class({})

local public = modifier_heal_amplify_percentage

function public:IsHidden() return false end
function public:IsDebuff() return false end
function public:IsPurgable() return false end
function public:IgnoreTenacity() return true end
function public:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function public:OnCreated(params)
    self.heal_amplify_percentage = params.heal_amplify_percentage or 10
end

function public:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
        MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
    }
end

function public:GetTexture()
	return "item_satanic"
end

function public:GetModifierHealAmplify_PercentageTarget()
    return self.heal_amplify_percentage
end

function public:GetModifierHPRegenAmplify_Percentage()
    return self.heal_amplify_percentage
end
