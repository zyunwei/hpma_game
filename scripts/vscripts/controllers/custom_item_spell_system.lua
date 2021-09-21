
if CustomItemSpellSystem == nil then
	CustomItemSpellSystem = RegisterController('custom_item_spell_system')
	CustomItemSpellSystem.__heroes = {}
	CustomItemSpellSystem.__dummy_list = {}
	setmetatable(CustomItemSpellSystem,CustomItemSpellSystem)
end

local public = CustomItemSpellSystem

Custom_Item_Spell_System_Slot_1 = 12
Custom_Item_Spell_System_Slot_2 = 13
Custom_Item_Spell_System_Slot_3 = 14
Custom_Item_Spell_System_Slot_4 = 15
Custom_Item_Spell_System_Slot_5 = 16
Custom_Item_Spell_System_Slot_6 = 17
Custom_Item_Spell_System_Slot_Min = 12
Custom_Item_Spell_System_Slot_Max = 17
Custom_Item_Spell_System_QuickCastSlot = 22
Custom_Item_Spell_Prefix = "custom_item_spell_system_"

function public:init()
	_G['AbilitiesKV'] = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
	Avalon:Listen("bag_changed", Dynamic_Wrap(self,"OnBagChanged"), self)
end

function public:SetSlot(hero, slot, item)
	if slot < Custom_Item_Spell_System_Slot_Min then return end

	local hasItemInInventory = hero:HasItem(item)

	local bag = hero:GetBag()
	if not bag or not bag:HasItem(item) then 
		if not hasItemInInventory then
			return
		end
	end

	local itemname = item:GetAbilityName()
	local abilityName = 'custom_' .. itemname
	if not AbilitiesKV[abilityName] then return end

	local oldAbility = hero:GetAbilityByIndex(slot)
	if not oldAbility or oldAbility:GetAbilityName() == abilityName then return end

	local hasSwap = false
	for i=Custom_Item_Spell_System_Slot_Min,Custom_Item_Spell_System_Slot_Max do
		local ability = hero:GetAbilityByIndex(i)
		if ability and ability:GetAbilityName() == abilityName and i ~= slot then
			self:SwapAbilities(hero,i,slot)
			hasSwap = true
			break
		end
	end

	-- 防止技能错位
	hero:CheckAbilitySlots()
	if not hasSwap then
		hero:RemoveAbilityByHandle(oldAbility)
		hero:SetAbility(abilityName)
		self:SetSlotItemIndex(hero, slot, item:GetEntityIndex())
	end
end

-- 获取槽位上绑定的物品index
function public:GetItemIndex(hero, slot)
	if slot < Custom_Item_Spell_System_Slot_Min then return -1 end

	local heroItemAbilities = self.__heroes[hero:GetEntityIndex()]
	if heroItemAbilities == nil then
		heroItemAbilities = {}
		self.__heroes[hero:GetEntityIndex()] = heroItemAbilities
	end

	return heroItemAbilities[slot] or -1
end

-- 绑定物品index
function public:SetSlotItemIndex(hero, slot, itemIndex)
	if slot < Custom_Item_Spell_System_Slot_Min then return end

	local heroItemAbilities = self.__heroes[hero:GetEntityIndex()]
	if heroItemAbilities == nil then
		heroItemAbilities = {}
		self.__heroes[hero:GetEntityIndex()] = heroItemAbilities
	end

	heroItemAbilities[slot] = itemIndex

	CustomNetTables:SetTableValue("Common", Custom_Item_Spell_Prefix .. hero:GetEntityIndex(), heroItemAbilities)
end

-- 替换位置
function public:SwapAbilities(hero, slot1,slot2)
	if slot1 == slot2 then return end
	if slot1 < Custom_Item_Spell_System_Slot_Min then return end
	if slot2 < Custom_Item_Spell_System_Slot_Min then return end

	local ability1 = hero:GetAbilityByIndex(slot1)
	local ability2 = hero:GetAbilityByIndex(slot2)
	if not ability1 or not ability2 then return end

	hero:SwapAbilities(ability1:GetAbilityName(), ability2:GetAbilityName(), true, true)

	local temp = self:GetItemIndex(hero, slot1)
	self:SetSlotItemIndex(hero, slot1, self:GetItemIndex(hero, slot2))
	self:SetSlotItemIndex(hero, slot2, temp)
end

