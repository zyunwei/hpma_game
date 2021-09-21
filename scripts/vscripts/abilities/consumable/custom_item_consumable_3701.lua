require 'client'
custom_item_consumable_3701 = CustomItemSpellSystem:GetBaseClass()

local public = custom_item_consumable_3701

function public:OnCustomSpellStart(item)
    local caster = self:GetCaster()
    if IsNull(item) or IsNull(caster) then
        return
    end
    local cooldown_reduction = item:GetSpecialValueFor("cooldown_reduction")
    caster:RandomAbilityCooldownReduction(cooldown_reduction)
end