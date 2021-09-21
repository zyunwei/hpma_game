if BlockadeSystem == nil then
    BlockadeSystem = RegisterController('blockade_system')
    setmetatable(BlockadeSystem,BlockadeSystem)
end

local public = BlockadeSystem

function public:init()
    self.__regions = {}
    self.__regionCount = 9
    self.__blocadeSlackTime = 30
    self.__warningPlayers = {}
    self.__blockRegions = {}
    self.__regionBoundary = {}
    self.__blockCount = 0
    self.__lastBlockRegion = nil
    self.__safeArea = nil
    -- self:LoadRegions()
end

function public:LoadRegions()
    for i = 1, self.__regionCount do
        self.__regions[i] = Region(i)
    end

    local allRegions = Entities:FindAllByClassname("point_message")
    local connections = {}
    local regionKeys = {"RegionId1", "RegionId2", "RegionId3", "RegionId4"}
    for _, regionEnity in pairs(allRegions) do
        local entityPos = regionEnity:GetAbsOrigin()
        local containRegionIds = {}
        for _, key in pairs(regionKeys) do
            if regionEnity:HasAttribute(key) then
                local regionId = regionEnity:Attribute_GetIntValue(key, -1)
                if self.__regions[regionId] ~= nil then
                    self.__regions[regionId]:AddRegionPoint(entityPos)
                    table.insert(containRegionIds, regionId)
                end
            end
        end

        if regionEnity:HasAttribute("IsConnectPoint") then
            table.sort(containRegionIds)
            for i = 1, #containRegionIds do
                local regionId1 = containRegionIds[i]
                for j = i + 1, #containRegionIds do
                    local regionId2 = containRegionIds[j]
                    local hashStr = tostring(regionId1) .. "-" .. tostring(regionId2)
                    if connections[hashStr] == nil then
                        connections[hashStr] = {
                            RegionId1 = regionId1,
                            RegionId2 = regionId2,
                            Positions = {},
                        }
                    end
                    table.insert(connections[hashStr].Positions, entityPos)
                end
            end
        end
    end

    for id, region in pairs(self.__regions) do
        region:SortPoints()
        -- table.print(region.__shapePoints)
    end

    self.__regionBoundary = {}
    for _, connection in pairs(connections) do
        local maxXLen = 0
        local maxYLen = 0
        for i = 1, #connection.Positions do
            for j = i + 1, #connection.Positions do
                maxXLen = math.max(maxXLen, math.abs(connection.Positions[i].x - connection.Positions[j].x))
                maxYLen = math.max(maxYLen, math.abs(connection.Positions[i].y - connection.Positions[j].y))
            end
        end
        if maxXLen > maxYLen then
            table.sort(connection.Positions, function(a, b) return a.x > b.x end)
        else
            table.sort(connection.Positions, function(a, b) return a.y > b.y end)
        end
        for i = 1, #connection.Positions - 1, 2 do
            local particleIndex1, particleIndex2, checkPoint1, checkPoint2 = self:CreateParticlesByConnection(connection, i)
            if particleIndex1 ~= nil and particleIndex2 ~= nil then
                table.insert(self.__regionBoundary, {
                    RegionId1 = connection.RegionId1,
                    RegionId2 = connection.RegionId2,
                    CheckPoint1 = checkPoint1,
                    CheckPoint2 = checkPoint2,
                    ParticleIndex1 = particleIndex1,
                    ParticleIndex2 = particleIndex2,
                })
            end
        end
    end

    self:UpdateWarningLineParticles()
end

function public:Start()
    -- self:initAttrs()
    -- self:LoadRegions()
    self:UpdateWarningLineParticles()
    local GameMode = GameRules:GetGameModeEntity()
    GameMode:SetContextThink("BlockadeSystem", function() return self:OnThink() end, 0)
end

