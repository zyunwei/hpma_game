require 'client'
custom_item_consumable_0102 = CustomItemSpellSystem:GetBaseClass()

local public = custom_item_consumable_0102

function public:OnCustomSpellStart(item)
    local caster = self:GetCaster()
    if IsNull(item) or IsNull(caster) then
        return
    end
    local hp = item:GetSpecialValueFor("hp")
    caster:ModifyCustomAttribute("hp", "item_consumable_0102", hp)
    caster:AddConsumableUseCount("item_consumable_0102")
end