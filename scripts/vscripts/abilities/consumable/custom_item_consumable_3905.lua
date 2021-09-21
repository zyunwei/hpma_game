require 'client'

LinkLuaModifier("modifier_custom_ultimate_scepter", "modifiers/pet/modifier_pet_passive", LUA_MODIFIER_MOTION_NONE)
custom_item_consumable_3905 = CustomItemSpellSystem:GetBaseClass()

local public = custom_item_consumable_3905

function public:OnCustomSpellStart(item)
    local caster = self:GetCaster()
    if IsNull(item) or IsNull(caster) then
        return
    end
    caster:AddNewModifier(caster, nil, "modifier_item_ultimate_scepter", {})
    caster:AddNewModifier(caster, nil, "modifier_custom_ultimate_scepter", {})
    caster:ModifyCustomAttribute("int", "item_consumable_3905", item:GetSpecialValueFor("intelligence"))
    caster:ModifyCustomAttribute("agi", "item_consumable_3905", item:GetSpecialValueFor("agility"))
    caster:ModifyCustomAttribute("str", "item_consumable_3905", item:GetSpecialValueFor("strength"))
end