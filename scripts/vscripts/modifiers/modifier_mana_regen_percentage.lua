modifier_mana_regen_percentage = class({})

local public = modifier_mana_regen_percentage

function public:IsHidden() return false end
function public:IsDebuff() return false end
function public:IsPurgable() return false end
function public:IgnoreTenacity() return true end
function public:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function public:OnCreated(params)
    self.texture = CustomItemSpellSystem:GetBuffIcon(self, "item_clarity")
    self.mana_regen_percentage = params.mana_regen_percentage or 10
end

function public:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE,
    }
end

function public:GetTexture()
	return self.texture
end

function public:GetModifierTotalPercentageManaRegen()
    return self.mana_regen_percentage
end
