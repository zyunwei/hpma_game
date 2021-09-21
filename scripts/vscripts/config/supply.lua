if SUPPLY_CONFIG == nil then
    SUPPLY_CONFIG = {}
    local suppliesConfig = LoadKeyValues("scripts/kv/supplies.kv")
    local maxLevel = 5

    SUPPLY_CONFIG.SupplyConfigs = suppliesConfig.SupplyConfigs

    local qualityTables = {}
    for i = 1, maxLevel do
        local qualityInfo = suppliesConfig["Quality_" .. tostring(i)]
        if qualityInfo then
            qualityTables[i] = NormalizeProbFromTable(qualityInfo, "Weight")
        end
    end
    SUPPLY_CONFIG.QualityTables = qualityTables

    qualityTables = {}
    for i = 1, maxLevel do
        local qualityInfo = suppliesConfig["Quality_" .. tostring(i)]
        if qualityInfo then
            qualityTables[i] = {}
        end
    end

    local targetKinds = {
        ITEM_KIND_WEAPON,
        ITEM_KIND_SHOES,
        ITEM_KIND_CLOTHES,
        ITEM_KIND_HAT,
        ITEM_KIND_TRINKET,
        ITEM_KIND_GLOVES,
    }
    
    for itemName, itemInfo in pairs(ItemConfig) do
        local targetWeight = 1
        local targetQuality = 2
        if table.contains(targetKinds, itemInfo.kind) then
            targetQuality = itemInfo.quality
            if qualityTables[targetQuality] then
                table.insert(qualityTables[targetQuality], {ItemName = itemName, Weight = targetWeight})
            end
        end
    end
    
    for i = 1, maxLevel do
        local qualityInfo = qualityTables[i]
        if qualityInfo then
            qualityTables[i] = NormalizeProbFromTable(qualityInfo, "Weight")
        end
    end
    SUPPLY_CONFIG.QualityTables = qualityTables
end
