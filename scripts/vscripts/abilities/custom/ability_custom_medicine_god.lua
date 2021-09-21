ability_custom_medicine_god = ability_custom_medicine_god or class({})

function ability_custom_medicine_god:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
    if IsNull(caster) then return end
    local chance = self:GetSpecialValueFor("chance")
    local remainCrystal = caster:GetCustomAttribute("crystal")
    local crystalCost = self:GetSpecialValueFor("crystal_cost") + remainCrystal
    caster:ModifyCustomAttribute("crystal", "crystal", -remainCrystal)

    local item = nil
    if crystalCost >= 1 and crystalCost <= 3 then
        item = table.random(ItemComposeClassifyTable[1][ITEM_KIND_CONSUMABLE])
    elseif crystalCost >= 4 and crystalCost <= 6 then
        item = table.random(ItemComposeClassifyTable[2][ITEM_KIND_CONSUMABLE])
    elseif crystalCost >= 7 and crystalCost <= 9 then
        item = table.random(ItemComposeClassifyTable[3][ITEM_KIND_CONSUMABLE])
    elseif crystalCost == 10 then
        item = table.random(ItemComposeClassifyTable[4][ITEM_KIND_CONSUMABLE])
    end
    local bag = caster:GetBag()
    if item then
        if bag and bag:CanCreateItem(item, 1) then
            caster:AddItemByName(item)
        else
            DropperCtrl:DropItem(item, caster:GetAbsOrigin(), nil)
        end
    end

    -- if RollPercentage(chance * crystalCost) then
    --     if bag and bag:CanCreateItem("item_consumable_ability", 1) then
    --         caster:AddItemByName("item_consumable_ability")
    --     else
    --         DropperCtrl:DropItem("item_consumable_ability", caster:GetAbsOrigin(), nil)
    --     end
    -- end
end