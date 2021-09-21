if ComposeSystem == nil then
	ComposeSystem = RegisterController('compose_system')
	setmetatable(ComposeSystem,ComposeSystem)
end

local public = ComposeSystem

function public:ComposeRandom(hero, requestItem, data)
	local bag = hero:GetBag()
	if not bag then return false end
	local quality = -1
	local kinds = {}
	local targetKind = -1
	local requestItemHashs = {}

	local composeType = tostring(data.compose_type)
	local useEquipment = data.use_equipment
	local composeItemName = tostring(data.item_name)
	for _, itemName in pairs(requestItem) do
		local itemInfo = ItemConfig[itemName]
		if quality ~= -1 and itemInfo.quality ~= quality then
			return false
		end
		quality = itemInfo.quality
		kinds[itemInfo.kind] = true
		targetKind = itemInfo.kind
		if requestItemHashs[itemName] == nil then
			requestItemHashs[itemName] = 0
		end
		requestItemHashs[itemName] = requestItemHashs[itemName] +  1
	end
	if composeType == "equip_compose" and quality + 1 > 5 then
		return false
	end
	if composeType == "consumable_compose" and quality + 1 > 4 then
		return false
	end
	if composeType == "composeType" and quality + 1 ~= 4 then
		return false
	end
	local temp = {}
	for itemName,count in pairs(requestItemHashs) do
		table.insert(temp, {itemname=itemName, count=count})
	end
	requestItem = temp

	local allKinds = {ITEM_KIND_WEAPON, ITEM_KIND_SHOES, ITEM_KIND_CLOTHES, ITEM_KIND_HAT, ITEM_KIND_TRINKET, ITEM_KIND_GLOVES}
	if table.count(kinds) > 1 or string.find(composeItemName, "item_virtual_random_") == 1 then
		targetKind = table.random(allKinds)
	end

	local targetItemName = ""
	local itemComposeClassify = ItemComposeClassifyTable[quality + 1]
	if itemComposeClassify == nil then
		itemComposeClassify = {}
	end

	if composeType == "consumable_compose" then
		local candidateItems = itemComposeClassify[ITEM_KIND_CONSUMABLE]
		targetItemName = table.random(candidateItems)
	else
		local candidateItems = itemComposeClassify[targetKind]
		targetItemName = table.random(candidateItems)
	end
	if targetItemName == "" then
		return false
	end
	local useEquipItems = {}
	local composeItem = {}
	local conform = {}	

	-- 使用装备栏内物品
	if useEquipment and useEquipment ~= 0 then
		for i, t in pairs(requestItem) do
			for slotIndex = 0, 5 do 
				local item = hero:GetItemInSlot(slotIndex)
				if item ~= nil and item:GetName() == t.itemname then
					table.insert(useEquipItems, { itemName = t.itemname, slotIndex = slotIndex, item = item })
				end
			end
		end
	end

	local requestBagItems = {}
	for i, v in pairs(requestItem) do
		if table.find(useEquipItems, "itemName", v.itemname) == nil then
			table.insert(requestBagItems, { itemname = v.itemname, count = v.count })
		elseif v.count > 1 then
			table.insert(requestBagItems, { itemname = v.itemname, count = v.count - 1 })
		end
    end

	for i,t in pairs(requestBagItems) do
		local items = {}
		bag:Look(function(bagSlot,itemIndex,item)
			if item:GetAbilityName() == t.itemname then
				if item:IsStackable() then
					local list = items['list']
					if list == nil then
						list = {}
						items['list'] = list
						items['count'] = 0
					end

					if conform[t.itemname] == nil then
						conform[t.itemname] = bag:GetNumItemInBag(t.itemname)
					end

					local num = conform[t.itemname]
					if num <= 0 then return true end

					local charges = item:GetCurrentCharges()
					local remaining_require = t.count - items.count

					if charges >= remaining_require then
						items.count = items.count + remaining_require
						conform[t.itemname] = num - remaining_require
					else
						items.count = items.count + charges
						conform[t.itemname] = num - charges
					end
					table.insert(list,bagSlot)

					if items.count >= t.count then
						return true
					end

				elseif conform[bagSlot] == nil then
					conform[bagSlot] = true
					items['IsStackable'] = false

					local list = items['list']
					if list == nil then
						list = {}
						items['list'] = list
						items['count'] = 0
					end

					table.insert(list,bagSlot)
					items.count = items.count + 1

					if items.count >= t.count then
						return true
					end
				end
			end
		end)
		composeItem[i] = items
	end

	for i, t in pairs(requestBagItems) do
		local items = composeItem[i]
		if (items.count or 0) < t.count then
			return Avalon:Throw(hero,"xxwar_msg_materials_not_enough",false)
		end
	end

	for _, v in pairs(useEquipItems) do
		local item = hero:GetItemInSlot(v.slotIndex)
		if item ~= nil then
			hero:RemoveItem(item)
		end
	end

	for k,items in pairs(composeItem) do
		if items.IsStackable == false then
			for _,bagSlot in pairs(items.list) do
				bag:RemoveItemInSlot(bagSlot)
			end
		else
			for _,bagSlot in pairs(items.list) do
				bag:CostItemInSlot(bagSlot,items.count)
			end
		end
	end

	hero:AddOwnerItemByName(targetItemName)
	
	CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "xxwar_new_item_tips", {itemname=targetItemName})
	CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "xxwar_compose_item_finished", {ID=0})
end
