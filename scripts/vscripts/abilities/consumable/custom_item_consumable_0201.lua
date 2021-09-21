require 'client'
custom_item_consumable_0201 = CustomItemSpellSystem:GetBaseClass()

local public = custom_item_consumable_0201

function public:OnCustomSpellStart(item)
    local caster = self:GetCaster()
    if IsNull(item) or IsNull(caster) then
        return
    end
    caster:ModifyCustomAttribute("int", "item_consumable_0201", item:GetSpecialValueFor("intelligence"))
    caster:AddConsumableUseCount("item_consumable_0201")
end