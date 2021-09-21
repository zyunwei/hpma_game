if ItemReplaceSystem == nil then
	ItemReplaceSystem = RegisterController('item_replace_system')
end

local public = ItemReplaceSystem

function public:CanReplace(hero, item)
	local config = ItemConfig[item:GetAbilityName()]

	if config.quality <= ITEM_QUALITY_D then
		return Avalon:Throw(hero,"xxwar_replace_error_msg_quality", false)
	end

	local group = ItemKindGroup[config.kind]

	if group == ITEM_KIND_GROUP_WEAPON or group == ITEM_KIND_GROUP_SHOES or group == ITEM_KIND_GROUP_CLOTHES
		or group == ITEM_KIND_GROUP_HAT or group == ITEM_KIND_GROUP_TRINKET or group == ITEM_KIND_GROUP_GLOVES then
		return true
	end

	return Avalon:Throw(hero,"xxwar_replace_error_msg_kind",false)
end

function public:ReplaceItem(hero, item)
	local bag = hero:GetBag()

	if item == nil or not bag:HasItem(item) then return end

	if not self:CanReplace(hero, item) then
		return
	end

	local itemconfig = ItemConfig[item:GetAbilityName()]
	if itemconfig == nil then
		return 
	end

	local cost = 0
	if itemconfig.quality == ITEM_QUALITY_D then
		cost = 100
	elseif itemconfig.quality == ITEM_QUALITY_C then
		cost = 200
	elseif itemconfig.quality == ITEM_QUALITY_B then
		cost = 400
	elseif itemconfig.quality == ITEM_QUALITY_A then
		cost = 800
	elseif itemconfig.quality == ITEM_QUALITY_S then
		cost = 1600
	elseif itemconfig.quality == ITEM_QUALITY_Z then
		cost = 6400
	elseif itemconfig.quality == ITEM_QUALITY_EX then
		cost = 12800
	end

	local playerInfo = GameRules.XW:GetPlayerInfo(hero:GetPlayerID())
	if playerInfo ~= nil and hero:SpendGold(cost) then
		local oldItemName = item:GetName()
		bag:RemoveItem(item)
		local allKinds = {ITEM_KIND_WEAPON, ITEM_KIND_SHOES, ITEM_KIND_CLOTHES, ITEM_KIND_HAT, ITEM_KIND_TRINKET, ITEM_KIND_GLOVES}
		local candidateItems = ItemComposeClassifyTable[itemconfig.quality][table.random(allKinds)]
		local targetItemName = table.random(candidateItems)

		local notDuplicatedItems = {}
		for _, v in pairs(candidateItems) do
			if(table.contains(playerInfo.ReplacedItems, v) == false and v ~= oldItemName) then
				table.insert(notDuplicatedItems, v)
            end
		end

	    if(#notDuplicatedItems > 0) then
	        targetItemName = table.random(notDuplicatedItems)
	    else
	    	targetItemName = table.random(candidateItems)
	    end

	    table.insert(playerInfo.ReplacedItems, oldItemName)

		if not bag:CreateItem(targetItemName, 1) then
			local newItem = CreateItem(targetItemName, nil, nil)
			CreateItemOnPositionSync(RandomVector(150), newItem)
		end
	end
end