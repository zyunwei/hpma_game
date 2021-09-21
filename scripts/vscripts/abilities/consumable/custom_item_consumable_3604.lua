require 'client'
custom_item_consumable_3604 = CustomItemSpellSystem:GetBaseClass()

local public = custom_item_consumable_3604

function public:OnCustomSpellStart(item)
    local caster = self:GetCaster()
    if IsNull(item) or IsNull(caster) then
        return
    end
    caster:ModifyCustomAttribute("int", "item_consumable_3604", item:GetSpecialValueFor("intelligence"))
    caster:ModifyCustomAttribute("agi", "item_consumable_3604", item:GetSpecialValueFor("agility"))
    caster:ModifyCustomAttribute("str", "item_consumable_3604", item:GetSpecialValueFor("strength"))
    caster:AddConsumableUseCount("item_consumable_3604")
end