if SpawnCreepsCtrl == nil then
    SpawnCreepsCtrl = RegisterController("spawn_creeps")
    SpawnCreepsCtrl.__spawners = {}
    SpawnCreepsCtrl.__creep_config_table = nil
    SpawnCreepsCtrl.__spawn_regions = {}
end

local public = SpawnCreepsCtrl
local GameMode = GameRules:GetGameModeEntity()


function public:init()
    _G["SpawnAnimalsKV"] = LoadKeyValues("scripts/kv/spawn_animals.kv")
end

function public:LoadSpawnRegions()
    local allRegions = Entities:FindAllByClassname("path_corner")
    for _, regionEnity in pairs(allRegions) do
        local entityPos = regionEnity:GetAbsOrigin()
        if regionEnity:HasAttribute("ID") or regionEnity:HasAttribute("id") then
            local regionId = regionEnity:Attribute_GetIntValue("ID", -1)
            if regionEnity:HasAttribute("id") then
                regionId = regionEnity:Attribute_GetIntValue("id", -1)
            end
            if regionId > 0 then
                if not self.__spawn_regions[regionId] then
                    self.__spawn_regions[regionId] = Region(regionId)    
                end
                self.__spawn_regions[regionId]:AddRegionPoint(entityPos)
            end
        end
    end
    for _, region in pairs(self.__spawn_regions) do
        region:SortPoints()
    end
end

function public:StartSpawnCreeps()
    self:LoadSpawnRegions()
    for regionId, region in pairs(self.__spawn_regions) do
        if region:IsVaildRegion() then
            local animal_spawner = CSpawnCreeps({
                RegionId = regionId,
                Modifiers = {"modifier_animal"}
            })
            local animal_spawnInfo = SpawnAnimalsKV["CreepsInRegion_" .. tostring(regionId)]
            if animal_spawnInfo then
                animal_spawner:SetSpawnerTable(animal_spawnInfo)
                animal_spawner:RandomPositionsFromRegion(region)
                table.insert(self.__spawners, animal_spawner)
            end
        end
    end

    local creepConfigTable = {}
    for i, v in pairs(self.__spawners) do
        for j, vv in pairs(v.__spawner_table) do
            if string.find(j, "Creep") == 1 then
                if creepConfigTable[vv.unit_name] == nil then
                    creepConfigTable[vv.unit_name] = {}
                end

                table.insert(creepConfigTable[vv.unit_name], i)
            end
        end
    end
    self.__creep_config_table = creepConfigTable

    for _, spawner in pairs(self.__spawners) do
        spawner:ExecuteSpawn()
    end
end

function public:OnEntityKilled(attacker, victim)
    if IsNull(attacker) or IsNull(victim) then
        return
    end
    
    if victim:GetTeam() ~= DOTA_TEAM_NEUTRALS then return end

    for _, spawner in pairs(self.__spawners) do
        spawner:OnKilledUnit(attacker, victim)
    end
end

function public:GetCreepConfigTable()
    return self.__creep_config_table
end