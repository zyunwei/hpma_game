CustomEvents('compose_random_item', function(e, data)
	if data == nil or data.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end

	local hero = player:GetAssignedHero()
	if IsNull(hero) then return end

	ComposeSystem:ComposeRandom(hero, data.target_items or {}, data)
end)

CustomEvents('purchase_item', function(e, data)
	if data == nil or data.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end

	local hero = player:GetAssignedHero()
	if hero ==nil then return end

	local cost = GetItemCost(data.itemname)
	local itemConfig = ItemConfig[data.itemname]
    if itemConfig then
    	cost = itemConfig.price
    end

	if hero:SpendGold(cost) then
		EmitSoundOnClient("General.Buy", PlayerResource:GetPlayer(hero:GetPlayerID()))

		hero:AddOwnerItemByName(data.itemname)
	else
		return Avalon:Throw(hero,"xxwar_not_enough_gold")
	end
end)
