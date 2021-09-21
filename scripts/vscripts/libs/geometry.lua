if Geometry == nil then
    Geometry = {}
end

if Vector2D == nil then
    Vector2D = { x = 0, y = 0}
    Vector2D.__index = Vector2D
end

function Vector2D:New(x, y)
    local o = { x = x, y = y}
    setmetatable(o, self)
    return o
end

function dcmp(v)
    if math.abs(v) < 1e-6 then
        return 0
    elseif v < 0 then
        return -1
    end
    return 1
end

function Vector2D:Length()
    return math.sqrt(self.x*self.x + self.y*self.y)
end

function Vector2D:Cross(v1, v2)
    return v1.x*v2.y - v2.x*v1.y
end

function Vector2D:Dot(v1, v2)
    return v1.x * v2.x + v1.y * v2.y
end

function Vector2D:Sub(v1, v2)
    return Vector2D:New(v1.x - v2.x, v1.y - v2.y)
end

function Vector2D:Add(v1, v2)
    return Vector2D:New(v1.x + v2.x, v1.y + v2.y)
end

function Vector2D:Rotate(angle)
    local theta = math.rad(angle)
    local cosTheta = math.cos(theta)
    local sinTheta = math.sin(theta)
    local x = self.x * cosTheta - self.y * sinTheta
    local y = self.x * sinTheta + self.y * cosTheta
    self.x = x
    self.y = y
end

function Geometry:PointOnSegment(p1, p2, q)
    local v1 = Vector2D:Sub(p1, q)
    local v2 = Vector2D:Sub(p2, q)
    local crossValue = Vector2D:Cross(v1, v2)
    local dotValue = Vector2D:Dot(v1, v2)
    return dcmp(crossValue) == 0 and dcmp(dotValue) <= 0
end

function Geometry:IsPointInPolygon(polygonPoints, targetPoint)
    local flag = false
    local n = #polygonPoints
    local j = n
    for i = 1, n do
        local p1 = polygonPoints[i]
        local p2 = polygonPoints[j]
        if Geometry:PointOnSegment(p1, p2, targetPoint) then
            return true
        end
        local check1 = dcmp(p1.y - targetPoint.y)
        local check2 = dcmp(p2.y - targetPoint.y)
        local check3 = dcmp(targetPoint.x - (targetPoint.y - p1.y)*(p1.x - p2.x)/(p1.y - p2.y) - p1.x )
        if (check1 ~= check2) and check3 < 0 then
            flag = not flag
        end
        j = i
    end
    return flag
end

function Geometry:ApproximateGravityPoint(points)
    local sumX = 0
    local sumY = 0
    local n = #points or 1
    for _, p in pairs(points) do
        sumX = sumX + p.x
        sumY = sumY + p.y
    end
    return Vector2D:New(sumX / n, sumY / n)
end

function Geometry:ApproximateCenterPoint(points)
    local minX = points[1].x
    local maxX = points[1].x
    local minY = points[1].y
    local maxY = points[1].y
    local n = #points or 1
    for _, p in pairs(points) do
        minX = math.min(minX, p.x)
        minY = math.min(minY, p.y)
        maxX = math.max(maxX, p.x)
        maxY = math.max(maxY, p.y)
    end
    return Vector2D:New((maxX + minX) / 2, (minY + maxY) / 2)
end

function Geometry:PolygonPointCmp(p1, p2, center)
    -- if p1.x >= 0 and p2.x < 0 then
    --     return true
    -- end
    -- if p1.x == 0 and p2.x == 0 then
    --     return p1.y > p2.y
    -- end
    local v1 = Vector2D:Sub(p1, center)
    local v2 = Vector2D:Sub(p2, center)
    if v1.x >= 0 and v1.x < 0 then
        return true
    end
    if v1.x == 0 and v2.x == 0 then
        return v1.y > v2.y
    end
    local crossValue = Vector2D:Cross(v1, v2)
    if dcmp(crossValue) < 0 then
        return true
    end
    if dcmp(crossValue) > 0 then
        return false
    end
    local d1 = v1.x*v1.x + v1.y*v1.y
    local d2 = v2.x*v2.x + v2.y*v2.y
    return d1 > d2
end

function Geometry:SortPolygonPoints(points)
    local index = 1
    local n = #points

    for i = 2, n do
        if points[i].y < points[index].y or (points[i].y == points[index].y and points[i].x < points[index].x) then
            index = i
        end
    end

    points[1], points[index] = points[index], points[1]
    for i = 2, n - 1 do
        index = i
        for j = i + 1, n do
            v1 = Vector2D:Sub(points[1], points[j])
            v2 = Vector2D:Sub(points[index], points[j])
            crossValue = Vector2D:Cross(v1, v2)
            d1 = Vector2D:Sub(points[1], points[j]):Length()
            d2 = Vector2D:Sub(points[1], points[index]):Length()
            if crossValue > 0 or (crossValue == 0 and d1 < d2) then
                index = j
            end
        end
        points[i], points[index] = points[index], points[i]
    end

    return points
end

-- 获取线段两边的点和对应平行线段的平移量
function Geometry:GetPointsOfLineSide(point1, point2, d)
    local cx = (point1.x + point2.x)/2
    local cy = (point1.y + point2.y)/2
    if point1.x == point2.x then
        return {
            p1 = Vector2D:New(cx - d, cy),
            p2 = Vector2D:New(cx + d, cy),
            bias1 = Vector2D:New(-d, 0),
            bias2 = Vector2D:New(d, 0)
        }
    end
    if point1.y == point2.y then
        return {
            p1 = Vector2D:New(cx, cy - d),
            p2 = Vector2D:New(cx, cy + d),
            bias1 = Vector2D:New(0, -d),
            bias2 = Vector2D:New(0, d)
        } 
    end
    local k = (point2.y - point1.y) / (point2.x - point1.x)
    local k2 = -1/k
    local c = cy - cx*k2
    local A = k2*k2 + 1
    local B = -2 * (cx * k2 + c - cy) * k2
    local C = (cx * k2 + c - cy)*(cx*k2 + c - cy) - d*d
    local m1 = (-B + math.sqrt(B*B - 4*A*C))/(2*A)
    local m2 = (-B - math.sqrt(B*B - 4*A*C))/(2*A)
    local m = m1
    if m1 < 0 then
        m = m2
    end
    local p1 = Vector2D:New(cx - m, (cx - m)*k2 + c)
    local p2 = Vector2D:New(cx + m, (cx + m)*k2 + c)
    return {
        p1 = p1,
        p2 = p2,
        bias1 = Vector2D:New(p1.x - cx, p1.y - cy),
        bias2 = Vector2D:New(p2.x - cx, p2.y - cy),
    }
end