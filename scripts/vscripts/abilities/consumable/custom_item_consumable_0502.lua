require 'client'
custom_item_consumable_0502 = CustomItemSpellSystem:GetBaseClass()

local public = custom_item_consumable_0502

function public:OnCustomSpellStart(item)
    local caster = self:GetCaster()
    if IsNull(item) or IsNull(caster) then
        return
    end
    caster:ModifyCustomAttribute("move_speed", "item_consumable_0502", item:GetSpecialValueFor("move_speed"))
    caster:AddConsumableUseCount("item_consumable_0502")
end