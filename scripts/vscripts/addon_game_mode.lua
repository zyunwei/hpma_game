require "libs.utils"
require "libs.timers"
require "res_def"
require "player_info"
require "game_manager"
require "ai_boss"
require "ai_summon"

XXW = XXW or class({})

local state = GameRules:State_Get()
if state > DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
    print("reload script")
    require("autoload")
end

_G['autoload'] = function (t,prefix)
    prefix = prefix or ""
    if prefix == "" then
        for i,v in ipairs(t) do
            require(v)
        end
    else
        prefix = prefix..'.'
        for i,v in ipairs(t) do
            require(prefix..v)
        end
    end
end

function Precache( context )
    for _, v in pairs(PrecacheHeroList) do
        PrecacheUnitByNameSync(v, context)
    end

    for _, v in pairs(PreloadSounds) do
        PrecacheResource("soundfile", v, context)
    end

    for _, v in pairs(PreloadParticles) do
        PrecacheResource("particle", v, context)
    end

    for _, v in pairs(PreloadModels) do
        PrecacheResource("model", v, context)
    end
end

function Activate()
    GameRules.AddonTemplate = XXW()
    GameRules.AddonTemplate:InitGameMode()
end

function XXW:InitGameMode()
    GameRules.XW.SVR_KEY = GetDedicatedServerKeyV2("DDW")
    GameRules.XW.SVR = bSvrDecode2(GameRules.XW.SVR_KEY)
	GameRules.XW.MapName = GetMapName()
    GameRules.XW.MatchID = tostring(GameRules:Script_GetMatchID())

    SendToServerConsole("dota_max_physical_items_purchase_limit 9999")
    SendToServerConsole("dota_pause_count 1")
    SendToServerConsole("dota_reconnect_idle_buffer_time 360")
    SendToServerConsole("dota_idle_acquire 0")
    SendToServerConsole("dota_idle_time 3600")
    SendToServerConsole("dota_max_disconnected_time 3600")
    SendToServerConsole("dota_lenient_idle_time 4800")
    SendToServerConsole("dota_camera_distance 1300")

    require('autoload')
end

if GameRules.XW == nil then
    GameRules.XW = {}
    GameRules.XW.IndependentAbilities = LoadKeyValues("scripts/kv/independent_abilities.kv")
    GameRules.XW.GameId = ""
    GameRules.XW.SVR = ""
    GameRules.XW.SVR_KEY = ""
    GameRules.XW.MapName = ""
    GameRules.XW.MatchID = "0"
    GameRules.XW.PlayerList = {}
    GameRules.XW.IsGameOver = false
    GameRules.XW.MapSize = 8000
    GameRules.XW.MapBorderSize = 8900
    GameRules.XW.RegionCreepRefreshTickTime = 60
    GameRules.XW.CompensateTickTime = 30
    GameRules.XW.BuyBossOpenTime = 300
    GameRules.XW.Jackpot = 0
    GameRules.XW.PlayerBonusExpTickTime = 60
    GameRules.XW.GlobalJackpot = "Loading.."
    GameRules.XW.GlobalJackpotUpdateTime = 0
    GameRules.XW.AutoReleaseBossCount = 0
    GameRules.XW.TaskIndicatorNames = {
        [1] = "boss_kill_count",
        [2] = "player_kill_count",
        [3] = "win_count",
        [4] = "respawn_count",
        [5] = "open_treasure_count",
        [6] = "jump_count",
        [7] = "creep_kill_count",
        [8] = "use_repsawn_coin_count",
        [9] = "summon_boss_lv3_count",
        [10] = "buy_ability_book_count",
        [11] = "get_new_card_count",
        [12] = "use_pet_to_win_count",
    }
    GameRules.XW.TaskIndicators = {
        [1] = 50,
        [2] = 50,
        [3] = 10,
        [4] = 20,
        [5] = 200,
        [6] = 1500,
        [7] = 1000,
        [8] = 10,
        [9] = 10,
        [10] = 100,
        [11] = 10,
        [12] = 10,
    }

    GameRules.XW.MaxPlayerCount = 2

    GameRules.XW.TeamColor = {
        [DOTA_TEAM_CUSTOM_1] = {0, 120, 60},
        [DOTA_TEAM_CUSTOM_2] = {220, 220, 50},
        [DOTA_TEAM_CUSTOM_3] = {110, 70, 180},
        [DOTA_TEAM_CUSTOM_4] = {0, 110, 210},
        [DOTA_TEAM_CUSTOM_5] = {245, 143, 152},
        [DOTA_TEAM_CUSTOM_6] = {101, 212, 19},
        [DOTA_TEAM_CUSTOM_7] = {27, 192, 216},
        [DOTA_TEAM_CUSTOM_8] = {141, 208, 243}
    }

    GameRules.XW.PalaceWinTime = 300
    GameRules.XW.PalaceSize = 1350
    GameRules.XW.PalaceTime = {
        [DOTA_TEAM_CUSTOM_1] = 0,
        [DOTA_TEAM_CUSTOM_2] = 0,
        [DOTA_TEAM_CUSTOM_3] = 0,
        [DOTA_TEAM_CUSTOM_4] = 0,
        [DOTA_TEAM_CUSTOM_5] = 0,
        [DOTA_TEAM_CUSTOM_6] = 0,
        [DOTA_TEAM_CUSTOM_7] = 0,
        [DOTA_TEAM_CUSTOM_8] = 0,
    }
    GameRules.XW.LastOccupyTeam = -1
    GameRules.XW.Outposts = {}
    GameRules.XW.OutpostCenter = nil
    GameRules.XW.OutpostTeam = DOTA_TEAM_BADGUYS

    -- 测试开关
    GameRules.XW.EnableAutoUse = true
    GameRules.XW.DynamicVision = true
    GameRules.XW.EnableCreepRefresh = true
    GameRules.XW.EnableMinor = true

    for playerId = 0, GameRules.XW.MaxPlayerCount - 1 do
        GameRules.XW.PlayerList[playerId] = PlayerInfo:New()
    end
