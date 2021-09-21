CustomEvents('event_get_compose_table', function(e, data)
    if data == nil or data.PlayerID == nil then return end
    local player = PlayerResource:GetPlayer(data.PlayerID)
    if IsNull(player) then return end
    CustomGameEventManager:Send_ServerToPlayer(player, "event_get_compose_table_response", {data=ItemComposeTable})
end)

CustomEvents('event_get_item_config_table', function(e, data)
    if data == nil or data.PlayerID == nil then return end
    local player = PlayerResource:GetPlayer(data.PlayerID)
    if IsNull(player) then return end
    CustomGameEventManager:Send_ServerToPlayer(player, "event_get_item_config_table_response", {data=ItemConfig})
end)

CustomEvents('event_get_compose_classify_table', function(e, data)
    if data == nil or data.PlayerID == nil then return end
    local player = PlayerResource:GetPlayer(data.PlayerID)
    if IsNull(player) then return end
    CustomGameEventManager:Send_ServerToPlayer(player, "event_get_compose_classify_table_response", {data=ItemComposeClassifyTable})
end)

CustomEvents('event_get_boss_config_table', function(e, data)
    if data == nil or data.PlayerID == nil then return end
    local player = PlayerResource:GetPlayer(data.PlayerID)
    if IsNull(player) then return end
    CustomGameEventManager:Send_ServerToPlayer(player, "event_get_boss_config_table_response", {data=BossConfigTable})
end)