function NotNull(entity)
    return entity and not entity:IsNull()
end

function IsNull(entity)
    return not entity or entity:IsNull()
end

function IsAlive(entity)
    return NotNull(entity) and entity.IsAlive ~= nil and entity:IsAlive()
end

function GetDistanceBetweenTwoVec2D(a, b)
    local xx = (a.x-b.x)
    local yy = (a.y-b.y)
    return math.sqrt(xx*xx + yy*yy)
end

function GetRadBetweenTwoVec2D(a,b)
	local y = b.y - a.y
	local x = b.x - a.x
	return math.atan2(y,x)
end

function GetAttributeByAttributeType(caster, attributeType)
    if attributeType == 0 then
        return caster:GetStrength()
    elseif attributeType == 1 then
        return caster:GetAgility()
    elseif attributeType == 2 then
        return caster:GetIntellect()
    end
end

function MoveUnitToTarget(unit,target,speed,func)
    local endTime = GameRules:GetGameTime() + 5
    unit:SetContextThink(DoUniqueString("MoveUnitToTarget"), 
        function()
            if GameRules:IsGamePaused() then return 0.03 end
            if unit==nil or target==nil or unit:IsNull() or target:IsNull() or GameRules:GetGameTime() >= endTime  then
                if func then func() end
                return nil
            end
            local vecCaster = unit:GetOrigin()
            local vecTarget = target:GetOrigin()
            if GetDistanceBetweenTwoVec2D(vecCaster,vecTarget) > 100 or GameRules:GetGameTime() >= endTime then
                local forward = (vecTarget - vecCaster):Normalized()
                unit:SetOrigin(vecCaster+forward*speed*0.03)
                return 0.03
            else
                FindClearSpaceForUnit(unit,unit:GetOrigin(),false)
                if func then func() end
                return nil
            end
        end, 
    0.03)
end

function MoveUnitToTargetJump(unit,target,speed,vUp,func)
    local endTime = GameRules:GetGameTime() + 5
    local distance = GetDistanceBetweenTwoVec2D(unit:GetOrigin(),target:GetOrigin())
    local t = distance/speed
    local upSpeed = vUp
    unit:SetContextThink(DoUniqueString("MoveUnitToTarget"), 
        function()
            if GameRules:IsGamePaused() then return 0.03 end
            if unit==nil or target==nil or unit:IsNull() or target:IsNull() or GameRules:GetGameTime() >= endTime  then
                if func then func() end
                return nil
            end
            upSpeed = upSpeed - 0.03 * (2*upSpeed/t)
            local vecCaster = unit:GetOrigin()
            local vecTarget = target:GetOrigin()
            if GetDistanceBetweenTwoVec2D(vecCaster,vecTarget) > 100 or GameRules:GetGameTime() >= endTime then
                local forward = (vecTarget - vecCaster):Normalized()
                unit:SetOrigin(vecCaster+forward*speed*0.03+Vector(0,0,upSpeed))
                return 0.03
            else
                FindClearSpaceForUnit(unit,unit:GetOrigin(),false)
                if func then func() end
                return nil
            end
        end, 
    0.03)
end

function MoveUnitToTargetPointJump(unit,targetPoint,speed,vUp,func)
    local endTime = GameRules:GetGameTime() + 5
    local distance = GetDistanceBetweenTwoVec2D(unit:GetOrigin(),targetPoint)
    local t = distance/speed
    local upSpeed = vUp
    unit:SetContextThink(DoUniqueString("MoveUnitToTarget"), 
        function()
            if GameRules:IsGamePaused() then return 0.03 end
            if unit==nil or unit:IsNull() or GameRules:GetGameTime() >= endTime then
                if func then func() end
                return nil
            end
            upSpeed = upSpeed - 0.03 * (2*upSpeed/t)
            local vecCaster = unit:GetOrigin()

            if GetDistanceBetweenTwoVec2D(vecCaster,targetPoint) > 100 or GameRules:GetGameTime() >= endTime then
                local forward = (targetPoint - vecCaster):Normalized()
                unit:SetOrigin(vecCaster+forward*speed*0.03+Vector(0,0,upSpeed))
                return 0.03
            else
                FindClearSpaceForUnit(unit,unit:GetOrigin(),false)
                if func then func() end
                return nil
            end
        end, 
    0.03)
