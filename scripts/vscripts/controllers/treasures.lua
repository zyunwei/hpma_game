if TreasuresCtrl == nil then
	TreasuresCtrl = RegisterController('treasures')
	TreasuresCtrl.__treasures = {}
end

local public = TreasuresCtrl

INIT_TREASURES_COUNT = 50

function public:init()
	LinkLuaModifier("modifier_treasure", "modifiers/modifier_treasure", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_treasure_hero_touching", "modifiers/modifier_treasure_hero_touching", LUA_MODIFIER_MOTION_NONE)

    local regions = BlockadeSystem:GetAllRegions()
    for regionId, region in pairs(regions) do
        local config = TREASURE_CONFIG["TreasureInRegion_" .. tostring(regionId)]
        for i = 1, config.TotalCount do
            self:CreateTreasureInRegion(regionId, config)    
        end
    end

    local allCollections = Entities:FindAllByName("npc_dota_techies_mines")
    for _, v in pairs(allCollections) do
        if v:HasAbility("ability_collection_unit") then
            v:SetAbility("ability_collection_unit")
        end
    end
end

function public:CreateTreasureInRegion(regionId, config)
    local region = BlockadeSystem:GetRegionById(regionId)
    if region == nil or config == nil then
        return
    end
    local treasure_setting = table.random(TREASURE_UNIT_TABLE)
    if config == nil or treasure_setting == nil then
        return
    end
    local loc = region:RandomPointInRegion()
    local unit = CreateUnitByName(treasure_setting.unitname, loc, true, nil, nil, DOTA_TEAM_NEUTRALS)
    if unit == nil then
        return
    end
    unit:SetHullRadius(0)
    unit:SetAbility("ability_collection_unit")
    local treasure = {
        entindex = unit:entindex(),
        unitname = treasure_setting.unitname,
        items = {}
    }

    local itemcount = math.random(treasure_setting.item_count_min, treasure_setting.item_count_max)
    local items = config.Items
    for i = 1, itemcount do
        local randomValue = math.random()
        local sumValue = 0
        local targetItemName = nil
        for _, item in pairs(items) do
            if sumValue + item.weight >= randomValue then
                targetItemName = item.item_name
                break
            end
            sumValue = sumValue + item.weight
        end
        if targetItemName then
            table.insert(treasure.items, targetItemName)
        end
    end

    -- 加1级消耗品
    local consumeitems = {}
    for itemName, itemInfo in pairs(ItemConfig) do
        if itemInfo.quality == 1 and itemInfo.kind == ITEM_KIND_CONSUMABLE then
            table.insert(consumeitems, itemName)
        end
    end

    local extraItem = table.random(consumeitems)
    if extraItem ~= nil then
        table.insert(treasure.items, extraItem)
    end

    table.insert(self.__treasures, treasure)
end

function public:GetTreasureItems(entindex)
	local items = {}
	for _, t in pairs(self.__treasures) do
		if t.entindex == entindex then
			for _, v in pairs(t.items) do
				table.insert(items,{
					display = "item",
					itemname = v
				})
			end
		end
	end

	return items
end

function public:RemoveItem(entindex, itemname)
	local items = {}
	for _, t in pairs(self.__treasures) do
		if t.entindex == entindex then
			for _, v in pairs(t.items) do
				if v == itemname then
					table.remove_value(t.items, v)
					break
				end
			end
		end
	end
end

function public:OnTouching(npc, hero)

end

function public:OnOpenTreasure(entIndex, hero)
    local unit = EntIndexToHScript(entIndex)
    if IsNull(unit) or IsNull(hero) then return end
    local modifier = hero:FindModifierByName("modifier_ability_custom_treasure_hunter")
    if NotNull(modifier) then
        if RollPercentage(modifier:GetChance()) then
            self:AddRandomItemQuality(entIndex, {1})
        end
    end

    unit:SetOriginalModel("models/props_generic/chest_treasure_02_open.vmdl")
    unit:NotifyWearablesOfModelChange(true)

    unit:RemoveAbility("ability_collection_unit")
    unit:AddNewModifier(unit, nil, "modifier_treasure", nil)
end

function public:AddRandomItemQuality(entIndex, qualities)
    local itemName = GetRandomItemQuality(qualities, false)
    if itemName then
        for _, t in pairs(self.__treasures) do
            if t.entindex == entIndex then
                table.insert(t.items, itemName)
            end
        end
    end
end