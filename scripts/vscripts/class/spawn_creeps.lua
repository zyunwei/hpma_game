
if CSpawnCreeps == nil then
    CSpawnCreeps = class({})
end

local public = CSpawnCreeps
local GameMode = GameRules:GetGameModeEntity()

function public:constructor(info)
    self.__regionId = info.RegionId
    self.__spawner_table = nil
    self.__spawned_creeps = {}
    self.__target_creeps = {}
    self.__target_positions = {}
    self.__addModifiers = info.Modifiers
end

function public:SetSpawnerTable(data)
    if data == nil then
        return
    end
    self.__spawner_table = data

    local spawnCount = self.__spawner_table.TotalCount
    for i = 1, spawnCount do
        self.__spawned_creeps[i] = {
            EntityIndex = -1
        }
    end

    local totalWeight = 0
    for key, value in pairs(self.__spawner_table) do
        if string.find(key, "Creep") == 1 then
            table.insert(self.__target_creeps, {
                unit_name = value.unit_name,
                weight = value.weight
            })
            totalWeight = totalWeight + value.weight
        end
    end
    
    for _, creepInfo in pairs(self.__target_creeps) do
        creepInfo.weight = creepInfo.weight / totalWeight
    end
end

function public:RandomPositionsFromRegion(region)
    self.__target_positions = {}
    for i = 1, 200 do
        table.insert(self.__target_positions, region:RandomPointInRegion())
    end
end

function public:ExecuteSpawn()
    if self.__spawner_table == nil then
        return nil
    end

    local nowTime = GameRules:GetGameTime()
    local spawnCount = self.__spawner_table.TotalCount
    for i = 1, spawnCount do
        local entIndex = self.__spawned_creeps[i].EntityIndex
        if entIndex > 0 then
            local entity = EntIndexToHScript(entIndex)
            if entity == nil or entity:IsAlive() == false or entity:IsNull() then
                self.__spawned_creeps[i].EntityIndex = -1
            end
        end

        if self.__spawned_creeps[i].EntityIndex == -1 then
            self:CreateUnit(i)
        end
    end
end

function public:CreateUnit(index)
    local unitName = self:RandomUnitName()
    local targetPos = table.random(self.__target_positions)
    targetPos = Vector(targetPos.x + math.random(-100, 100), targetPos.y + math.random(-100, 100), targetPos.z)
    local unit = CreateUnitByName(unitName, targetPos, true, nil, nil, DOTA_TEAM_NEUTRALS)
    for _, modifierName in pairs(self.__addModifiers) do
        if unit:HasModifier(modifierName) == false then
            unit:AddNewModifier(unit, nil, modifierName, nil)
        end
    end
    unit:SetForwardVector(Vector(RandomInt(-100, 100), RandomInt(-100, 100), 0))
    self.__spawned_creeps[index].EntityIndex = unit:entindex()
end

function public:RandomUnitName()
    local randomValue = math.random()
    local sumValue = 0
    local targetInfo = self.__target_creeps[1]
    for _, creepInfo in pairs(self.__target_creeps) do
        if sumValue + creepInfo.weight >= randomValue then
            targetInfo = creepInfo
            break
        end
        sumValue = sumValue + creepInfo.weight
    end
    return targetInfo.unit_name
end

function public:OnKilledUnit(attacker, victim)
    local nowTime = GameRules:GetGameTime()
    local victimEntIndex = victim:entindex()
    for _, spawnInfo in pairs(self.__spawned_creeps) do
        if spawnInfo.EntityIndex == victimEntIndex then
            spawnInfo.EntityIndex = -1
        end
    end
end