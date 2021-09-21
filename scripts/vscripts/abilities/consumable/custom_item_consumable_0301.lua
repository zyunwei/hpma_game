require 'client'
custom_item_consumable_0301 = CustomItemSpellSystem:GetBaseClass()

local public = custom_item_consumable_0301

function public:OnCustomSpellStart(item)
    local caster = self:GetCaster()
    if IsNull(item) or IsNull(caster) then
        return
    end
    caster:ModifyCustomAttribute("agi", "item_consumable_0301", item:GetSpecialValueFor("agility"))
    caster:AddConsumableUseCount("item_consumable_0301")
end