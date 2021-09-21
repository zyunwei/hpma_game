require 'client'
custom_item_consumable_1204 = CustomItemSpellSystem:GetBaseClass()

local public = custom_item_consumable_1204

function public:OnCustomSpellStart(item)
    local caster = self:GetCaster()
    if IsNull(item) or IsNull(caster) then
        return
    end
    local attack_damage = item:GetSpecialValueFor("attack_damage")
    caster:ModifyCustomAttribute("attack_damage", "item_consumable_1204", attack_damage)
    caster:AddConsumableUseCount("item_consumable_1204")
end