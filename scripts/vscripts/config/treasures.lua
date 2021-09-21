TREASURE_UNIT_TABLE = {
	{
		unitname = "npc_treasure_chest",
		item_count_min = 1,
		item_count_max = 1,
	},
}

if TREASURE_CONFIG == nil then
    TREASURE_CONFIG = {}
    local treasuresConfig = LoadKeyValues("scripts/kv/treasures.kv")

    -- 每个区域一个， 箱子里一个一级装备
    for key, configItem in pairs(treasuresConfig) do
        TREASURE_CONFIG[key] = {
            TotalCount = configItem.TotalCount,
            Items = {},
        }

        local targetKinds = {
            ITEM_KIND_WEAPON,
            ITEM_KIND_GLOVES,
            ITEM_KIND_SHOES,
            ITEM_KIND_CLOTHES,
            ITEM_KIND_HAT,
            ITEM_KIND_TRINKET,
        }

        for itemName, itemInfo in pairs(ItemConfig) do
            if itemInfo.quality == 1 and table.contains(targetKinds, itemInfo.kind) then
                table.insert(TREASURE_CONFIG[key].Items, { item_name = itemName, weight = 1})
            end
        end

        TREASURE_CONFIG[key].Items = NormalizeProbFromTable(TREASURE_CONFIG[key].Items, "weight")
    end
end