end

function GameRules.XW:StartThink()
    GameRules.LastTick = 0
    GameRules:GetGameModeEntity():SetThink("OnThink", self, 0)
end

function GameRules.XW:GetStageInfo()
    return {
        Stage = GameManager.Stage,
        StageName = GameManager.StageName[GameManager.Stage]
    }
end

function GameRules.XW:GetPlayerInfo(playerId)
    if playerId == nil then
        return nil
    end

    return GameRules.XW.PlayerList[playerId]
end

function GameRules.XW:IsDeveloper(playerId)
    if playerId == nil then
        return nil
    end

    local idlist = {"150032927", "971380541"}
    local id = tostring(PlayerResource:GetSteamAccountID(playerId))
    return table.contains(idlist, id)
end

function GameRules.XW:OnThink()
    if GameRules.XW.IsGameOver then return nil end

    xpcall(function() GameManager:OnThink() end, ShowGolbalMessage)
    return 1
end

function GameRules.XW:FindPlayerInSameRegion(playerId)
    local info = GameRules.XW:GetPlayerInfo(playerId)
    local regionId = info:GetStayRegionId()
    local teamId = info.TeamId
    local res = {}
    for _, playerInfo in pairs(GameRules.XW.PlayerList) do
        if playerInfo.TeamId ~= teamId and playerInfo:GetStayRegionId() == regionId and NotNull(playerInfo.Hero) then
            table.insert(res, playerInfo.Hero)
            local ownedunits = playerInfo.Hero:GetAdditionalOwnedUnits()
            for _, unit in ipairs(ownedunits) do
                table.insert(res, unit)
            end
            local pets = CallHeroPool:GetPlayerPets(playerId)

            for _, unit in ipairs(pets) do
                table.insert(res, unit)
            end
        end
    end
    return res
end

function GameRules.XW:GetJackpotShare(teamCount, rank, calculateRatio)
    local jackpotAmount = GameRules.XW.Jackpot
    local calculateRatio = GameRules.XW:GetJackpotRatio()

    if teamCount > 0 and teamCount <= 4 then
        if rank == 1 then
            return math.floor(jackpotAmount * calculateRatio * 1.0)
        end
    elseif teamCount > 4 and teamCount <= 7 then
        if rank == 1 then
            return math.floor(jackpotAmount * calculateRatio * 0.7)
        end
        if rank == 2 then
            return math.floor(jackpotAmount * calculateRatio * 0.3)
        end
    else
        if rank == 1 then
            return math.floor(jackpotAmount * calculateRatio * 0.5)
        end
        if rank == 2 then
            return math.floor(jackpotAmount * calculateRatio * 0.3)
        end
        if rank == 3 then
            return math.floor(jackpotAmount * calculateRatio * 0.2)
        end
    end

    return 0
end

function GameRules.XW:GetJackpotShareCount(teamCount)
    if teamCount > 0 and teamCount <= 4 then
        return 1
    elseif teamCount > 4 and teamCount <= 7 then
        return 2
    else
        return 3
    end

    return 1
end

function GameRules.XW:GetJackpotRatio()
    return 1.0
end
