modifier_health_regen_remain = class({})

local public = modifier_health_regen_remain

function public:IsHidden() return false end
function public:IsDebuff() return false end
function public:IsPurgable() return false end

function public:OnCreated(params)
    self.health_regen_percentage = params.health_regen_percentage or 10
    self.texture = CustomItemSpellSystem:GetBuffIcon(self, "item_flask")
end

function public:GetTexture()
    return self.texture
end

function public:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    }
end

function public:GetModifierConstantHealthRegen()
    if not IsServer() then return end
    local hero = self:GetParent()
    local remainHP = hero:GetMaxHealth() - hero:GetHealth()
    if remainHP > 0 then
        local heal = remainHP * self.health_regen_percentage / 100
        return heal
    end
    return 0
end
