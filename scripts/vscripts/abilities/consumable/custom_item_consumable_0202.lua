require 'client'
custom_item_consumable_0202 = CustomItemSpellSystem:GetBaseClass()

local public = custom_item_consumable_0202

function public:OnCustomSpellStart(item)
    local caster = self:GetCaster()
    if IsNull(item) or IsNull(caster) then
        return
    end
    caster:ModifyCustomAttribute("int", "item_consumable_0202", item:GetSpecialValueFor("intelligence"))
    caster:AddConsumableUseCount("item_consumable_0202")
end