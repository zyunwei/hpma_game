require 'client'
custom_item_consumable_0003 = CustomItemSpellSystem:GetBaseClass()

local public = custom_item_consumable_0003

function public:OnCustomSpellStart(item)
    local caster = self:GetCaster()

    if IsNull(item) or IsNull(caster) then
        return
    end

    local itemCount = item:GetCurrentCharges()
    local bag = caster:GetBag()
    local learnedAll = false
    if bag then
        bag:RemoveItem(item)
        for i = 1, itemCount do
            local upgradeXinfa = PlayerInfo:GetXinFaToBeUpgrade(caster:GetPlayerID())
            if upgradeXinfa ~= nil then
                local modifierParams = {}
                if upgradeXinfa.specialValue then
                    for k, v in pairs(upgradeXinfa.specialValue) do
                        modifierParams[k] = v
                    end
                end
                caster:AddNewModifier(caster, nil, upgradeXinfa.modifierName, modifierParams)
                if upgradeXinfa.upgradeAbility then
                    CardGroupSystem:ReplaceCard(caster:GetPlayerID(), upgradeXinfa.abilityName, upgradeXinfa.upgradeAbilityName, false)
                end
                caster:ShowCustomMessage({
                    type="bottom",
                    msg={"xxwar_learn", "DOTA_Tooltip_"..upgradeXinfa.modifierName},
                    class="success",
                })
            else
                learnedAll = true
            end
        end
    end

    if learnedAll then
        Avalon:Throw(caster, "xxwar_learned_all_xinfa")
    end
end