function public:QuickCastAbility(hero, item)
	if item:GetBehavior() ~= DOTA_ABILITY_BEHAVIOR_NO_TARGET then
		return
	end

	local itemname = item:GetAbilityName()
	local abilityName = 'custom_' .. itemname
	if not AbilitiesKV[abilityName] then return end

	if(hero:IsMuted()) then
        return
    end

	if hero:HasAbility(abilityName) then
		local ability = hero:FindAbilityByName(abilityName)
		ability:CastAbility()
	else
		local quickCastAbility = hero:GetAbilityByIndex(Custom_Item_Spell_System_QuickCastSlot)
		if quickCastAbility ~= nil then
			hero:RemoveAbilityByHandle(quickCastAbility)
		end

		quickCastAbility = hero:SetAbility(abilityName)
        self:SetSlotItemIndex(hero, Custom_Item_Spell_System_QuickCastSlot, item:GetEntityIndex())
		quickCastAbility:CastAbility()

		if IsNull(quickCastAbility) == false then
			hero:RemoveAbilityByHandle(quickCastAbility)
			hero:SetAbility("xxwar_empty_ability_" .. Custom_Item_Spell_System_QuickCastSlot)
		end
	end
end

function public:Release(hero, slot)
	if slot < Custom_Item_Spell_System_Slot_Min then return end

	local ability = hero:GetAbilityByIndex(slot)
	if ability then hero:RemoveAbilityByHandle(ability) end

	for i = 0, Custom_Item_Spell_System_QuickCastSlot do
		local checkAbility = hero:GetAbilityByIndex(i)
		if IsNull(checkAbility) == false and string.find(checkAbility:GetAbilityName(), Custom_Item_Spell_Prefix) == 1 then
			if i < Custom_Item_Spell_System_Slot_Min or i > Custom_Item_Spell_System_Slot_Max then
				hero:RemoveAbilityByHandle(checkAbility)
            	hero:AddAbility("xxwar_empty_ability_" .. i)
			end
		end
	end

	local addCount = 0
	for i = Custom_Item_Spell_System_Slot_Min, Custom_Item_Spell_System_Slot_Max do
		local checkAbility = hero:GetAbilityByIndex(i)
		if IsNull(checkAbility) then
			addCount = addCount + 1
		elseif string.find(checkAbility:GetAbilityName(), "xxwar_empty_ability_") == 1 then
			hero:RemoveAbilityByHandle(checkAbility)
			addCount = addCount + 1
		end
	end

    for i = 1, 6 do
        if not hero:HasAbility(Custom_Item_Spell_Prefix .. i) then
            hero:SetAbility(Custom_Item_Spell_Prefix .. i)
            addCount = addCount - 1
            if addCount <= 0 then
            	break
            end
        end
	end

	self:SetSlotItemIndex(hero, slot, -1)
	
	-- 防止技能错位
	hero:CheckAbilitySlots()
end

-- 背包发生改变
function public:OnBagChanged(hero)
	for i = Custom_Item_Spell_System_Slot_Min, Custom_Item_Spell_System_Slot_Max do
		local ability = hero:GetAbilityByIndex(i)
		if ability and string.find(ability:GetAbilityName(), Custom_Item_Spell_Prefix) == nil and ability.GetBindItem then
			local item = ability:GetBindItem()
			local bag = hero:GetBag()
			local hasItemInInventory = hero:HasItem(item)

			if not item or item:IsNull() or not bag:HasItem(item) then
				if not hasItemInInventory then
					self:Release(hero,i)
				end
			end
		end
	end
end

function CustomItemSpellSystem__OnSpellStart(self)
	local caster = self:GetCaster()

	local item = self:GetBindItem()
	if not item or item:IsNull() then return end

	if item:GetBehavior() == DOTA_ABILITY_BEHAVIOR_CHANNELLED then
		self:OnCustomSpellStart(item)
		return
	end

	if item:IsStackable() and item:GetCurrentCharges() > 0 then
		self:OnCustomSpellStart(item)
		local bag = caster:GetBag()
		if NotNull(item) then
			CustomItemSpellSystem:StartItemCooldown(caster, item, self)
			item:SetCurrentCharges(item:GetCurrentCharges() - 1)
			if item:GetCurrentCharges() <= 0 and not item:IsPermanent() then
				if NotNull(self) then
					CustomItemSpellSystem:Release(caster, self:GetAbilityIndex())	
				end
				bag:RemoveItem(item)
			end
		end
		bag:Update()
	elseif not item:IsStackable() then
		self:OnCustomSpellStart(item)
		local bag = caster:GetBag()
		if NotNull(item) then
			CustomItemSpellSystem:StartItemCooldown(caster, item, self)
			if not item:IsPermanent() then
				if NotNull(self) then
					CustomItemSpellSystem:Release(caster, self:GetAbilityIndex())
				end
				bag:RemoveItem(item)
			end
		end
		bag:Update()
	end
