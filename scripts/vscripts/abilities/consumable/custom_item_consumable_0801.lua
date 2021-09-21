require 'client'
custom_item_consumable_0801 = CustomItemSpellSystem:GetBaseClass()

local public = custom_item_consumable_0801

function public:OnCustomSpellStart(item)
    local caster = self:GetCaster()
    if IsNull(item) or IsNull(caster) then
        return
    end
    local health_regen_pct = item:GetSpecialValueFor("health_regen_pct")
    caster:ModifyCustomAttribute("health_regen_pct", "item_consumable_0801", health_regen_pct)
    caster:AddConsumableUseCount("item_consumable_0801")
end