function public:OnThink()
    local gameTime = math.floor(GameManager:GetGameTime())

    if gameTime ~= 0 and gameTime % GameRules.XW.RegionCreepRefreshTickTime == 0 then
        collectgarbage("collect") -- 每分钟清理内存
        RefreshCreepSystem:IncreaseRefreshCount()
    end

    -- 每个区域间隔5秒刷新
    if GameRules.XW.EnableCreepRefresh then
        for i = 1, 9 do
            if gameTime ~= 0 and gameTime % GameRules.XW.RegionCreepRefreshTickTime == i * 5 then
                local region = self.__regions[i]
                if region ~= nil and region:IsBlockade() == false then
                    RefreshCreepSystem:RefreshCreeps(i)
                    -- print("refreshed region:" .. i)
                end
            end
        end
    end

    return 1
end

function public:GetRegionInfos()
    local result = {}
    for regionId, region in pairs(self.__regions) do
        table.insert(result, {
            RegionId = regionId,
            IsBlockade = region:IsBlockade(),
            WillBeBlockade = region:IsBlockadeWarning(),
        })
    end
    return result
end

function public:CreateParticlesByConnection(connection, startIndex)
    local cp1 = connection.Positions[startIndex]
    local cp2 = connection.Positions[startIndex + 1]
    local res = Geometry:GetPointsOfLineSide(cp1, cp2, 15)
    local region1 = self.__regions[connection.RegionId1]
    local region2 = self.__regions[connection.RegionId2]
    if region1 == nil or region2 == nil then
        return nil
    end

    local z = math.max(cp1.z, cp2.z)
    local p1 = Vector(res.p1.x, res.p1.y, z)
    local p2 = Vector(res.p2.x, res.p2.y, z)
    local bias1 = Vector(res.bias1.x, res.bias1.y, z)
    local bias2 = Vector(res.bias2.x, res.bias2.y, z)
    if region1:IsInRegion(p2) then
        p1, p2 = p2, p1
        bias1, bias2 = bias2, bias1
    end

    local particleIndex1 = ParticleManager:CreateParticle(ParticleRes.WALL, PATTACH_WORLDORIGIN, nil)
    local particleIndex2 = ParticleManager:CreateParticle(ParticleRes.WALL, PATTACH_WORLDORIGIN, nil)
    local fp1 = cp1 + bias1
    local fp2 = cp2 + bias1
    local fp3 = cp1 + bias2
    local fp4 = cp2 + bias2
    ParticleManager:SetParticleControl(particleIndex1, 0, Vector(fp1.x, fp1.y, GetGroundHeight(Vector(fp1.x,fp1.y, 0), nil)+1000))
    ParticleManager:SetParticleControl(particleIndex1, 1, Vector(fp2.x, fp2.y, GetGroundHeight(Vector(fp2.x,fp2.y, 0), nil)+1000))

    ParticleManager:SetParticleControl(particleIndex2, 0, Vector(fp3.x, fp3.y, GetGroundHeight(Vector(fp3.x,fp3.y, 0), nil)+1000))
    ParticleManager:SetParticleControl(particleIndex2, 1, Vector(fp4.x, fp4.y, GetGroundHeight(Vector(fp4.x,fp4.y, 0), nil)+1000))

    return particleIndex1, particleIndex2, p1, p2
end

