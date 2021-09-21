require 'client'
custom_item_consumable_0303 = CustomItemSpellSystem:GetBaseClass()

local public = custom_item_consumable_0303

function public:OnCustomSpellStart(item)
    local caster = self:GetCaster()
    if IsNull(item) or IsNull(caster) then
        return
    end
    caster:ModifyCustomAttribute("agi", "item_consumable_0303", item:GetSpecialValueFor("agility"))
    caster:AddConsumableUseCount("item_consumable_0303")
end