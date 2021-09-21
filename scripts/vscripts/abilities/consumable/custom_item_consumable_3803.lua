require 'client'
custom_item_consumable_3803 = CustomItemSpellSystem:GetBaseClass()

local public = custom_item_consumable_3803

function public:OnCustomSpellStart(item)
    local caster = self:GetCaster()
    if IsNull(item) or IsNull(caster) then
        return
    end

    local health_regen_percentage = item:GetSpecialValueFor("health_regen_percentage")
    local duration = item:GetSpecialValueFor("duration")
    caster:AddNewModifier(caster, self, "modifier_health_regen_percentage", {duration=duration, health_regen_percentage=health_regen_percentage, CanInterrupt=1})
end