function public:UpdateWarningLineParticles()
    for _, item in pairs(self.__regionBoundary) do
        local region1 = self.__regions[item.RegionId1]
        local region2 = self.__regions[item.RegionId2]
        if region1:IsBlockade() == true then
            ParticleManager:SetParticleControl(item.ParticleIndex1, 60, Vector(0, 255, 0))
            ParticleManager:SetParticleControl(item.ParticleIndex1, 61, Vector(255, 255, 0))
        elseif region1:IsBlockadeWarning() then
            ParticleManager:SetParticleControl(item.ParticleIndex1, 60, Vector(0, 255, 90))
            ParticleManager:SetParticleControl(item.ParticleIndex1, 61, Vector(255, 0, 0))
        else
            ParticleManager:SetParticleControl(item.ParticleIndex1, 60, Vector(0, 0, 255))
            ParticleManager:SetParticleControl(item.ParticleIndex1, 61, Vector(255, 0, 0))
        end
        if region2:IsBlockade() == true then
            ParticleManager:SetParticleControl(item.ParticleIndex2, 60, Vector(0, 255, 0))
            ParticleManager:SetParticleControl(item.ParticleIndex2, 61, Vector(255, 255, 0))
        elseif region2:IsBlockadeWarning() then
            ParticleManager:SetParticleControl(item.ParticleIndex2, 60, Vector(0, 255, 90))
            ParticleManager:SetParticleControl(item.ParticleIndex2, 61, Vector(255, 0, 0))
        else
            ParticleManager:SetParticleControl(item.ParticleIndex2, 60, Vector(0, 0, 255))
	        ParticleManager:SetParticleControl(item.ParticleIndex2, 61, Vector(255, 0, 0))
        end
    end
end

function public:GetPointRegionId(point)
    for regionId, region in pairs(self.__regions) do
        if region:IsInRegion(Vector2D:New(point.x, point.y)) then
            return regionId
        end
    end
    return -1
end

function public:GetAllRegions()
    return self.__regions
end

function public:GetRegionCount()
    return self.__regionCount
end

function public:GetRegionById(regionId)
    return self.__regions[regionId]
end

function public:ShowWarningEffect(playerId)
    local playerInfo = GameRules.XW.PlayerList[playerId]
    if playerInfo == nil or playerInfo.IsBot then
        return
    end
    local warningInfo = self.__warningPlayers[playerId]
    if warningInfo == nil then
        self.__warningPlayers[playerId] = {
            StartEffectTime = -99999,
            EffectIndex = -1,
            CountDown = -1,
            CountDownEffectIndex0 = -1,
            CountDownEffectIndex1 = -1,
            CountDownEffectIndex2 = -1,
        }
        warningInfo = self.__warningPlayers[playerId]
    end

    local nowTime = GameRules:GetGameTime()
    if warningInfo.EffectIndex < 0 then
        if warningInfo.EffectIndex > 0 then
            ParticleManager:DestroyParticle(warningInfo.EffectIndex, true)
        end

        -- create new particle
        local path = "particles/generic_gameplay/screen_damage_indicator.vpcf"
        local player = PlayerResource:GetPlayer(playerId)
        if NotNull(player) then
            local effect_cast = ParticleManager:CreateParticleForPlayer(path, PATTACH_EYES_FOLLOW, hero, player)
            ParticleManager:SetParticleControl(effect_cast, 1, Vector(1, 0, -300))
            warningInfo.StartEffectTime = nowTime
            warningInfo.EffectIndex = effect_cast
        end
    end

    
    if warningInfo.CountDown < 0 then
        local player = PlayerResource:GetPlayer(playerId)
        local hero = playerInfo.Hero

        if NotNull(player) and NotNull(hero) then
            local path0 = "particles/custom_counter_number0.vpcf"
            local path1 = "particles/custom_counter_number1.vpcf"
            local path2 = "particles/custom_counter_number2.vpcf"
            warningInfo.CountDownEffectIndex0 = ParticleManager:CreateParticleForPlayer(path0, PATTACH_OVERHEAD_FOLLOW, hero, player)
            warningInfo.CountDownEffectIndex1 = ParticleManager:CreateParticleForPlayer(path1, PATTACH_OVERHEAD_FOLLOW, hero, player)
            warningInfo.CountDownEffectIndex2 = ParticleManager:CreateParticleForPlayer(path2, PATTACH_OVERHEAD_FOLLOW, hero, player)
            self:UpdateInBlockadeNumberEffect(playerInfo, warningInfo)
        end
    else
        self:UpdateInBlockadeNumberEffect(playerInfo, warningInfo)
    end
