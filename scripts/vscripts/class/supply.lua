
if Supply == nil then
    Supply = class({})
end

local public = Supply

function public:constructor()
    self.__regionId = -1
    self.__quality = 0
    self.__effectIndex = -1
    self.__dropItems = {}
    self.__supplyBoxIndex = -1
    self.__isBeOpened = false
    self.__isHintOver = false
    self.__createTime = GameManager:GetGameTime()
    self.__position = Vector(0, 0, 128)
    self.__hintTime = 99999999
    self.__index = -1
end

function public:CreateSupply(position, dropItems, hintTime)
    self.__position = position
    for _, itemName in pairs(dropItems) do
        -- itemInfo.ItemName
        local itemCfg = ItemConfig[itemName]
        if itemCfg then
            self.__quality = math.max(itemCfg.quality, self.__quality)
            table.insert(self.__dropItems, itemName)
        end
    end
    local tempUnit = CreateUnitByName("npc_dummy_unit_invisible", self.__position, true, nil, nil, DOTA_TEAM_NEUTRALS)
    if tempUnit then
        tempUnit:SetHullRadius(0)
        self.__position = tempUnit:GetAbsOrigin()
        tempUnit:Destroy()
    end
    local effectPath = self:GetEffectPath()
    self.__effectIndex = ParticleManager:CreateParticle(effectPath, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(self.__effectIndex, 0, self.__position + Vector(0, 0, 10))
    self.__regionId = BlockadeSystem:GetPointRegionId(self.__position)
    self.__hintTime = hintTime
end

function public:CreateSupplyBox()
    local unit = CreateUnitByName("npc_supply_present", self.__position, true, nil, nil, DOTA_TEAM_NEUTRALS)
    if unit then
        unit:SetHullRadius(0)
        unit:SetAbility("ability_collection_unit")
        unit:AddNewModifier(unit, nil, "modifier_supply", nil )
        self.__supplyBoxIndex = unit:entindex()
    end
    self.__isHintOver = true

    return unit
end

function public:GetEffectPath()
    if self.__quality >= 5 then
        return "particles/ring_orange.vpcf"
    end
    if self.__quality >= 4 then
        return "particles/ring_purple.vpcf"
    end
    if self.__quality >= 3 then
        return "particles/ring_blue.vpcf"
    end
    return "particles/ring_green.vpcf"
end

function public:Destroy()
    ParticleManager:DestroyParticle(self.__effectIndex, true)
    CustomGameEventManager:Send_ServerToAllClients("destory_supply", {supplyIndex = self.__index})
    if self.__supplyBoxIndex > 0 then
        CustomNetTables:SetTableValue("TreasureIcon", tostring(self.__index), nil)
        local unit = EntIndexToHScript(self.__supplyBoxIndex)
        if unit then
            unit:Destroy()
        end
    end
end

function public:GetCreateTime()
    return self.__createTime
end

function public:GetIsHintOver()
    return self.__isHintOver
end

function public:CheckHintTimeOver()
    local nowTime = GameRules:GetGameTime()
    if nowTime > self.__createTime + self.__hintTime then
        return true
    end
    return false
end

function public:GetSupplyBoxIndex()
    return self.__supplyBoxIndex
end

function public:OpenSupply()
    if self.__isBeOpened == false then
        local unit = EntIndexToHScript(self.__supplyBoxIndex)
        if unit then
            unit:RemoveAbility("ability_collection_unit")
            unit:AddNewModifier(unit, nil, "modifier_ability_supply_opened", nil)
        end
    end
    self.__isBeOpened = true
end

function public:IsBeOpened()
    return self.__isBeOpened
end

function public:GetDropItems()
    return self.__dropItems
end

function public:RemoveItem(itemName)
    table.remove_value(self.__dropItems, itemName)
end

function public:AddRandomItemQuality()
    local qualities = {}
    if self.__quality == 2 then
        qualities = {2,3}
    elseif self.__quality == 3 then
        qualities = {3,4}
    elseif self.__quality == 4 then
        qualities = {4,5}
    end
    local itemName = GetRandomItemQuality(qualities, false)
    if itemName then
        table.insert(self.__dropItems, itemName)
    end
end