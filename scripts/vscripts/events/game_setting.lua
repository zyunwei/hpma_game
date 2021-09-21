CustomEvents('ADD_BOT', function(e, data)
    if data == nil or data.PlayerID == nil then return end
    local hostPlayerId = data.PlayerID
    if GameRules:PlayerHasCustomGameHostPrivileges(PlayerResource:GetPlayer(hostPlayerId)) == false then
        return false
    end

    local playerCount = PlayerResource:GetPlayerCount()
    if(playerCount >= GameRules.XW.MaxPlayerCount) then
        return
    end

    -- local addCount = 1
    local teams = {
        DOTA_TEAM_CUSTOM_1, DOTA_TEAM_CUSTOM_2, 
        DOTA_TEAM_CUSTOM_3, DOTA_TEAM_CUSTOM_4,
        DOTA_TEAM_CUSTOM_5, DOTA_TEAM_CUSTOM_6,
        DOTA_TEAM_CUSTOM_7, DOTA_TEAM_CUSTOM_8
    }

    local teamMaxPlayerCount = 1

    local teamCount = {}
    local targetTeam = DOTA_TEAM_NOTEAM
    for _, v in pairs(teams) do
        local count = PlayerResource:GetPlayerCountForTeam(v)
        if count < teamMaxPlayerCount then
            targetTeam = v
            break
        end
    end

    if targetTeam == DOTA_TEAM_NOTEAM then
        return
    end

    local randomHero = "npc_dota_hero_" .. table.random(GameManager.AllHeroNames)

    local bot = GameRules:AddBotPlayerWithEntityScript(randomHero, 'bot ' .. tostring(math.random(100)), targetTeam, nil, false)
    if bot ~= nil then
        local botPlayerId = bot:GetPlayerID()
        local playerInfo = GameRules.XW.PlayerList[botPlayerId]
        playerInfo:SetAsBot(botPlayerId)
    end
end)
