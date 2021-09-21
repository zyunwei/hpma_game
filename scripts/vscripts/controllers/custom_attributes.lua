
if AttributesCtrl == nil then
	AttributesCtrl = RegisterController('custom_attributes')
	AttributesCtrl.__player_hero_attributes = {}
	AttributesCtrl.__items = {}
	setmetatable(AttributesCtrl,AttributesCtrl)
end

local public = AttributesCtrl

-- 获取实体的属性类
function public:__call(entity)
	if IsNull(entity) then
		return
	end

    if entity:IsBaseNPC() and entity:IsHero() and entity.IsRealHero ~= nil and entity:IsRealHero() then
        if not entity:HasModifier("modifier_custom_attributes") then
	        entity:AddNewModifier(entity, nil, "modifier_custom_attributes", nil)
	    end
    end

    local itemInfo = nil
	if entity.IsItem and entity:IsItem() then
		-- 非装备道具不附加属性
		local itemName = entity:GetAbilityName()
		itemInfo = ItemConfig[itemName]
		if not itemInfo then
			return
		end
		if not ItemKindEquips[itemInfo.kind] then
			return
		end
	end

	if entity.__CustomAttributes == nil then
		entity.__CustomAttributes = {}
		CustomNetTables:SetTableValue("CustomAttributes", tostring(entity:GetEntityIndex()),{})

		if entity:IsBaseNPC() and entity:IsHero()  then
			entity.__CustomAttributesChildren = {}
			entity.__All_Attributes = {}
		else
			if itemInfo ~= nil then
				-- 附加词缀
				if ItemRandomAffix[itemInfo.kind] ~= nil then
					local playerId = nil
					local owner = entity:GetOwner()
					if NotNull(owner) and owner.GetPlayerID ~= nil then
						playerId = owner:GetPlayerID()
					end

					local affixList = {}
					for _, affix in pairs(ItemRandomAffix[itemInfo.kind]) do
						if ItemAffixAbilityMapping[affix] ~= nil then
							if playerId ~= nil then
								local hasCard = false
								for _, cardName in pairs(ItemAffixAbilityMapping[affix]) do
									if CardGroupSystem:CheckPlayerHasCard(playerId, cardName) then
										table.insert(affixList, affix)
										break
									end
								end
							end
						else
							table.insert(affixList, affix)	
						end
					end

					affixList = table.shuffle(affixList)

					local affixCount = 0
					if itemInfo.quality == ITEM_QUALITY_S then
						affixCount = 2
					elseif itemInfo.quality == ITEM_QUALITY_A or itemInfo.quality == ITEM_QUALITY_B or itemInfo.quality == ITEM_QUALITY_C then
						affixCount = 1
					end

					if affixCount > 0 then
						for i = 1, affixCount do
							local selectAffixName = affixList[i]
							if selectAffixName ~= nil then
								local affixValueList = ItemAffixValues[selectAffixName]
								if affixValueList then
									affixValue = affixValueList[itemInfo.quality]
									if affixValue then
										entity:SetCustomAttribute(selectAffixName, affixValue)
									end
								end
							end
						end
					end
				end
			end
		end
	end
end
