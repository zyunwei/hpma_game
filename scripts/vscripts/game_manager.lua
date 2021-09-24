if GameManager == nil then
    GameManager = {
        Stage = 0,
        StageTime = 90,
        GameStartTime = 0,
        StageStartTime = 0,
        IsGameOver = false,
        WinnerTeam = nil,
        IsPostGame = false,
        TotalTeamCount = 0,
        StartTimeStamp = 0,
        StartPosList = {
            [DOTA_TEAM_CUSTOM_1] = {},
            [DOTA_TEAM_CUSTOM_2] = {},
            [DOTA_TEAM_CUSTOM_3] = {},
            [DOTA_TEAM_CUSTOM_4] = {},
            [DOTA_TEAM_CUSTOM_5] = {},
            [DOTA_TEAM_CUSTOM_6] = {},
            [DOTA_TEAM_CUSTOM_7] = {},
            [DOTA_TEAM_CUSTOM_8] = {},
        },
        AllHeroNames = {
            "lina", "templar_assassin"
        }
    }
end

function GameManager:InitStartPositions()
    local startPosList = Entities:FindAllByClassname("info_player_start_dota")
    local allPoints = {}
    for i, v in pairs(startPosList) do
        table.insert(allPoints, v:GetAbsOrigin())
    end

    allPoints = table.shuffle(allPoints)

    for _, point in pairs(allPoints) do
        if #GameManager.StartPosList[DOTA_TEAM_CUSTOM_1] < #allPoints / 2 then
            table.insert(GameManager.StartPosList[DOTA_TEAM_CUSTOM_1], { state = 0, pos = point })
        else
            table.insert(GameManager.StartPosList[DOTA_TEAM_CUSTOM_2], { state = 0, pos = point })
        end
    end
end

function GameManager:ResetPlayerPosition(playerId)
    local playerInfo = GameRules.XW.PlayerList[playerId]
    if playerInfo ~= nil and playerInfo.Hero ~= nil and playerInfo.Hero:IsNull() == false then
        playerInfo.TeamId = playerInfo.Hero:GetTeamNumber()
        for _, v in pairs(GameManager.StartPosList[playerInfo.TeamId]) do
            if v.state == 0 then
                v.state = 1
                if v.pos.x > 0 then
                    playerInfo.BattleSide = 1
                else
                    playerInfo.BattleSide = -1
                end
                FindClearSpaceForUnit(playerInfo.Hero, v.pos, true)
                playerInfo.Hero:RemoveModifierByName("modifier_out_of_game")
                PlayerResource:SetCameraTarget(playerId, playerInfo.Hero)
                Timers:CreateTimer(1, function() PlayerResource:SetCameraTarget(playerId, nil) end)
                break
            end
        end
    end
end

function GameManager:GameStart()
    print("Gamestart")
    self.GameStartTime = math.floor(GameRules:GetGameTime())
    self.StageStartTime = math.floor(GameRules:GetGameTime())
    self.Stage = 1

    for i = 1, 4 do
        local outpost = Entities:FindByName(nil, "outpost_" .. i)
        if NotNull(outpost) then
            table.insert(GameRules.XW.Outposts, outpost)
            outpost:RemoveModifierByName("modifier_invulnerable")
        end
    end

    local outpost_center = Entities:FindByName(nil, "outpost_center")
    if NotNull(outpost_center) then
        outpost_center:RemoveModifierByName("modifier_invulnerable")
        GameRules.XW.OutpostCenter = outpost_center
    end

    local playerCount = 0
    local botCount = 0
    local totalGrade = 0
    local players = {}
    for playerId, info in pairs(GameRules.XW.PlayerList) do
        if(info.IsEmpty == false) then
            if(info.IsBot) then
                botCount = botCount + 1
            else
                totalGrade = totalGrade + info.Grade
                playerCount = playerCount + 1
                table.insert(players, info.SteamAccountId)
            end
        end
    end
    
    local averageGrade = math.floor(totalGrade / playerCount)
    if(averageGrade < 1) then averageGrade = 1 end
    
    local postData = {
        MatchId = GameRules.XW.MatchID, 
        PlayerCount = playerCount, 
        BotCount = botCount, 
        AverageGrade = averageGrade, 
        MapName = GameRules.XW.MapName,
        Players = players
    }

    HttpPost("api/Game/GameStart", postData, function(result)
        if(result.isSuccess) then
            -- ShowGolbalMessage("Game data uploaded.")
            GameRules.XW.GameId = result.tag
        else
            ShowGolbalMessage(result.message)
        end
    end)

    GameRules.XW:StartThink()
    BlockadeSystem:Start()
    -- SupplyCtrl:Start()
    PetExpCtrl:Start()
    self:SetPlayerInitDatas()
