require "libs.geometry"

if Region == nil then
    Region = class({})
end

function Region:constructor(regionId)
    self.__name = ""
    self.__regionId = regionId
    self.__shapePoints = {}
    self.__lines = {}
    self.__containItems = {}
    self.__minX = 9999999
    self.__maxX = -1
    self.__minY = 9999999
    self.__maxY = -1
    self.__isVaildRegion = false
    self.__isBlockade = false
    self.__willBeBlockade = false
end

function Region:AddRegionPoint(point)
    if point == nil then
        return
    end
    table.insert(self.__shapePoints, point)
    self.__minX = math.min(point.x , self.__minX)
    self.__maxX = math.max(point.x , self.__maxX)
    self.__minY = math.min(point.y , self.__minY)
    self.__maxY = math.max(point.y , self.__maxY)

    if #self.__shapePoints >= 3 and (self.__maxX - self.__minX) > 0 and (self.__maxY - self.__minY) then
        self.__isVaildRegion = true
    end

    -- Geometry:SortPolygonPoints(self.__shapePoints)
end

function Region:SortPoints()
    local center = Geometry:ApproximateCenterPoint(self.__shapePoints)
    table.sort(self.__shapePoints, function (a,b) return Geometry:PolygonPointCmp(a, b, center) end)

    self.__lines = {}
    local n = #self.__shapePoints
    table.insert(self.__lines, {p1 = self.__shapePoints[n], p2 = self.__shapePoints[1]})
    for i = 1, n - 1 do
        table.insert(self.__lines, {p1 = self.__shapePoints[i], p2 = self.__shapePoints[i + 1]})
    end
    for i = 1, n do
        local v = Vector2D:Sub(self.__lines[i].p2, self.__lines[i].p1)
        local d = v:Length()
        self.__lines[i].v = v
        self.__lines[i].d = d
    end
end

function Region:IsInRegion(point)
    if point == nil then return false end
    if self:CheckInBoundBox(point) == false then
        return false
    end

    return Geometry:IsPointInPolygon(self.__shapePoints, point)
end

function Region:CheckInBoundBox(point)
    return not (point.x < self.__minX or point.x > self.__maxX or point.y < self.__minY or point.y > self.__maxY)
end

function Region:IsVaildRegion()
    return self.__isVaildRegion
end

function Region:BlockadRegion()
    self.__isBlockade = true
    self.__willBeBlockade = false
end

function Region:BlockadeWarning()
    self.__isBlockade = false
    self.__willBeBlockade = true
end

function Region:IsBlockade()
    return self.__isBlockade or self.__isVaildRegion == false
end

function Region:IsBlockadeWarning()
    return self.__willBeBlockade
end

function Region:RandomPointInRegion()
    for i = 1, 100 do
        local lineIndex1, lineIndex2 = self:RandomTowLines()
        if lineIndex1 == nil or lineIndex2 == nil then
            print("lineIndex1 or lineIndex2 is nil")
            break
        end
        local p1 = self:RandomPointInLine(self.__lines[lineIndex1])
        local p2 = self:RandomPointInLine(self.__lines[lineIndex2])
        local generateLine = {p1 = p1, p2 = p2, v = Vector2D:Sub(p2, p1)}
        local pos = self:RandomPointInLine(generateLine)
        local point = Vector(pos.x, pos.y, 512)
        if self:IsInRegion(Vector(point.x, point.y, 512)) then
            if CheckCanSpawnUnit(point) then
                return point
            end
        end
    end
    return Vector(0, 0, 512)
end

function Region:RandomTowLines()
    local sumValue = 0
    for i = 1, #self.__lines do
        if self.__lines[i].d == nil then
            print("Region.__lines[i].d is nil")
            return nil, nil
        end
        sumValue = sumValue + self.__lines[i].d
    end

    local randomValue = math.random()
    local sumProb = 0
    local targetLine1 = 1
    for i = 1, #self.__lines do
        local p = self.__lines[i].d/sumValue
        if sumProb + p >= randomValue then
            targetLine1 = i
            break
        end
        sumProb = sumProb + p
    end

    local candidateLines = {}
    sumValue = 0
    for i = 1, #self.__lines do
        if i ~= targetLine1 then
            local v1 = Vector2D:Sub(self.__lines[i].p1, self.__lines[targetLine1].p1)
            local v2 = Vector2D:Sub(self.__lines[i].p1, self.__lines[targetLine1].p2)
            local v3 = Vector2D:Sub(self.__lines[i].p2, self.__lines[targetLine1].p1)
            local v4 = Vector2D:Sub(self.__lines[i].p2, self.__lines[targetLine1].p2)
            local w = math.min(v1:Length(), v2:Length())
            w = math.min(w, v3:Length())
            w = math.min(w, v4:Length())
            table.insert(candidateLines, {p1 = self.__lines[i].p1, p2 = self.__lines[i].p2, v = self.__lines[i].v , d = self.__lines[i].d, w = w})
            sumValue = sumValue + w
        else
            table.insert(candidateLines, {})
        end
    end

    randomValue = math.random()
    sumProb = 0
    local targetLine2 = #candidateLines
    for i = 1, #candidateLines do
        if i ~= targetLine1 then
            local p = candidateLines[i].w/sumValue
            if sumProb + p >= randomValue then
                targetLine2 = i
                break
            end
            sumProb = sumProb + p
        end
    end
    return targetLine1, targetLine2
end

function Region:RandomPointInLine(line)
    -- local p = math.random()
    local p = RandomFloat(0.1, 0.9)
    local offsetVector = Vector2D:New(line.v.x*p, line.v.y*p)
    return Vector2D:Add(line.p1, offsetVector)
end