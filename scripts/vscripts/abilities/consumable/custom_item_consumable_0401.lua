require 'client'
custom_item_consumable_0401 = CustomItemSpellSystem:GetBaseClass()

local public = custom_item_consumable_0401

function public:OnCustomSpellStart(item)
    local caster = self:GetCaster()
    if IsNull(item) or IsNull(caster) then
        return
    end
    caster:ModifyCustomAttribute("str", "item_consumable_0401", item:GetSpecialValueFor("strength"))
    caster:AddConsumableUseCount("item_consumable_0401")
end