end

function CustomItemSpellSystem__OnChannelFinish(self, bInterrupted)
	local caster = self:GetCaster()

	local item = self:GetBindItem()
	if not item or item:IsNull() then return end

	if not bInterrupted then
		if item:IsStackable() and item:GetCurrentCharges() > 0 then
			self:OnCustomChannelFinish(item, bInterrupted)
			CustomItemSpellSystem:StartItemCooldown(caster, item, self)

			local bag = caster:GetBag()
			item:SetCurrentCharges(item:GetCurrentCharges() - 1)

			if item:GetCurrentCharges() <= 0 and not item:IsPermanent() then
				if NotNull(self) then
					CustomItemSpellSystem:Release(caster, self:GetAbilityIndex())
					bag:RemoveItem(item)
				end
			end

			bag:Update()
		elseif not item:IsStackable() then
			self:OnCustomChannelFinish(item, bInterrupted)
			CustomItemSpellSystem:StartItemCooldown(caster, item, self)
		end
	else
		self:OnCustomChannelFinish(item, bInterrupted)
		CustomItemSpellSystem:StartItemCooldown(caster, item, self)
	end
		
end

function CustomItemSpellSystem__GetBindItem(self)
	return EntIndexToHScript(CustomItemSpellSystem:GetItemIndex(self:GetCaster(), self:GetAbilityIndex()))
end

function public:StartItemCooldown(hero, item, ability)
	if IsNull(hero) or IsNull(item) or IsNull(ability) then return end

	local dummy_list = self.__dummy_list
	if dummy_list == nil then
		dummy_list = {}
		self.__dummy_list = dummy_list
	end

	local itemname = item:GetAbilityName()
	hero:GetBag():Look(function(bagSlot,itemIndex,bagItem)
		if NotNull(bagItem) and bagItem:GetAbilityName() == itemname then
			local hasStartCooldown = false
			for i,dummy in ipairs(dummy_list) do
				repeat
					if dummy:IsNull() then return end

					if dummy:HasItemInInventory(itemname) then
						for i=0,5 do
							local slot_item = dummy:GetItemInSlot(i)
							if slot_item and not slot_item:IsNull() and slot_item:GetEntityIndex() == itemIndex then
								slot_item:StartCooldown(ability:GetCooldownTimeRemaining())
								hasStartCooldown = true
							end
						end
						break
					end

					local num = 0
					for i=0,5 do
						local slot_item = dummy:GetItemInSlot(i)
						if slot_item and not slot_item:IsNull() then
							num = num + 1
						end
					end

					if hasStartCooldown then break end

					if num < 6 then
						dummy:AddItem(bagItem)
						bagItem:StartCooldown(ability:GetCooldownTimeRemaining())
						hasStartCooldown = true
						break
					end
				until true
				if hasStartCooldown then return end
			end

			if not hasStartCooldown then
				local dummy = CreateUnitByName("avalon_dummy", Vector(0,0,0), true, nil, nil, hero:GetTeam())
				dummy:SetOwner(hero)
				dummy:AddNoDraw()
				dummy:AddNewModifier(hero, nil, "modifier_invulnerable", nil)
				dummy:AddNewModifier(hero, nil, "modifier_phased", nil)

				dummy:AddItem(bagItem)
				bagItem:StartCooldown(ability:GetCooldownTimeRemaining())

				table.insert(dummy_list,dummy)
			end
		end
	end)
end

function public:GetBaseClass()
	return class({
		OnSpellStart=CustomItemSpellSystem__OnSpellStart,
		GetBindItem=CustomItemSpellSystem__GetBindItem,
		OnChannelFinish=CustomItemSpellSystem__OnChannelFinish,
	})
end

function public:GetBuffIcon(buff, defaultIcon)
    local texture = ""
    if buff == nil or buff:IsNull() or buff.GetAbility == nil then
        return texture
    end
    local ability = buff:GetAbility()
    if ability ~= nil and ability:IsNull() == false then
        texture = ability:GetName()
        if string.find(texture, "custom_item_") == 1 then
            texture = string.gsub(texture, "custom_item_", "item_")
        end
    else
    	texture = defaultIcon
    end

    return texture
end