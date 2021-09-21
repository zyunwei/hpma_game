modifier_health_regen_percentage = class({})

local public = modifier_health_regen_percentage

function public:IsHidden() return false end
function public:IsDebuff() return false end
function public:IsPurgable() return false end
function public:IgnoreTenacity() return true end
function public:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function public:OnCreated(params)
    self.texture = CustomItemSpellSystem:GetBuffIcon(self, "item_flask")
    self.health_regen_percentage = params.health_regen_percentage or 10
    if IsServer() then
        self.CanInterrupt = true
        if params.CanInterrupt == 1 then
            self.CanInterrupt = false
        end
    end
end

function public:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
        -- MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end

function public:GetTexture()
    return self.texture
end

function public:GetModifierHealthRegenPercentage()
    return self.health_regen_percentage
end

-- function public:OnTakeDamage(keys)
--     if not IsServer() then return end
--     local attacker = keys.attacker
--     local unit = keys.unit
--     local parent = self:GetParent()
--     if IsNull(attacker) or IsNull(unit) or IsNull(parent) then return end
--     if unit == parent and attacker.IsRealHero ~= nil and attacker:IsRealHero() and self.CanInterrupt then
--         self:Destroy()
--     end
-- end