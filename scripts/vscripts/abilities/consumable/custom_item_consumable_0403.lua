require 'client'
custom_item_consumable_0403 = CustomItemSpellSystem:GetBaseClass()

local public = custom_item_consumable_0403

function public:OnCustomSpellStart(item)
    local caster = self:GetCaster()
    if IsNull(item) or IsNull(caster) then
        return
    end
    caster:ModifyCustomAttribute("str", "item_consumable_0403", item:GetSpecialValueFor("strength"))
    caster:AddConsumableUseCount("item_consumable_0403")
end