end

function MoveUnitToTargetPoint(unit,targetpoint,speed,func)
    local endTime = GameRules:GetGameTime() + 5
    unit:SetContextThink(DoUniqueString("MoveUnitToTarget"), 
        function()
            if GameRules:IsGamePaused() then return 0.03 end
            if unit==nil or unit:IsNull() or GameRules:GetGameTime() >= endTime  then
                if func then func() end
                return nil
            end
            local vecCaster = unit:GetOrigin()
            local vecTarget = targetpoint
            if GetDistanceBetweenTwoVec2D(vecCaster,vecTarget) > 100 or GameRules:GetGameTime() >= endTime then
                local forward = (vecTarget - vecCaster):Normalized()
                unit:SetOrigin(vecCaster+forward*speed*0.03)
                return 0.03
            else
                FindClearSpaceForUnit(unit,unit:GetOrigin(),false)
                if func then func() end
                return nil
            end
        end, 
    0.03)
end

function MoveUnitToFaceFixedTime(unit,speed,time,func)
    local endTime = time
    unit:SetContextThink(DoUniqueString("MoveUnitToTarget"), 
        function()
            if GameRules:IsGamePaused() then return 0.03 end
            if unit==nil or unit:IsNull() then
                if func then func() end
                return nil
            end
            if endTime > 0 then
                unit:SetOrigin(unit:GetOrigin()+unit:GetForwardVector()*speed*0.03)
                endTime = endTime - 0.03
                return 0.03
            else
                FindClearSpaceForUnit(unit,unit:GetOrigin(),false)
                if func then func() end
                return nil
            end
        end, 
    0.03)
end

function FindItemByModifierPrefix(modifierPrefix, hero)
    if IsNull(hero) then return end
    for i = 1,5 do
        local modifier = hero:FindModifierByName(modifierPrefix.. tostring(i))
        if NotNull(modifier) then
            local item = modifier:GetAbility()
            if NotNull(item) then
                return item
            end
        end
    end
    return nil
end

function FindItemByModifierName(name, hero)
    if IsNull(hero) then return end
    local modifier = hero:FindModifierByName(name)
    if NotNull(modifier) then
        local item = modifier:GetAbility()
        if NotNull(item) then
            return item
        end
    end
    return nil
end

function GetRandomItemQuality(qualities, isConsumable)
    if qualities == nil or #qualities == 0 then
        return nil
    end

    local itemTable = {}
    for _, quality in ipairs(qualities) do
        local kindItems = ItemComposeClassifyTable[quality]
        if kindItems ~= nil then
            for kind, items in pairs(kindItems) do
                if (kind ~= ITEM_KIND_CONSUMABLE and isConsumable == false) or (kind == ITEM_KIND_CONSUMABLE and isConsumable) then
                    for _, itemName in pairs(items) do
                        table.insert(itemTable, itemName)
                    end
                end
            end
        end
    end

    return table.random(itemTable)
end

function GetRandomItemQualityKind(qualities, kind)
    if qualities == nil or #qualities == 0 then
        return nil
    end

    local itemTable = {}
    for _, quality in ipairs(qualities) do
        local items = ItemComposeClassifyTable[quality][kind]
        if items ~= nil then
            for _, itemName in pairs(items) do
                table.insert(itemTable, itemName)
            end
        end
    end

    return table.random(itemTable)
end

function RollLottery()
    local giftTable = {}
    local rateTotally = 0
    for i, v in pairs(STORE_CONFIG.LotteryGift) do
        rateTotally = rateTotally + v.rate
        table.insert(giftTable, rateTotally)
    end
    local rollNumber = RandomFloat(0, rateTotally)
    for i, v in pairs(giftTable) do
        if v > rollNumber then
            return i
        end
    end

    return 1
end