end

function GameManager:CheckGameStart()
    if self.GameStartTime > 0 then
        return
    end

    if GameRules:State_Get() < DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        return
    end

    local loadedPlayerCount = 0
    for playerId, playerInfo in pairs(GameRules.XW.PlayerList) do
        -- 开局退出的玩家不影响开始游戏
        if(PlayerResource:GetConnectionState(playerId) == DOTA_CONNECTION_STATE_ABANDONED) then
            loadedPlayerCount = loadedPlayerCount + 1
            playerInfo.IsEmpty = true
            playerInfo.IsOnline = false

            if NotNull(playerInfo.Hero) then
                playerInfo.Hero:ForceKill(true)
                playerInfo.Hero = nil
            end
        else
            if playerInfo.IsEmpty == false and NotNull(playerInfo.Hero) then
                loadedPlayerCount = loadedPlayerCount + 1
            end
        end
    end

    if(loadedPlayerCount >= PlayerResource:GetPlayerCount()) then
        GameManager:InitStartPositions()
        local teamList = {}
        local totalTeamCount = 0
        for playerId, playerInfo in pairs(GameRules.XW.PlayerList) do
            if playerInfo.IsEmpty == false then
                self:ResetPlayerPosition(playerId)
                if table.contains(teamList, playerInfo.TeamId) == false then 
                    totalTeamCount = totalTeamCount + 1
                    table.insert(teamList, playerInfo.TeamId)
                end
            end
        end
        GameManager.TotalTeamCount = totalTeamCount
        GameManager:GameStart()
    end
end

