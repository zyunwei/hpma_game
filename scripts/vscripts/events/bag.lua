CustomEvents('xxwar_bag_swap_item', function(e, data)
	if data == nil or data.PlayerID == nil then return end
	if not data.from and not data.to then return end

	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end

	local hero = player:GetAssignedHero()
	if IsNull(hero) then return end

	local bag1 = BagCtrl(hero, data.from.bagName)
	local bag2 = BagCtrl(hero, data.to.bagName)
	local slot1 = data.from.slot
	local slot2 = data.to.slot
	if bag1 == nil or bag2 == nil then return end

	if bag1 == bag2 then
		bag1:SwapItem(slot1,slot2)
	else
		bag1:SwapItemForOtherBag(slot1,bag2,slot2)
	end
end)

CustomEvents('xxwar_bag_swap_item_from_inventory', function(e, data)
	if data == nil or data.PlayerID == nil then return end
	if not data.from then return end

	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end

	local hero = player:GetAssignedHero()
	if IsNull(hero) then return end

	local bag = BagCtrl(hero, data.from.bagName)
	local slot = data.from.slot

	if bag then
		bag:SwapItemFromInventory(slot, data.inventorySlot)
	end
end)

CustomEvents('xxwar_bag_equip_item', function(e, data)
	if data == nil or data.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end

	local hero = player:GetAssignedHero()
	if IsNull(hero) then return end

	local bag = BagCtrl(hero, data.bagName)
	local slot = data.slot

	if bag then
		local item = bag:GetItem(slot)
		if item then
			local inventorySlot = EquipCtrl:GetSlotForHero(hero,item)
			if inventorySlot >= 0 then
				bag:SwapItemFromInventory(slot, inventorySlot)
			else
				-- 如果不是可装备的物品，则尝试使用
				CustomItemSpellSystem:QuickCastAbility(hero, item)
			end
		end
	end
end)

CustomEvents('xxwar_bag_unload_equipment', function(e, data)
	if data == nil or data.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end

	local hero = player:GetAssignedHero()
	if IsNull(hero) then return end

	local bag = BagCtrl(hero, data.bagName)
	local inventorySlot = data.inventorySlot

	if bag then
		local item = hero:GetItemInSlot(inventorySlot)
		if item then
			local slot = bag:GetNoUseSlot()
			if slot > 0 then
				bag:SwapItemFromInventory(slot, inventorySlot)
			end
		end
	end
end)

CustomEvents('xxwar_bag_context_menu', function(e, data)
	if data == nil or data.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end

	local hero = player:GetAssignedHero()
	if IsNull(hero) then return end

	local item = EntIndexToHScript(data.item or -1)
	if not item then return end

	local config = ItemConfig[item:GetAbilityName()]
	local res = {}

	if config then
		if config["kind"] == ITEM_KIND_CONSUMABLE then
			res.is_consumable = true
		elseif ItemKindGroup[config["kind"]] >= ITEM_KIND_GROUP_WEAPON then
			res.is_equipment = true
		end
	end

	CustomGameEventManager:Send_ServerToPlayer(player, "xxwar_bag_context_menu_response", res)
end)

CustomEvents('xxwar_bag_discard', function(e, data)
	if data == nil or data.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end

	local hero = player:GetAssignedHero()
	if IsAlive(hero) == false then return end

	local bag = hero:GetBag()
	bag:Discard(data.slot or -1)
end)

CustomEvents('xxwar_bag_sell', function(e, data)
	if data == nil or data.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end

	local hero = player:GetAssignedHero()
	if IsAlive(hero) == false then return end

	local item = EntIndexToHScript(data.item or -1)
	if not item then return end
	
	local bag = hero:GetBag()
	bag:SellItem(item)
end)

CustomEvents('xxwar_bag_split_item', function(e, data)
	if data == nil or data.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end

	local hero = player:GetAssignedHero()
	if IsNull(hero) then return end

	local bag = hero:GetBag()
	bag:Split(data.slot or -1, data.num or 1)
end)

CustomEvents('xxwar_bag_merge_item', function(e, data)
	if data == nil or data.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end

	local hero = player:GetAssignedHero()
	if IsNull(hero) then return end

	local bag = hero:GetBag()
	bag:Merge(data.slot1 or -1, data.slot2 or -1)
end)

CustomEvents('xxwar_equipments_discard', function(e, data)
	if data == nil or data.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end

	local hero = player:GetAssignedHero()
	if IsAlive(hero) == false then return end

	if data.slot then
		local item = hero:GetItemInSlot(data.slot)
		if item and item:IsNull() == false then
			-- hero:DropItemAtPositionImmediate(item, hero:GetAbsOrigin())
			local dropItem = hero:TakeItem(item)
			local drop = CreateItemOnPositionSync(hero:GetAbsOrigin(), dropItem)
			local itemConfig = ItemConfig[dropItem:GetName()]
			if itemConfig and itemConfig.quality then
				DropperCtrl:ShowDropEffect(drop, itemConfig.quality)
			end

			local bag = hero:GetBag()
			bag:Update()
		end
	end
end)

CustomEvents('xxwar_bag_replace', function(e, data)
	if data == nil or data.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end

	local hero = player:GetAssignedHero()
	if IsNull(hero) then return end

	if data.slot == nil then
		ItemReplaceSystem:ReplaceItem(hero)
	else
		local bag = hero:GetBag()
		local item = bag:GetItem(data.slot or -1)
		ItemReplaceSystem:ReplaceItem(hero, item)
	end
end)
