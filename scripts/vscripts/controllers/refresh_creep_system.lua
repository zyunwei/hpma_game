if RefreshCreepSystem == nil then
    RefreshCreepSystem = RegisterController("refresh_creep_system")
    RefreshCreepSystem.__region_creeps = {}
    RefreshCreepSystem.__creeps_hashs = {}
end

local public = RefreshCreepSystem

function public:init()
    self.CreepUpgrade = LoadKeyValues("scripts/kv/creep_upgrade.kv")
    self.MaxLevel = self.CreepUpgrade.MaxLevel
    self.RefreshCount = 0
    self.__creep_upgrade_tables = {}
    for i = 1, self.MaxLevel do
        local data = self.CreepUpgrade["Level_" .. tostring(i)]
        if not data then
            self.MaxLevel = i
            break
        end
        self.__creep_upgrade_tables[i] = data
    end

    self:LoadAllCreeps()
end

function public:LoadAllCreeps()
    local allEntities = Entities:FindAllByName("npc_dota_creep_neutral")
    local allRegions = BlockadeSystem:GetAllRegions()
    for regionId, _ in pairs(allRegions) do
        self.__region_creeps[regionId] = {}
    end
    for _, unit in pairs(allEntities) do
        if unit and unit.IsCreep and unit:IsCreep() then
            local position = unit:GetAbsOrigin()
            local region_id = BlockadeSystem:GetPointRegionId(position)
            if self.__region_creeps[region_id] then
                table.insert(self.__region_creeps[region_id], {
                    Level = 1,
                    Position = position,
                    UnitName = unit:GetUnitName(),
                    Entindex = unit:entindex(),
                    ForwardVector = unit:GetForwardVector(),
                })
                self.__creeps_hashs[unit:entindex()] = {RegionId = region_id, Index = #self.__region_creeps[region_id]}
            else
                print("error position:", position, region_id)
            end
        end
    end
    for regionId, _ in pairs(allRegions) do
        self:RefreshCreeps(regionId)
    end
end

function public:IncreaseRefreshCount()
    self.RefreshCount = self.RefreshCount + 1
end

function public:RefreshCreeps(regionId)
    for index, creepInfo in pairs(self.__region_creeps[regionId]) do
        local unit = EntIndexToHScript(creepInfo.Entindex)
        if unit == nil or unit:IsAlive() == false then
            unit = self:CreateCreep(creepInfo)
            self.__creeps_hashs[unit:entindex()] = {RegionId = regionId, Index = index}
        end

        unit:SetAbility("ability_creep_enhancement", true, creepInfo.Level)
        local modifier = unit:FindModifierByName("modifier_creep")
        if IsNull(modifier) then
            unit:AddNewModifier(unit, nil, "modifier_creep", {stack_count = self.RefreshCount})
        else
            modifier:IncrementStackCount()
        end
    end
end

function public:UpgradeCreeps(regionId)
    for _, creepInfo in pairs(self.__region_creeps[regionId]) do
        if creepInfo.Level >= self.MaxLevel then
            return false
        end
        creepInfo.Level = creepInfo.Level + 1
    end
    self:RefreshCreeps(regionId)
end

function public:CreateCreep(creepInfo)
    local oldUnit = EntIndexToHScript(creepInfo.Entindex)
    if NotNull(oldUnit) then
        UTIL_Remove(oldUnit)
    end
    
    local unitName = creepInfo.UnitName
    local targetPos = creepInfo.Position
    local unit = CreateUnitByName(unitName, targetPos, true, nil, nil, DOTA_TEAM_NEUTRALS)
    unit:SetForwardVector(creepInfo.ForwardVector)

    creepInfo.Entindex = unit:entindex()
    return unit
end

function public:OnEntityKilled(attacker, victim)
    if IsNull(attacker) or IsNull(victim) then
        return
    end

    if victim:GetTeam() ~= DOTA_TEAM_NEUTRALS then return end

    local entIndex = victim:entindex()
    if self.__creeps_hashs[entIndex] == nil then
        return
    end
    local regionId = self.__creeps_hashs[entIndex].RegionId
    local index = self.__creeps_hashs[entIndex].Index
    self.__region_creeps[regionId][index].Entindex = -1
    self.__creeps_hashs[entIndex] = nil
end

function public:GetRegionCreepLevel(regionId)
    for _, creepInfo in pairs(self.__region_creeps[regionId]) do
        return creepInfo.Level
    end
    return 1
end

function public:GetRegionRefreshCostGold(regionId)
    local level = self:GetRegionCreepLevel(regionId)
    local data = self.CreepUpgrade["Level_" .. tostring(level)]
    return data.refresh_cost
end

function public:GetRegionUpgradeCostGold(regionId)
    local level = self:GetRegionCreepLevel(regionId)
    if level == self.MaxLevel then
        return nil
    end
    local data = self.CreepUpgrade["Level_" .. tostring(level)]
    return data.upgrade_cost
end