function GameManager:OnThink()
    if self.Stage <= 0 then
        return
    end

    local nowTime = math.floor(GameRules:GetGameTime())
    local stagePassTime = nowTime - self.StageStartTime
    local stageCountDown = self.StageTime - stagePassTime
    if stageCountDown <= 0 then
        self.Stage = self.Stage + 1
        self.StageStartTime = nowTime
    end

    local gameTime = math.floor(GameManager:GetGameTime())
    if gameTime == GameRules.XW.BuyBossOpenTime then
        CustomMessage:all({
            type="message-box", 
            role="xxwar_system_notification",
            list={{text="xxwar_buyboss_open", args={}}},
        })
    end

    local topbarInfo = {}
    local aliveCount = 0
    local checkedTeams = {}
    local playerCount = 0
    local playerLevelList = {}
    for playerId, playerInfo in pairs(GameRules.XW.PlayerList) do
        if playerInfo.IsEmpty == false then
            if playerInfo.IsBot == false then
                playerCount = playerCount + 1
            end

            -- if playerInfo.IsBot and IsAlive(playerInfo.Hero) then
            --     local target = playerInfo.Hero:GetNearestEnemyForAI(-1, true, 100)
            --     if IsAlive(target) and GridNav:CanFindPath(playerInfo.Hero:GetAbsOrigin(), target:GetAbsOrigin()) then
            --         playerInfo.Hero:MoveToPositionAggressive(target:GetAbsOrigin())
            --     end
            -- end

            if IsNull(playerInfo.Hero) == false and playerInfo.IsAlive then
                playerInfo.Hero:CheckPosition()
                table.insert(playerLevelList, {playerId = playerId, level = playerInfo.Hero:GetLevel()})
                CustomNetTables:SetTableValue("CustomAttributes",  
                    "StatisticalAttributes_" .. tostring(playerInfo.Hero:GetEntityIndex()), 
                    playerInfo.Hero:StatisticalAttributes())

                if GameRules:IsGamePaused() == false then
                    playerInfo.Hero:GiveGold(1)
                    if gameTime ~= 0 and gameTime % GameRules.XW.PlayerBonusExpTickTime == 0 then 
                        playerInfo.Hero:AddExperience(gameTime * 0.5, 0, false, false)
                    end
                    local crystal = playerInfo.Hero:GetCustomAttribute("crystal")
                    local maxCrystal = playerInfo.Hero:GetCustomAttribute("max_crystal")
                    local crystalRegen = playerInfo.Hero:GetCustomAttribute("crystal_regen")

                    if crystal + crystalRegen < maxCrystal then
                        playerInfo.Hero:ModifyCustomAttribute("crystal", "crystal", crystalRegen)
                    else
                        playerInfo.Hero:SetCustomAttribute("crystal", "crystal", maxCrystal)
                    end
                end
            end

            CustomNetTables:SetTableValue("PlayerInfo", tostring(playerId), {
                ShowDeathFrame = playerInfo.ShowDeathFrame, 
                XXCoin = playerInfo.XXCoin, 
                Bullion = playerInfo.Bullion,
                RespawnCoin = playerInfo.RespawnCoin,
                RespawnCount = playerInfo.RespawnCount,
                BountyBullion = playerInfo.BountyBullion,
                IsVip = playerInfo.IsVip,
            })

            CustomNetTables:SetTableValue("PlayerImgItem", tostring(playerId), playerInfo.ImgItem)

            if checkedTeams[playerInfo.TeamId] ~= true then
                if playerInfo.IsAlive then
                    aliveCount = aliveCount + 1
                    checkedTeams[playerInfo.TeamId] = true

                    -- 开局视野
                    if GameManager:GetGameTime() < 5 and NotNull(playerInfo.Hero) then
                        GameManager:ShowAllHeroesForTeam(playerInfo.TeamId)
                    end
                else
                    -- 阵亡视野
                    -- if NotNull(playerInfo.Hero) then
                    --     GameManager:ShowAllHeroesForTeam(playerInfo.TeamId)
                    -- end
                end
            end

            local pets = CallHeroPool:GetPlayerPets(playerId)
            for _, v in pairs(pets) do
                local attrs = v:StatisticalAttributes()
                local tableAttrs = {
                    str = math.floor(attrs["str"]),
                    agi = math.floor(attrs["agi"]),
                    int = math.floor(attrs["int"]),
                    spell_amp = math.floor(attrs["spell_amp"]),
                    status_resistance = math.floor(attrs["status_resistance"]),
                    evasion = math.floor(attrs["evasion"]),
                    armor = math.floor(attrs["armor"]),
                    attack_speed = math.floor(attrs["attack_speed"]),
                }
                CustomNetTables:SetTableValue("PetAttributes", tostring(v:GetEntityIndex()), tableAttrs)
            end
        end
    end

    table.sort(playerLevelList, function(a, b)
        return a.level > b.level
    end)

    for i, v in pairs(playerLevelList) do
        local playerInfo = GameRules.XW:GetPlayerInfo(v.playerId)
        if playerInfo ~= nil and IsAlive(playerInfo.Hero) then
            if playerInfo.Hero:GetLevel() >= 30 then
                playerInfo.Hero:SetCustomAttribute("exp_gain", "compensation", 0)
            else
                playerInfo.Hero:SetCustomAttribute("exp_gain", "compensation", (i - 1) * 10)
            end
        end
    end

    -- if gameTime ~= 0 and gameTime % GameRules.XW.CompensateTickTime == 0 and not GameRules:IsGamePaused() then
    --     local gold = CurrenciesCtrl:GetSortedAllPlayerGold()
    --     for rank, v in ipairs(gold) do
    --         local config = COMPENSATE[rank]
    --         local hero = EntIndexToHScript(v.heroIndex)
    --         if NotNull(hero) and config then
    --             for i = 1, config.count do
    --                 local item = GetRandomItemQuality({config.quality}, (config.kind == ITEM_KIND_CONSUMABLE))
    --                 if item then
    --                     hero:AddOwnerItemByName(item)
    --                 end
    --             end
    --             hero:ShowCustomMessage({
    --                 type="message-box", 
    --                 role="xxwar_system_notification",
    --                 styles={color="#36B8FF"},
    --                 list={{text={"xxwar_compensate"}, args={}}},
    --             })
    --         end
    --     end
    -- end

    -- if gameTime ~= 0 and gameTime % 120 == 0 and not GameRules:IsGamePaused() then
    --     for _, playerInfo in pairs(GameRules.XW.PlayerList) do
    --         if playerInfo.IsEmpty == false and playerInfo.IsAlive and NotNull(playerInfo.Hero) then
    --             playerInfo.Hero:AddItemByName("item_consumable_ability")
    --         end
    --     end
    -- end

    topbarInfo.AlivePlayerCount = aliveCount
    topbarInfo.StageCountdown = stageCountDown
    topbarInfo.TotalPlayerCount = GameManager.TotalTeamCount
    topbarInfo.Jackpot = GameRules.XW.Jackpot
    topbarInfo.JackpotAmount = {}
    topbarInfo.GlobalJackpot = GameRules.XW.GlobalJackpot

    local jackpotShareCount = GameRules.XW:GetJackpotShareCount(GameManager.TotalTeamCount)
    for i = 1, jackpotShareCount do
        local amount = GameRules.XW:GetJackpotShare(GameManager.TotalTeamCount, i, false)
        table.insert(topbarInfo.JackpotAmount, amount)
    end

    CustomNetTables:SetTableValue("Common", "TopbarInfo", topbarInfo)
    self:UpdateGlobalJackpot()
