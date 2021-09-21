modifier_mana_regen_remain = class({})

local public = modifier_mana_regen_remain

function public:IsHidden() return false end
function public:IsDebuff() return false end
function public:IsPurgable() return false end
function public:IgnoreTenacity() return true end
function public:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function public:OnCreated(params)
    self.texture = CustomItemSpellSystem:GetBuffIcon(self, "item_clarity")
    self.mana_regen_percentage = params.mana_regen_percentage or 10
end

function public:GetTexture()
	return self.texture
end

function public:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    }
end

function public:GetModifierConstantManaRegen()
    if not IsServer() then return end
    local hero = self:GetParent()
    local remainMP = hero:GetMaxMana() - hero:GetMana()
    if remainMP > 0 then
        local mana = remainMP * self.mana_regen_percentage / 100
        return mana
    end
    return 0
end