end

function public:UpdateInBlockadeNumberEffect(playerInfo, warningInfo)
    if warningInfo.CountDownEffectIndex0 == nil or warningInfo.CountDownEffectIndex1 == nil or warningInfo.CountDownEffectIndex2 == nil then
        return
    end

    local inBlockadeTime = playerInfo:GetInBlockadeTime()
    local countDown = self.__blocadeSlackTime - inBlockadeTime
    if countDown < 0 then
        warningInfo.CountDown = 0
        ParticleManager:SetParticleControl(warningInfo.CountDownEffectIndex0, 1, Vector(0, 0, 0))
        ParticleManager:SetParticleControl(warningInfo.CountDownEffectIndex1, 1, Vector(0, 0, 0))
        ParticleManager:SetParticleControl(warningInfo.CountDownEffectIndex2, 1, Vector(0, 0, 0))
        return
    end

    if NotNull(playerInfo.Hero) then
        local countDownSound = "announcer_ann_custom_countdown_"
        local countDownNumber = math.ceil(countDown)
        local validSound = false
        if countDownNumber == 10 then
            countDownSound = countDownSound .. "10"
            validSound = true
        elseif countDownNumber > 0 and countDownNumber < 10 then
            countDownSound = countDownSound .. "0" .. countDownNumber
            validSound = true
        end

        if validSound then
            EmitSoundOnLocationForAllies(playerInfo.Hero:GetAbsOrigin(), countDownSound, playerInfo.Hero)
        end

        warningInfo.CountDown = countDown
        countDown = math.ceil(countDown)
        local number1 = math.floor(countDown/10) % 10
        local number2 = countDown % 10
        local heroPos = playerInfo.Hero:GetAbsOrigin()

        if number1 == 0 then
            ParticleManager:SetParticleControl(warningInfo.CountDownEffectIndex0, 1, Vector(number2, 1, 0))
            ParticleManager:SetParticleControl(warningInfo.CountDownEffectIndex1, 1, Vector(0, 0, 0))
            ParticleManager:SetParticleControl(warningInfo.CountDownEffectIndex2, 1, Vector(0, 0, 0))
        else
            ParticleManager:SetParticleControl(warningInfo.CountDownEffectIndex0, 1, Vector(0, 0, 0))
            ParticleManager:SetParticleControl(warningInfo.CountDownEffectIndex1, 1, Vector(number1, 1, 0))
            ParticleManager:SetParticleControl(warningInfo.CountDownEffectIndex2, 1, Vector(number2, 1, 0))
        end
    end
end

function public:HideWarningEffect(playerId)
    if self.__warningPlayers[playerId] ~= nil then
        local warningInfo = self.__warningPlayers[playerId]
        ParticleManager:DestroyParticle(warningInfo.EffectIndex, true)
        ParticleManager:DestroyParticle(warningInfo.CountDownEffectIndex0, true)
        ParticleManager:DestroyParticle(warningInfo.CountDownEffectIndex1, true)
        ParticleManager:DestroyParticle(warningInfo.CountDownEffectIndex2, true)
        self.__warningPlayers[playerId] = nil
    end
end

function public:SetBlockadeModifier(playerInfo)
    if playerInfo ==nil or playerInfo.Hero == nil then
        return
    end
    local hero = playerInfo.Hero
    if self:IsInSafeArea(playerInfo) then
        return
    end
    if hero:HasModifier("modifier_in_blockade") then
        return
    end
    hero:AddNewModifier(hero, nil, "modifier_in_blockade", {})
end

function public:RemoveBlockadeModifier(playerInfo)
    if playerInfo == nil or IsNull(playerInfo.Hero) then
        return
    end
    local hero = playerInfo.Hero
    if hero:HasModifier("modifier_in_blockade") then
        hero:RemoveModifierByName("modifier_in_blockade")
    end
end

