require 'client'
custom_item_consumable_0701 = CustomItemSpellSystem:GetBaseClass()

local public = custom_item_consumable_0701

function public:OnCustomSpellStart(item)
    local caster = self:GetCaster()
    if IsNull(item) or IsNull(caster) then
        return
    end
    local mana = item:GetSpecialValueFor("mana")
    local mana_regen = item:GetSpecialValueFor("mana_regen")
    caster:ModifyCustomAttribute("mana", "item_consumable_0701", mana)
    caster:ModifyCustomAttribute("mana_regen_pct", "item_consumable_0701", mana_regen)
    caster:AddConsumableUseCount("item_consumable_0701")
    local mana_regen_percentage = item:GetSpecialValueFor("mana_regen_percentage")
    local duration = item:GetSpecialValueFor("duration")
    caster:AddNewModifier(caster, self, "modifier_mana_regen_percentage", {duration=duration, mana_regen_percentage=mana_regen_percentage})
end