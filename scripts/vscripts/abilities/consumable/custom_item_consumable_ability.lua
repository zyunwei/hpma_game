require 'client'
custom_item_consumable_ability = CustomItemSpellSystem:GetBaseClass()

local public = custom_item_consumable_ability

function public:OnCustomSpellStart(item)
    local caster = self:GetCaster()
    if IsNull(caster)  then return end
    local playerId = caster:GetPlayerID()
    AbilityRewardCtrl:RandomMainAbilityForPlayer(playerId)
end