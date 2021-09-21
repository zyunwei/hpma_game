if SupplyCtrl == nil then
	SupplyCtrl = RegisterController('supplies')
end

local public = SupplyCtrl

function public:init()
    self.__supplies = {}
    self.__supplyWaveCounts = {}
    self.__supplyIndex = 0
    self.__supplyBoxes = {}
    LinkLuaModifier("modifier_supply","modifiers/modifier_supply",LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_supply_hero_touching","modifiers/modifier_supply_hero_touching",LUA_MODIFIER_MOTION_NONE)
end

function public:Start()
    local GameMode = GameRules:GetGameModeEntity()

    for k, v in pairs(SUPPLY_CONFIG.SupplyConfigs) do
        self.__supplyWaveCounts[k] = 0
    end
    GameMode:SetContextThink("SupplyCtrl", function() return self:OnThink() end, 1)
end

function public:OnThink()
    local nowTime = GameManager:GetGameTime()
    for k, v in pairs(SUPPLY_CONFIG.SupplyConfigs) do
        local targetTime = v.SupplyStartTime + self.__supplyWaveCounts[k] * v.GenerateInterval
        if targetTime < nowTime then
            self:CreateNewSupplies(k, v)
        end
    end

    for _, supply in pairs(self.__supplies) do
        if supply:GetIsHintOver() == false and supply:CheckHintTimeOver() then
            supply:CreateSupplyBox()
            table.insert(self.__supplyBoxes, supply)
        end
    end

    for _, v in pairs(self.__supplyBoxes) do
        if v ~= nil and v:GetCreateTime() + 90 < nowTime then
            public:RemoveSupplyBox(v.__supplyBoxIndex)
            table.remove_value(self.__supplyBoxes, v)
        end
    end

    return 1
end

function public:CreateNewSupplies(configKey, configValue)
    local regionCount = BlockadeSystem:GetRegionCount()
    local generateCount = configValue.TotalCount
    local regions = {}
    for i = 1, regionCount do
        table.insert(regions, i)
    end
    regions = table.shuffle(regions)
    local mapLength = GameRules.XW.MapBorderSize
    for i = 1, generateCount do
        local index = (i - 1) % regionCount + 1
        local supplyItem = self:CreateSupplyInRegion(regions[index], configValue)
        if supplyItem ~= nil then
            local position = supplyItem.__position
            local pos = {
                x = (position.x + mapLength) / (2 * mapLength),
                y = (mapLength - position.y) / (2 * mapLength)
            }
            CustomNetTables:SetTableValue("TreasureIcon", tostring(supplyItem.__index), { pos = pos, quality = supplyItem.__quality} )
        end
    end
    self.__supplyWaveCounts[configKey] = self.__supplyWaveCounts[configKey] + 1
end

function public:CreateSupplyInRegion(regionId, levelInfo)
    local region = BlockadeSystem:GetRegionById(regionId)
    if region:IsBlockade() then
        return
    end
    local position = region:RandomPointInRegion()
    local supplyItem = Supply()
    supplyItem.__index = self.__supplyIndex
    self.__supplyIndex = self.__supplyIndex + 1
    local dropItemCount = RandomInt(levelInfo.MinItemCount, levelInfo.MaxItemCount)
    local dropItems = {}
    for i = 1, dropItemCount do
        local dropItemQuality = tonumber(RandomFromProbValues(levelInfo.QualityProbabilities))
        local candidateItems = SUPPLY_CONFIG.QualityTables[dropItemQuality]
        if candidateItems then
            local index = RandomFromProbTable(candidateItems, "Weight")
            local itemName = candidateItems[index].ItemName
            table.insert(dropItems, itemName)
        end
    end
    
    supplyItem:CreateSupply(position, dropItems, levelInfo.SupplyHintTime)
    table.insert(self.__supplies, supplyItem)
    return supplyItem
end

function public:GetSupplyByBoxIndex(supplyBoxIndex)
    if supplyBoxIndex == nil or supplyBoxIndex < 0 then
        return
    end
    for _, supply in pairs(self.__supplies) do
        if supply:GetSupplyBoxIndex() == supplyBoxIndex then
            return supply
        end
    end
    return nil
end

function public:OnOpenSupply(supplyBoxIndex, hero)
    local supply = self:GetSupplyByBoxIndex(supplyBoxIndex)
    if supply == nil or IsNull(hero) then
        return
    end
    local modifier = hero:FindModifierByName("modifier_ability_custom_treasure_hunter")
    if NotNull(modifier) then
        if RollPercentage(modifier:GetChance()) then
            supply:AddRandomItemQuality()
        end
    end
    supply:OpenSupply()
    local player = hero:GetPlayerOwner()
    CustomGameEventManager:Send_ServerToPlayer(player, "xxwar_touch_supply", {unit = supplyBoxIndex})
end

function public:GetSupplyBoxItems(supplyBoxIndex)
    local items = {}
    local supply = self:GetSupplyByBoxIndex(supplyBoxIndex)
    if supply == nil then
        return items
    end
    local dropItems = supply:GetDropItems()
    for _, itemName in pairs(dropItems) do
        table.insert(items, {
            display = "item",
            itemname = itemName
        })
    end 
    return items
end

function public:RemoveItemFromSupplyBox(supplyBoxIndex, itemName)
    local supply = self:GetSupplyByBoxIndex(supplyBoxIndex)
    if supply == nil then
        return
    end
    supply:RemoveItem(itemName)
end

function public:RemoveSupplyBox(supplyBoxIndex)
    local supply = self:GetSupplyByBoxIndex(supplyBoxIndex)
    if supply == nil then
        return
    end
    supply:Destroy()
    table.remove_value(self.__supplies, supply)
end

function public:GetSupplyBoxIsBeOpened(supplyBoxIndex)
    local supply = self:GetSupplyByBoxIndex(supplyBoxIndex)
    if supply == nil then
        return false
    end
    return supply:IsBeOpened()
end