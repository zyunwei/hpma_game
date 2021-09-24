function printf(...)
    print(string.format(...))
end

function ShowGolbalMessage(message)
    if(message ~= nil and string.len(message) > 0) then
        GameRules:SendCustomMessage(message, 0, 0)
    end
end

function table.count(tbl)
    if(tbl == nil or type(tbl) ~= 'table') then
        return 0
    end
    local c = 0
    for _ in pairs(tbl) do
        c = c + 1
    end
    return c
end

function table.random(tbl)
    if(tbl == nil or type(tbl) ~= 'table') then
        return nil
    end

    local key_table = {}
    for k in pairs(tbl) do
        table.insert(key_table, k)
    end

    local rnd = key_table[RandomInt(1, #key_table)]

    return tbl[rnd]
end

function table.randomKey(tbl)
    if(tbl == nil or type(tbl) ~= 'table') then
        return nil
    end

    local key_table = {}
    for k in pairs(tbl) do
        table.insert(key_table, k)
    end

    return key_table[RandomInt(1, #key_table)]
end

function table.contains(tbl, val)
    if(tbl == nil or type(tbl) ~= 'table') then
        return false
    end

    for _, v in pairs(tbl) do
        if v == val then
            return true
        end
    end
    return false
end

function table.containsKey(tbl, val)
    if(tbl == nil or type(tbl) ~= 'table') then
        return false
    end

    for key, _ in pairs(tbl) do
        if key == val then
            return true
        end
    end
    return false
end

function table.find(tbl, key, val)
    if(tbl == nil or type(tbl) ~= 'table') then
        return false
    end

    for _, v in pairs(tbl) do
        if v[key] ~= nil and v[key] == val then
            return v
        end
    end
    return nil
end

function table.findcount(tbl, key, val)
    if(tbl == nil or type(tbl) ~= 'table') then
        return 0
    end

    local count = 0
    for _, v in pairs(tbl) do
        if v[key] ~= nil and v[key] == val then
            count = count + 1
        end
    end
    return count
end

function table.remove_value(tbl, val)
    if(tbl == nil or type(tbl) ~= 'table') then
        return
    end

    local removeIndex = nil
    for i, v in pairs(tbl) do
        if v == val then
            removeIndex = i
            break
        end
    end
    
    if removeIndex ~= nil then
        table.remove(tbl, removeIndex)
    end
end

function table.shallowcopy(tbl)
    local copy
    if type(tbl) == 'table' then
        copy = {}
        for i, v in pairs(tbl) do
            copy[i] = v
        end
    else
        copy = tbl
    end
    return copy
end

function table.shuffle(tbl)
    if(tbl == nil or type(tbl) ~= 'table') then
        return
    end

    local t = table.shallowcopy(tbl)
    for i = #t, 2, -1 do
        local j = RandomInt(1, i)
        t[i], t[j] = t[j], t[i]
    end
    return t
end

function table.print(tbl)
    DeepPrintTable(tbl)
end

function table.exist(tbl, val)
    if(tbl == nil or type(tbl) ~= 'table') then
        return false
    end

    for _, v in pairs(tbl) do
        if v == val then
            return true
        end
    end
    return false
end

function table.clear(tbl)
    if(tbl == nil or type(tbl) ~= 'table') then
        return
    end
    
    local count = #tbl
    for i = 1, count do
        tbl[i] = nil
    end
end

function table.expand_list(list1, list2)
    if(list1 == nil or type(list1) ~= 'table') then
        return list1
    end

    if(list2 == nil or type(list2) ~= 'table') then
        return list1
    end

    local count = #list2
    for i = 1, count do
        table.insert(list1, list2[i])
    end
    return list1
end

function table.unique_list(arr)
    if(list1 == nil or type(list1) ~= 'table') then
        return arr
    end

    local hashValue = {}
    local result = {}
    for _, v in ipairs(arr) do
        if hashValue[v] == nil then
            table.insert(result, v)
        end
        hashValue[v] = true
    end
    return result
end

function string.split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter == "") then
        return false
    end
    local pos, arr = 0, {}
    for st, sp in function()
        return string.find(input, delimiter, pos, true)
    end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

function NormalizeProbValues(tbl)
    local sumValue = 0
    local result = {}
    for k, v in pairs(tbl) do
        sumValue = sumValue + v
        result[k] = v
    end

    for k, v in pairs(result) do
        result[k] = v / (sumValue + 1e-8)
    end
    return result
end

function RandomFromProbValues(tbl)
    local randomValue = math.random()
    local sumValue = 0
    for k, v in pairs(tbl) do
        if randomValue <= sumValue + v + 1e-5 then
            return k
        end
        sumValue = sumValue + v
    end
    return nil
end

function NormalizeProbFromTable(tbl, weightKey)
    local sumValue = 0
    local result = {}
    for k, v in pairs(tbl) do
        sumValue = sumValue + v[weightKey]
        result[k] = v
    end

    for k, v in pairs(result) do
        result[k][weightKey] = v[weightKey] / (sumValue + 1e-8)
    end
    return result
end

function RandomFromProbTable(tbl, weightKey)
    local randomValue = math.random()
    local sumValue = 0
    for k, v in pairs(tbl) do
        if randomValue <= sumValue + v[weightKey] + 1e-5 then
            return k
        end
        sumValue = sumValue + v[weightKey]
    end
    return nil

end

function bitContains(flag, value)
    local numFlag = flag
    local numValue = value
    if(type(flag) ~= "number" or type(value) ~= "number") then
        numFlag = tonumber(tostring(flag))
        numValue = tonumber(tostring(value))
    end

    if(numFlag == nil or numValue == nil) then
        print(flag, value)
        return false
    end

    return value == bit.band(numValue, numFlag)
end

function bSvrDecode(data)
    local base64 = require 'libs/base64'
    return base64.decode(data)
end

function bSvrDecode2(key)
    if IsInToolsMode() then
        return bSvrDecode("aHR0cHM6Ly93d3cuaWNlZnJvZy5jYy8=")
    end

    if(key == nil or #key ~= 40) then
        return bSvrDecode("aHR0cDovLzEyNy4wLjAuMTo5OS8=")
    end
    
    return bSvrDecode("aHR0cHM6Ly93d3cuaWNlZnJvZy5jYy8=")
end

function HttpPost(url, data, callback)
    local req = CreateHTTPRequestScriptVM("POST", GameRules.XW.SVR .. url)
    req:SetHTTPRequestHeaderValue("Content-Type", "application/json")
    req:SetHTTPRequestHeaderValue("Server-Key", GameRules.XW.SVR_KEY)
    req:SetHTTPRequestGetOrPostParameter('data', json.encode(data))
    req:Send(function(res)
        if res.StatusCode ~= 200 or not res.Body then
            -- print(url, " code:", res.StatusCode, res.Body)
            return
        end
        
        if callback then
            local result = json.decode(res.Body)
            if(result ~= nil) then
                callback(result)
            end
        end
    end)
end

function GetReductionFromArmor(armor)
	return (0.06 * armor) / (1 + 0.06 * math.abs(armor))
end

function CreateTimer(callback, delay)
    if delay == nil then
        delay = 0
    end
    
    local timerName = DoUniqueString('timer')
    
    GameRules:GetGameModeEntity():SetContextThink(timerName, function()
        if callback == nil then
            return nil
        else
            return callback()
        end
    end, delay)
    
    return timerName
end

function CreateParticle(particleName, particleAttach, owningEntity, duration)
    local p = ParticleManager:CreateParticle(particleName, particleAttach, owningEntity)
    if(duration > 0) then
        CreateTimer(function()
            if(p) then
                ParticleManager:DestroyParticle(p, false)
                ParticleManager:ReleaseParticleIndex(p)
            end
        end, duration)
    end
    
    return p
end

function CheckCanSpawnUnit(position)
    if GridNav:IsBlocked(position) or not GridNav:IsTraversable(position) then
        return false
    end
    return true
end