function public:IsInSafeArea(playerInfo)
    if playerInfo == nil or playerInfo.Hero == nil or self.__safeArea == nil then
        return false
    end
    local hero = playerInfo.Hero
    if hero then
        local pos = hero:GetAbsOrigin()
        return not (pos.x < self.__safeArea.minX or pos.x > self.__safeArea.maxX or pos.y < self.__safeArea.minY or pos.y > self.__safeArea.maxY)
    end
end

function public:CreateSafeArea(regionId)
    local teleportPoint = TELEPORT_POSITION[regionId]
    self.__safeArea = {}
    self.__safeArea.minX = teleportPoint.x - 1000
    self.__safeArea.minY = teleportPoint.y - 800
    self.__safeArea.maxX = teleportPoint.x + 1000
    self.__safeArea.maxY = teleportPoint.y + 800
    local particleIndex1 = ParticleManager:CreateParticle(ParticleRes.WALL, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particleIndex1, 0, Vector(self.__safeArea.minX, self.__safeArea.minY, GetGroundHeight(Vector(self.__safeArea.minX, self.__safeArea.minY, 0), nil)+1000))
    ParticleManager:SetParticleControl(particleIndex1, 1, Vector(self.__safeArea.minX, self.__safeArea.maxY, GetGroundHeight(Vector(self.__safeArea.minX, self.__safeArea.maxY, 0), nil)+1000))
    ParticleManager:SetParticleControl(particleIndex1, 60, Vector(0, 0, 255))
    ParticleManager:SetParticleControl(particleIndex1, 61, Vector(255, 0, 0))

    local particleIndex2 = ParticleManager:CreateParticle(ParticleRes.WALL, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particleIndex2, 0, Vector(self.__safeArea.maxX, self.__safeArea.minY, GetGroundHeight(Vector(self.__safeArea.maxX, self.__safeArea.minY, 0), nil)+1000))
    ParticleManager:SetParticleControl(particleIndex2, 1, Vector(self.__safeArea.maxX, self.__safeArea.maxY, GetGroundHeight(Vector(self.__safeArea.maxX, self.__safeArea.maxY, 0), nil)+1000))
    ParticleManager:SetParticleControl(particleIndex2, 60, Vector(0, 0, 255))
    ParticleManager:SetParticleControl(particleIndex2, 61, Vector(255, 0, 0))
    
    
    local particleIndex3 = ParticleManager:CreateParticle(ParticleRes.WALL, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particleIndex3, 0, Vector(self.__safeArea.minX, self.__safeArea.minY, GetGroundHeight(Vector(self.__safeArea.minX, self.__safeArea.minY, 0), nil)+1000))
    ParticleManager:SetParticleControl(particleIndex3, 1, Vector(self.__safeArea.maxX, self.__safeArea.minY, GetGroundHeight(Vector(self.__safeArea.maxX, self.__safeArea.minY, 0), nil)+1000))
    ParticleManager:SetParticleControl(particleIndex3, 60, Vector(0, 0, 255))
    ParticleManager:SetParticleControl(particleIndex3, 61, Vector(255, 0, 0))
    
    local particleIndex4 = ParticleManager:CreateParticle(ParticleRes.WALL, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particleIndex4, 0, Vector(self.__safeArea.minX, self.__safeArea.maxY, GetGroundHeight(Vector(self.__safeArea.minX, self.__safeArea.maxY, 0), nil)+1000))
    ParticleManager:SetParticleControl(particleIndex4, 1, Vector(self.__safeArea.maxX, self.__safeArea.maxY, GetGroundHeight(Vector(self.__safeArea.maxX, self.__safeArea.maxY, 0), nil)+1000))
    ParticleManager:SetParticleControl(particleIndex4, 60, Vector(0, 0, 255))
    ParticleManager:SetParticleControl(particleIndex4, 61, Vector(255, 0, 0))

    CustomMessage:all({
        type="message-box", 
        role="xxwar_system_notification",
        list={{text="xxwar_create_safearea", args={}}},
    })
