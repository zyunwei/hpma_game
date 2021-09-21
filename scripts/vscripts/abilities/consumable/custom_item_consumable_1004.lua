require 'client'
custom_item_consumable_1004 = CustomItemSpellSystem:GetBaseClass()

local public = custom_item_consumable_1004

function public:OnCustomSpellStart(item)
    local caster = self:GetCaster()
    if IsNull(item) or IsNull(caster) then
        return
    end
    local incoming_damage = item:GetSpecialValueFor("incoming_damage")
    caster:ModifyCustomAttribute("incoming_damage", "item_consumable_1004", incoming_damage)
    caster:AddConsumableUseCount("item_consumable_01004")
end