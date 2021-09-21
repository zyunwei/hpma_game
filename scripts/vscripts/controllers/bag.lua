
if BagCtrl == nil then
	BagCtrl = RegisterController('bag')
	BagCtrl.player_bag={}
	setmetatable(BagCtrl,BagCtrl)
end

BAG_SLOT_COUNT = 12
BAG_NAME_COMMON = 1 --普通背包

local public = BagCtrl

-- 获取英雄背包
function CDOTA_BaseNPC_Hero:GetBag()
	return public(self,BAG_NAME_COMMON)
end

-- 获取英雄的背包
function public:__call(hero, bagName)
	assert(hero and hero:IsHero(), 'Invalid hero')

	local playerBag = self.player_bag[hero:GetSteamID()]

	if playerBag == nil then
		playerBag = {}
		self.player_bag[hero:GetSteamID()] = playerBag
	end

	if playerBag[bagName] == nil then
		if bagName == BAG_NAME_COMMON then
			playerBag[bagName] = CBag(BAG_NAME_COMMON, hero, BAG_SLOT_COUNT, 1, 12)
		end
	end

	return playerBag[bagName]
end

-- 初始化
function public:init()
	Avalon:Listen("bag_changed", Dynamic_Wrap(self,"OnBagChanged"), self)
	Avalon:Listen("bag_sell_item", Dynamic_Wrap(self,"OnSellItem"), self)
	Avalon:Listen("bag_new_item", Dynamic_Wrap(self,"OnNewItem"), self)
	Avalon:BindConform("bag_sell_item", Dynamic_Wrap(self,"WhenSellItem"), self)
end

-- 背包发生改变
function public:OnBagChanged(hero, bag)
	self:Update(hero, bag:GetBagName())
end

-- 当前添加新的物品
function public:OnNewItem(hero, bag, item)
	for i=Custom_Item_Spell_System_Slot_Min,Custom_Item_Spell_System_Slot_Max do
		local ability = hero:GetAbilityByIndex(i)
		if ability == nil or string.find(ability:GetAbilityName(),"custom_item_spell_system") == 1 then
			CustomItemSpellSystem:SetSlot(hero, i, item)
			break
		end
	end
end

function public:OnSellItem(hero, itemname, charges)
	local playerId = hero:GetPlayerID()
	if playerId == nil then return end
	EmitSoundOnClient("General.Sell", PlayerResource:GetPlayer(playerId))
end

-- 当出售物品
function public:WhenSellItem(hero, item)
	local data = ItemConfig[item:GetAbilityName()]
	if not data then return false end

	local amount = item:GetCost()
	local charges = item:GetCurrentCharges()

	if not item:IsStackable() then
		charges = 1
	end

	if amount <= 0 then
		if data["quality"] <= 3 then
			amount = 100
		elseif data["quality"] <= 5 then
			amount = 300
		elseif data["quality"] <= 8 then
			amount = 900
		end
	end

	if data["kind"] == ITEM_KIND_MATERIAL then
		amount = math.floor(amount / 10)
	end

	hero:GiveGold(amount*charges)
	return true
end

-- DOTA物品过滤
function public:InventoryFilter(keys)
	local hInventoryParent = EntIndexToHScript(keys.inventory_parent_entindex_const)
	local hItem = EntIndexToHScript(keys.item_entindex_const)

	if IsNull(hInventoryParent) or IsNull(hItem) then
		return true
	end

	local container = hItem:GetContainer()

	local itemName = hItem:GetAbilityName()

	if itemName == 'item_tpscroll' then
		return true
	end

    if itemName == "item_enchanted_mango" then
        return false
    end

    local itemConfig = ItemConfig[itemName]
    if itemConfig and itemConfig["autoUse"] == 1 and GameRules.XW.EnableAutoUse == true then
    	CustomItemSpellSystem:QuickCastAbility(hInventoryParent, hItem)
        return false
    end

    -- 马甲单位直接跳过
    if hInventoryParent:GetUnitName() == "avalon_dummy" or hInventoryParent.GetBag == nil then
        return true
    end

	local bag = hInventoryParent:GetBag()

	-- 如果可以直接装备
	local canEquip,slot = EquipCtrl(hInventoryParent,hItem)
	if canEquip and slot >= 0 then
		AttributesCtrl(hItem)
		keys.suggested_slot = slot
		bag:Update()
		return true
	end

	local realItemName = nil
	if itemName == "item_virtual_weapon_4" then
		realItemName = table.random(ItemComposeClassifyTable[4][ITEM_KIND_WEAPON])
	elseif itemName == "item_virtual_trinket_4" then
		realItemName = table.random(ItemComposeClassifyTable[4][ITEM_KIND_TRINKET])
	elseif itemName == "item_virtual_shoes_4" then
		realItemName = table.random(ItemComposeClassifyTable[4][ITEM_KIND_SHOES])
	elseif itemName == "item_virtual_hat_4" then
		realItemName = table.random(ItemComposeClassifyTable[4][ITEM_KIND_HAT])
	elseif itemName == "item_virtual_gloves_4" then
		realItemName = table.random(ItemComposeClassifyTable[4][ITEM_KIND_GLOVES])
	elseif itemName == "item_virtual_clothes_4" then
		realItemName = table.random(ItemComposeClassifyTable[4][ITEM_KIND_CLOTHES])
	end

	if realItemName ~= nil then
		local owner = hItem:GetOwner()
		hItem:RemoveSelf()
		hItem = CreateItem(realItemName, owner, owner)
		hItem:SetOwner(owner)
	end

	-- 否则尝试放入背包
	if not bag:AddItem(hItem) then
		-- print("can not add item:" .. itemName)
		if container and not container:IsNull() then
			CreateItemOnPositionSync(container:GetOrigin(), hItem)
		else
			CreateItemOnPositionSync(hInventoryParent:GetOrigin() + RandomVector(100), hItem)
		end
	else
		-- 提示是否装备
		if hItem ~= nil and hItem:IsNull() == false and hItem.IsItem and hItem:IsItem() then
			local currentSlotIndex = EquipCtrl:GetSlot(hItem)
			if currentSlotIndex ~= -1 then
				local currentItem = hInventoryParent:GetItemInSlot(currentSlotIndex)
				if currentItem ~= nil then
					local newItemInfo = ItemConfig[itemName]
					local currentItemInfo = ItemConfig[currentItem:GetName()]

					if newItemInfo ~= nil and currentItemInfo ~= nil then
						if newItemInfo.quality > currentItemInfo.quality then
							CustomGameEventManager:Send_ServerToPlayer(hInventoryParent:GetPlayerOwner(), 
								"item_swap_alert", { new_item = itemName, current_item = currentItem:GetName(), slot = bag:GetItemSlotIndex(hItem) })
						end
					end
				end
			end
		end
	end

	return false
end

function public:UpdateBag(hero, bagName)
	CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "bag_event_update", AvalonEmptyTable)
end

function public:Update(hero, bagName)
	DelayDispatch(0.15, hero:GetEntityIndex(), self.UpdateBag, self, hero, bagName)
end