end

function public:RandomBlockadeRegion()
    for regionId, region in pairs(self.__regions) do
        if region:IsBlockadeWarning() then
            region:BlockadRegion()
            print("blockade region:", regionId)
            self.__blockCount = self.__blockCount + 1
            table.insert(self.__blockRegions, regionId)
            -- 释放BOSS
            if GameRules.XW.AutoReleaseBossCount == 0 and NPC_CONFIG and NPC_CONFIG[regionId] then
                local gameTime = GameManager:GetGameTime()
                local releaseBossList = {}
                for _, option in pairs(NPC_CONFIG[regionId].options) do
                    if option.optionType == "boss" and option.autoReleaseTime ~= nil and gameTime > option.autoReleaseTime then
                        table.insert(releaseBossList, option.targetName)
                    end
                end

                local releaseBossName = table.random(releaseBossList)
                if releaseBossName ~= nil then
                    CustomMessage:all({
                        type="message-box", 
                        role="xxwar_system_notification",
                        list={{text={"xxwar_boss_in", regionId, "xxwar_boss_release"}, args={}}},
                    })

                    GameRules.XW.AutoReleaseBossCount = GameRules.XW.AutoReleaseBossCount + 1

                    for i, option in pairs(NPC_CONFIG[regionId].options) do
                        if option.targetName == releaseBossName then
                            local boss = CreateUnitByName(releaseBossName, NPC_CONFIG[regionId].bossPos, true, nil, nil, DOTA_TEAM_NEUTRALS)
                            boss.SpawnPosition = NPC_CONFIG[regionId].bossPos
                            boss.IsBoss = true
                            boss.IsReleaseBoss = true
                            boss:SetContextThink("OnHeroThink", function() return BossAI:OnHeroThink(boss) end, 1)
                            boss:AddNewModifier(boss, nil, "modifier_provides_vision", {})

                            if string.find(releaseBossName, "npc_boss_timbersaw") == 1 then
                                EmitGlobalSound("XXWAR.RIM_SOUND_2")
                            end

                            table.remove(NPC_CONFIG[regionId].options, i)
                            break
                        end
                    end
                end
            end

            if self.__blockCount == self.__regionCount then 
                self.__lastBlockRegion = region
                self:CreateSafeArea(regionId)
            end
            for playerId, playerInfo in pairs(GameRules.XW.PlayerList) do
                if playerInfo.IsEmpty == false then
                    playerInfo:UpdatePlayerRegion(playerId)
                    local nowRegionId = playerInfo:GetStayRegionId()
                    if nowRegionId == regionId and self:IsInSafeArea(playerInfo) == false then
                        playerInfo:OnEnterBlockadeRegion()
                        self:SetBlockadeModifier(playerInfo)
                    end
                end
            end
        end
    end

    local remainRegionIds = {}
    for regionId, region in pairs(self.__regions) do
        if region:IsBlockade() == false then
            table.insert(remainRegionIds, regionId)
        end
    end

    local blockadeCount = 1
    remainRegionIds = table.shuffle(remainRegionIds)
    blockadeCount = math.min(blockadeCount, #remainRegionIds)
    for i = 1, blockadeCount do
        self.__regions[remainRegionIds[i]]:BlockadeWarning()
    end
    
    self:UpdateWarningLineParticles()

    CustomNetTables:SetTableValue("Common", "BlockadeInfoTable", self:GetRegionInfos())
    CustomGameEventManager:Send_ServerToAllClients("update_minimap_region_state", {})
end

function public:GetBlockRegions()
    return self.__blockRegions
end

function public:GetSafeRegions()
    local safeRegions = {}
    for i = 1, self.__regionCount do
        if self.__regions[i]:IsBlockade() == false and self.__regions[i]:IsBlockadeWarning() == false then
            table.insert(safeRegions, i)
        end
    end
    return safeRegions
end