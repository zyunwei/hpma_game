
if EquipCtrl == nil then
	EquipCtrl = RegisterController('equip')
	setmetatable(EquipCtrl,EquipCtrl)
end

local public = EquipCtrl

-- 装备位置
ITEM_KIND_GROUP_HAT_SLOT		= 0
ITEM_KIND_GROUP_CLOTHES_SLOT	= 1
ITEM_KIND_GROUP_SHOES_SLOT		= 2
ITEM_KIND_GROUP_GLOVES_SLOT		= 3
ITEM_KIND_GROUP_TRINKET_SLOT	= 4
ITEM_KIND_GROUP_WEAPON_SLOT 	= 5

-- 初始化
function public:init()
	Avalon:BindConform("bag_swap_item_from_inventory",  Dynamic_Wrap(self,"WhenSwapItem"), self)
end

-- 装备
function public:__call(hero, item)
	if not hero:IsHero() then return false end

	local slot = self:GetSlotForHero(hero, item)
	if slot >= 0 then
		local oldItem = hero:GetItemInSlot(slot)

		if oldItem == nil then
			return true,slot
		else
			return false
		end
	end

	return false
end

-- 获取装备的位置
function public:GetSlot(item)
	return self:GetSlotForItemName(item:GetAbilityName())
end

function public:GetSlotForItemName(itemname)
	local config = ItemConfig[itemname]
	if not config then return -1 end

	local group = ItemKindGroup[config["kind"]]

	if group == ITEM_KIND_GROUP_WEAPON then
		return ITEM_KIND_GROUP_WEAPON_SLOT
	elseif group == ITEM_KIND_GROUP_SHOES then
		return ITEM_KIND_GROUP_SHOES_SLOT
	elseif group == ITEM_KIND_GROUP_CLOTHES then
		return ITEM_KIND_GROUP_CLOTHES_SLOT
	elseif group == ITEM_KIND_GROUP_HAT then
		return ITEM_KIND_GROUP_HAT_SLOT
	elseif group == ITEM_KIND_GROUP_TRINKET then
		return ITEM_KIND_GROUP_TRINKET_SLOT
	elseif group == ITEM_KIND_GROUP_GLOVES then
		return ITEM_KIND_GROUP_GLOVES_SLOT
	end

	return -1
end

function public:GetSlotForHero(hero,item)
	if hero == nil or hero:IsNull() then
		return -1
	end
	
	local itemname = item:GetAbilityName()
	local config = ItemConfig[itemname]
	if not config then return -1 end

	local group = ItemKindGroup[config["kind"]]

	if group == ITEM_KIND_GROUP_WEAPON then
		return ITEM_KIND_GROUP_WEAPON_SLOT
	elseif group == ITEM_KIND_GROUP_SHOES then
		return ITEM_KIND_GROUP_SHOES_SLOT
	elseif group == ITEM_KIND_GROUP_CLOTHES then
		return ITEM_KIND_GROUP_CLOTHES_SLOT
	elseif group == ITEM_KIND_GROUP_HAT then
		return ITEM_KIND_GROUP_HAT_SLOT
	elseif group == ITEM_KIND_GROUP_TRINKET then
		return ITEM_KIND_GROUP_TRINKET_SLOT
	elseif group == ITEM_KIND_GROUP_GLOVES then
		return ITEM_KIND_GROUP_GLOVES_SLOT
	end

	return -1
end

function public:CanEquipItemToSlot(hero,item,slot)
	local itemname = item:GetAbilityName()
	local config = ItemConfig[itemname]
	if not config then return false end

	local group = ItemKindGroup[config["kind"]]
	if group == ITEM_KIND_GROUP_WEAPON then
		return slot == ITEM_KIND_GROUP_WEAPON_SLOT
	elseif group == ITEM_KIND_GROUP_SHOES then
		return slot == ITEM_KIND_GROUP_SHOES_SLOT
	elseif group == ITEM_KIND_GROUP_CLOTHES then
		return slot == ITEM_KIND_GROUP_CLOTHES_SLOT
	elseif group == ITEM_KIND_GROUP_HAT then
		return slot == ITEM_KIND_GROUP_HAT_SLOT
	elseif group == ITEM_KIND_GROUP_TRINKET then
		return slot == ITEM_KIND_GROUP_TRINKET_SLOT
	elseif group == ITEM_KIND_GROUP_GLOVES then
		return slot == ITEM_KIND_GROUP_GLOVES_SLOT
	end

	return false
end

function public:GetItemKindBySlot(slot)
	if slot == ITEM_KIND_GROUP_WEAPON_SLOT then
		return ITEM_KIND_WEAPON
	elseif slot == ITEM_KIND_GROUP_SHOES_SLOT then
		return ITEM_KIND_SHOES
	elseif slot == ITEM_KIND_GROUP_CLOTHES_SLOT then
		return ITEM_KIND_CLOTHES
	elseif slot == ITEM_KIND_GROUP_HAT_SLOT then
		return ITEM_KIND_HAT
	elseif slot == ITEM_KIND_GROUP_TRINKET_SLOT then
		return ITEM_KIND_TRINKET
	elseif slot == ITEM_KIND_GROUP_GLOVES_SLOT then
		return ITEM_KIND_GLOVES
	end
end

function public:WhenSwapItem(bagItem, inventorySlot)
	if not self:CanEquipItemToSlot(owner,bagItem,inventorySlot) then
		local preSlot = self:GetSlotForHero(owner,bagItem)

		if preSlot < 0 then
			return -1
		end

		if inventorySlot ~= preSlot then
			return preSlot
		end
	end

	return inventorySlot
end

function public:GetRandomLowQualityItem(hero)
	if IsNull(hero) then return -1 end
	local slot = -1
	local lowQuality = 6
	for i = 0, 5 do
		local quality = 0
		local item = hero:GetItemInSlot(i)
		if NotNull(item) then
			local config = ItemConfig[item:GetAbilityName()]
			if config then
				quality = config.quality
			end
		end
		if quality < lowQuality then
			lowQuality = quality
			slot = i
		end
	end
	return slot, lowQuality
end

function public:UpgradeEquip(hero)
	local slot, quality = self:GetRandomLowQualityItem(hero)
	local targetQuality
	if quality >= 0 and quality <= 4 then
		targetQuality = quality + 1
	else
		return
	end
	local item
	if targetQuality ~= 1 then
		hero:RemoveItem(hero:GetItemInSlot(slot))
	end
	item = GetRandomItemQualityKind({targetQuality}, self:GetItemKindBySlot(slot))
	if item then
		hero:AddItemByName(item)
	end
end