end

function GameManager:ShowAllHeroesForTeam(teamId)
    for _, playerInfo in pairs(GameRules.XW.PlayerList) do
        if playerInfo.IsEmpty == false then
            if IsNull(playerInfo.Hero) == false and playerInfo.IsAlive then
                AddFOWViewer(teamId, playerInfo.Hero:GetAbsOrigin(), 800, 2, false)
            end
        end
    end
end

function GameManager:UpdateGlobalJackpot()
    if(GameRules:IsGamePaused()) then return end
    local gameTime = GameRules:GetGameTime()
    if gameTime > GameRules.XW.GlobalJackpotUpdateTime + 5 then
        GameRules.XW.GlobalJackpotUpdateTime = gameTime
        HttpPost("api/Jackpot/GetGlobalJackpot", {}, function(result)
            if(result.isSuccess) then
                GameRules.XW.GlobalJackpot = result.tag
            end
             -- 控制更新频率
            GameRules.XW.GlobalJackpotUpdateTime = gameTime
        end)
    end
end

function GameManager:AssignmentTeams()
    local vaildTeams = {
        [1] = DOTA_TEAM_CUSTOM_1,
        [2] = DOTA_TEAM_CUSTOM_2,
        [3] = DOTA_TEAM_CUSTOM_3,
        [4] = DOTA_TEAM_CUSTOM_4,
        [5] = DOTA_TEAM_CUSTOM_5,
        [6] = DOTA_TEAM_CUSTOM_6,
        [7] = DOTA_TEAM_CUSTOM_7,
        [8] = DOTA_TEAM_CUSTOM_8
    }
    for _, teamId in pairs(vaildTeams) do
        GameRules:SetCustomGameTeamMaxPlayers(teamId, 4)
    end
    local now_team = 0
    for playerId, playerInfo in pairs(GameRules.XW.PlayerList) do
        if playerInfo.IsEmpty == false then
            playerInfo:SetPlayerTeam(playerId, vaildTeams[now_team + 1])
            now_team = (now_team + 1) % (#vaildTeams)
        end
    end
end

function GameManager:PlayerGameOver()
    if self:CheckGameIsOver() then
        if self.IsPostGame == false then
            self.IsPostGame = true
            self:GameOver()
        end
        return true
    end

    return false
end

function GameManager:GameOver()
    local endTable = {}
    local teams = {}
    GameManager:UpdatePlayersRank()
    for playerId, playerInfo in pairs(GameRules.XW.PlayerList) do
        if playerInfo.IsEmpty == false then
            -- 每日任务数据
            playerInfo:SaveTaskData()
            if table.contains(teams, playerInfo.TeamId) == false then
                table.insert(teams, playerInfo.TeamId)
            end

            local lastTime = playerInfo.TimeOfDeath
            local h = math.floor(lastTime / 3600)
            local m = math.floor((lastTime - 3600 * h) / 60)
            local s = math.floor(lastTime - 3600 * h - 60 * m)
            lastTime = string.format("%02d:%02d:%02d", h, m, s)

            local rank = playerInfo.Rank
            if rank == 1 then
                -- 给账户加头上的元宝
                if playerInfo.BountyBullion > 0 and playerInfo.IsBot == false then
                    -- 每周任务数据
                    playerInfo.TaskTable.win_count = playerInfo.TaskTable.win_count + 1

                    if CardGroupSystem:CheckHasPetCard(playerId) then
                        playerInfo.TaskTable.use_pet_to_win_count = playerInfo.TaskTable.use_pet_to_win_count + 1
                    end

                    -- 会员加倍
                    if playerInfo.IsVip then
                        playerInfo.BountyBullion = playerInfo.BountyBullion * 2
                    end

                    playerInfo.SavedBullion = playerInfo.SavedBullion + playerInfo.BountyBullion
                    local postData = { SteamAccountId = playerInfo.SteamAccountId, GameId = GameRules.XW.GameId, amount = playerInfo.BountyBullion, remark = 'WINNER_BOUNTY' }
                    HttpPost("api/Member/DepositBullion", postData, function(result)
                        -- if(result.isSuccess) then
                        --     killerPlayerInfo.Hero:ShowCustomMessage({type="bottom", msg={playerInfo.BountyBullion, "xxwar_increase_bullion"}, class="success"})
                        -- else
                        --     ShowGlobalMessage(result.message)
                        -- end
                    end)
                end
            end
            local data = {
                playerId = playerId,
                teamId = playerInfo.TeamId,
                steamId = playerInfo.SteamId,
                steamAccountId = playerInfo.SteamAccountId,
                playerName = playerInfo.PlayerName,
                isBot = playerInfo.IsBot,
                lastTime = lastTime,
                rank = rank,
                kills = PlayerResource:GetKills(playerId),
                assists = PlayerResource:GetAssists(playerId),
                goldTotal = 0,
                savedBullion = playerInfo.SavedBullion,
            }
            local hero = playerInfo.Hero
            if NotNull(hero) then
                data.goldTotal = math.floor(hero:GetTotalGold())
            end
            table.insert(endTable, data)
        end
    end

    local playerCount = #endTable

    table.sort(endTable, function(a, b)
        if a.rank ~= b.rank then
            return playerCount - a.rank > playerCount - b.rank
        end
        if a.kills ~= b.kills then
            return a.kills > b.kills
        end
        if a.assists ~= b.assists then
            return a.assists > b.assists
        end
        return a.playerId < b.playerId
    end)

    for _, v in ipairs(endTable) do
        v.bullionJackpot = GameRules.XW:GetJackpotShare(#teams, v.rank, true)

        -- 会员拿奖池的时候加倍
        local playerInfo = GameRules.XW:GetPlayerInfo(v.playerId)
        if playerInfo and playerInfo.IsVip then
            v.bullionJackpot = v.bullionJackpot * 2
        end
    end

    CustomNetTables:SetTableValue("end_game_table", "end_info", endTable)

    local postData = {GameId = GameRules.XW.GameId, EndTable = endTable}
    HttpPost("api/Game/GameEnd", postData, function(result)
        if(result.isSuccess) then
            -- ShowGolbalMessage("Game result uploaded.")
            CustomNetTables:SetTableValue("end_game_table", "score_info", result.tag)
        else
            ShowGolbalMessage(result.message)
        end
    end)

    CreateTimer(function()
        EmitGlobalSound(SoundRes.GAME_OVER)
        GameRules:SetGameWinner(self.WinnerTeam)
    end, 3)
end

function GameManager:CheckGameIsOver()
    local teamCounts = {}
    local remainTeam = 0
    local winnerTeam = nil
    for playerId, playerInfo in pairs(GameRules.XW.PlayerList) do
        if playerInfo.IsEmpty == false and playerInfo.IsAlive == true then
            if teamCounts[playerInfo.TeamId] == nil then
                teamCounts[playerInfo.TeamId] = 1
                remainTeam = remainTeam + 1
                winnerTeam = playerInfo.TeamId
            end
        end
    end

    -- if remainTeam == 2 then
    --     CustomMessage:all({
    --         type="message-box", 
    --         role="xxwar_system_notification",
    --         list={{text="xxwar_respawn_close", args={}}},
    --     })
    -- end

    if remainTeam == 1 then
        self.IsGameOver = true
        self.WinnerTeam = winnerTeam
        return true
    end
    return false
end

function GameManager:GetGameStartTime()
    return self.GameStartTime
end

function GameManager:CheckTeamIsAlive(teamId)
    for playerId, playerInfo in pairs(GameRules.XW.PlayerList) do
        if playerInfo.TeamId == teamId and playerInfo.IsAlive == true then
            return true
        end
    end
    return false
end

function GameManager:SetTeamDeathTime(teamId, time)
    for playerId, playerInfo in pairs(GameRules.XW.PlayerList) do
        if playerInfo.TeamId == teamId then
            playerInfo.TimeOfDeath = time
        end
    end
end

function GameManager:UpdatePlayersRank()
    local teamDeathTimeTable = {}
    for playerId, playerInfo in pairs(GameRules.XW.PlayerList) do
        if playerInfo.IsEmpty == false then
            local isExist = false
            for _, v in pairs(teamDeathTimeTable) do
                if v.TeamId == playerInfo.TeamId then
                    isExist = true
                end
            end

            if isExist == false then
                if playerInfo.IsAlive then
                    self:SetTeamDeathTime(playerInfo.TeamId, GameManager:GetGameTime() + 1)
                end

                local teamDeathInfo = {
                    TeamId = playerInfo.TeamId,
                    TimeOfDeath = playerInfo.TimeOfDeath
                }
                table.insert(teamDeathTimeTable, teamDeathInfo)
            end
        end
    end

    table.sort(teamDeathTimeTable, function(a, b)
        return a.TimeOfDeath > b.TimeOfDeath
    end)

    local rank = 1
    for _, v in ipairs(teamDeathTimeTable) do
        for playerId, playerInfo in pairs(GameRules.XW.PlayerList) do
            if playerInfo.TeamId == v.TeamId then
                playerInfo.Rank = rank
            end
        end
        rank = rank + 1
    end
end

function GameManager:GetAliveTeamCount()
    local teamState = {}
    local aliveTeam = 0
    for _, playerInfo in pairs(GameRules.XW.PlayerList) do
        if playerInfo.IsEmpty == false and playerInfo.IsAlive == true then
            if teamState[playerInfo.TeamId] == nil then
                teamState[playerInfo.TeamId] = true
                aliveTeam = aliveTeam + 1
            end
        end
    end
    return aliveTeam
end

function GameManager:SetPlayerInitDatas()
    for playerId, playerInfo in pairs(GameRules.XW.PlayerList) do
        if playerInfo.IsEmpty == false and playerInfo.Hero ~= nil then
            CardGroupSystem:InitPlayerCards(playerId)
            if playerInfo.IsBot == false then
                playerInfo:GetTaskData()
            end

            -- if playerInfo.IsBot then
                playerInfo.Hero:SetCustomAttribute("max_crystal", "max_crystal", 10)
                playerInfo.Hero:SetCustomAttribute("crystal_regen", "crystal_regen", 0.5)
                -- playerInfo.Hero:AddItemByName("item_clothes_0105")
                -- playerInfo.Hero:AddItemByName("item_gloves_0105")
                -- playerInfo.Hero:AddItemByName("item_hat_0105")
                -- playerInfo.Hero:AddItemByName("item_shoes_0105")
                -- playerInfo.Hero:AddItemByName("item_trinket_0105")
                -- playerInfo.Hero:AddItemByName("item_weapon_0705")
            -- end
        end
    end
end

function GameManager:GetGameTime()
    if GameManager.StartTimeStamp ~= nil then
        return GameRules:GetGameTime() - GameManager.StartTimeStamp
    end
    return GameRules:GetGameTime()
end

function GameManager:IsInPalace(hero)
    if IsAlive(hero) then
        local location = hero:GetAbsOrigin()
        if location.x > -GameRules.XW.PalaceSize and location.x < GameRules.XW.PalaceSize and location.y > -GameRules.XW.PalaceSize and location.y < GameRules.XW.PalaceSize then
            return true
        end
    end

    return false
end

function GameManager:IsInPalaceDead(hero)
    if NotNull(hero) then
        local location = hero:GetAbsOrigin()
        if location.x > -GameRules.XW.PalaceSize and location.x < GameRules.XW.PalaceSize and location.y > -GameRules.XW.PalaceSize and location.y < GameRules.XW.PalaceSize then
            return true
        end
    end

    return false
end

function GameManager:GetPalaceOccupyingTeam()
    local teams = {}
    for _, playerInfo in pairs(GameRules.XW.PlayerList) do
        if playerInfo.IsEmpty == false and playerInfo.IsAlive == true then
            if GameManager:IsInPalace(playerInfo.Hero) then
                if table.contains(teams, playerInfo.TeamId) == false then
                    table.insert(teams, playerInfo.TeamId)
                end
            end
        end
    end

    if #teams == 1 then
        return teams[1], false
    end

    if NotNull(GameRules.XW.OutpostCenter) then
        local team = GameRules.XW.OutpostCenter:GetTeamNumber()
        if team >= DOTA_TEAM_CUSTOM_1 and team <= DOTA_TEAM_CUSTOM_8 then
            return team, #teams > 1
        end
    end

    return nil, #teams > 1
end
