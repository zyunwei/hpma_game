local item_compose_table = {}

ItemComposeTable = {}
for item_name, v in pairs(ItemConfig) do
    if table.find(item_compose_table, "composeItem", item_name) == nil then
        table.insert(ItemComposeTable, {["composeItem"] = item_name, ["composable"] = v.composable})
    end
end

for _, v in pairs(item_compose_table) do
    table.insert(ItemComposeTable, v)
end

for k, v in pairs(ItemComposeTable) do
    v["ID"] = k
end

if ItemComposeClassifyTable == nil then
    ItemComposeClassifyTable = {}
    for i = 1, 5 do
        ItemComposeClassifyTable[i] = {}
    end

    local targetKinds = {
        ITEM_KIND_WEAPON,
        ITEM_KIND_GLOVES,
        ITEM_KIND_SHOES,
        ITEM_KIND_CLOTHES,
        ITEM_KIND_HAT,
        ITEM_KIND_TRINKET,
        ITEM_KIND_CONSUMABLE
    }
    for _, kind in pairs(targetKinds) do
        for i = 1, 5 do
            ItemComposeClassifyTable[i][kind] = {}
        end
    end
    for itemName, itemInfo in pairs(ItemConfig) do
        if itemInfo.quality <= 5 and table.contains(targetKinds, itemInfo.kind) and (itemInfo.composable == 1 or itemInfo.kind ~= ITEM_KIND_CONSUMABLE) then
            table.insert(ItemComposeClassifyTable[itemInfo.quality][itemInfo.kind], itemName)
        end
    end
end
