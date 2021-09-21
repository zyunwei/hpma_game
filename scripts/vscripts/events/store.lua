CustomEvents('store_update_coin_info', function(e, data)
    if data == nil or data.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end

	local playerInfo = GameRules.XW:GetPlayerInfo(data.PlayerID)
    if playerInfo == nil or playerInfo.IsEmpty then return end

	local hero = player:GetAssignedHero()
	if IsNull(hero) then return end

	local postData = { SteamAccountId = playerInfo.SteamAccountId, GameId = GameRules.XW.GameId }
    HttpPost("api/Member/GetCoinInfo", postData, function(result)
        if(result.isSuccess and result.tag ~= nil) then
        	playerInfo.XXCoin = result.tag.coin
        	playerInfo.Bullion = result.tag.bullion
        	playerInfo.RespawnCoin = result.tag.respawnCoin
        else
        	playerInfo.XXCoin = 0
        	playerInfo.Bullion = 0
        	playerInfo.RespawnCoin = 0
        end
    end)
end)

CustomEvents('store_redeem_gift', function(e, data)
    if data == nil or data.PlayerID == nil then return end
    local player = PlayerResource:GetPlayer(data.PlayerID)
    if IsNull(player) then return end

    local playerInfo = GameRules.XW:GetPlayerInfo(data.PlayerID)
    if playerInfo == nil or playerInfo.IsEmpty then return end

    local hero = player:GetAssignedHero()
    if IsNull(hero) then return end

    local postData = { SteamAccountId = playerInfo.SteamAccountId, GameId = GameRules.XW.GameId, WeChat = data.wechat, ItemName = data.itemName, }
    HttpPost("api/MemberStore/RedeemGift", postData, function(result)
        CustomGameEventManager:Send_ServerToPlayer(player, "store_msg_response", result)
    end)
end)

CustomEvents('store_buy_item', function(e, data)
    if data == nil or data.PlayerID == nil then return end
    local player = PlayerResource:GetPlayer(data.PlayerID)
    if IsNull(player) then return end

    local playerInfo = GameRules.XW:GetPlayerInfo(data.PlayerID)
    if playerInfo == nil or playerInfo.IsEmpty then return end

    local hero = player:GetAssignedHero()
    if IsNull(hero) then return end

    local itemConfig = nil
    for _, v in pairs(STORE_CONFIG.ItemList) do
        if v.name == data.name and v.price_type == data.price_type then
            itemConfig = v
            break
        end
    end

    if itemConfig == nil then return end

    local postData = {
        SteamAccountId = playerInfo.SteamAccountId,
        GameId = GameRules.XW.GameId,
        ItemName = data.name,
        ItemType = data.type,
        Price = itemConfig.price,
        PriceType = itemConfig.price_type,
        Amount = data.amount,
    }

    HttpPost("api/MemberStore/BuyItem", postData, function(result)
        if(result.isSuccess and data.name == "xxwar_vip_monthly") then
            playerInfo.IsVip = 1
        end

        CustomGameEventManager:Send_ServerToPlayer(player, "store_msg_response", result)
    end)
end)

CustomEvents('store_get_inventory', function(e, data)
    if data == nil or data.PlayerID == nil then return end
    local player = PlayerResource:GetPlayer(data.PlayerID)
    if IsNull(player) then return end

    local playerInfo = GameRules.XW:GetPlayerInfo(data.PlayerID)
    if playerInfo == nil or playerInfo.IsEmpty then return end

    local hero = player:GetAssignedHero()
    if IsNull(hero) then return end

    local postData = {
        SteamAccountId = playerInfo.SteamAccountId,
    }
    
    HttpPost("api/MemberStore/GetStoreItems", postData, function(result)
        if(result.isSuccess and result.tag ~= nil) then
            CustomNetTables:SetTableValue("PlayerStoreItems", tostring(data.PlayerID), result.tag)
            CustomGameEventManager:Send_ServerToPlayer(player, "store_refresh_inventory_notify", result)
        else
            playerInfo.StoreItems = {}
        end
    end)
end)

CustomEvents('store_get_lottery_point', function(e, data)
    if data == nil or data.PlayerID == nil then return end
    local player = PlayerResource:GetPlayer(data.PlayerID)
    if IsNull(player) then return end

    local playerInfo = GameRules.XW:GetPlayerInfo(data.PlayerID)
    if playerInfo == nil or playerInfo.IsEmpty then return end

    local hero = player:GetAssignedHero()
    if IsNull(hero) then return end

    local postData = {
        SteamAccountId = playerInfo.SteamAccountId,
    }
    
    HttpPost("api/MemberStore/GetLotteryPoint", postData, function(result)
        if(result.isSuccess and result.tag ~= nil) then
            CustomGameEventManager:Send_ServerToPlayer(player, "store_refresh_lottery_notify", result)
        end
    end)
end)

CustomEvents('store_use_lottery_point', function(e, data)
    if data == nil or data.PlayerID == nil then return end
    local player = PlayerResource:GetPlayer(data.PlayerID)
    if IsNull(player) then return end

    local playerInfo = GameRules.XW:GetPlayerInfo(data.PlayerID)
    if playerInfo == nil or playerInfo.IsEmpty then return end

    local hero = player:GetAssignedHero()
    if IsNull(hero) then return end

    local tenDraw = data.tenDraw or 0

    if tenDraw == 1 then
        local giftIndexTable = {}
        local giftIndexStr = ""
        for i = 1, 10 do
            local gift = RollLottery()
            table.insert(giftIndexTable, gift)
            giftIndexStr = giftIndexStr .. "," .. gift
        end

        local postData = {
            SteamAccountId = playerInfo.SteamAccountId,
            GameId = GameRules.XW.GameId,
            GiftIndexList = string.sub(giftIndexStr, 2),
        }

        HttpPost("api/MemberStore/UseLotteryPointTenTimes", postData, function(result)
            if(result.isSuccess and result.tag ~= nil) then
                result.giftIndexTable = giftIndexTable
                CustomGameEventManager:Send_ServerToPlayer(player, "store_lottery_ten_draw_notify", result)
            end
        end)
    else
        local postData = {
            SteamAccountId = playerInfo.SteamAccountId,
            GameId = GameRules.XW.GameId,
            GiftIndex = RollLottery(),
        }
        
        HttpPost("api/MemberStore/UseLotteryPoint", postData, function(result)
            if(result.isSuccess and result.tag ~= nil) then
                result.giftIndex = postData.GiftIndex - 1
                CustomGameEventManager:Send_ServerToPlayer(player, "store_lottery_start_notify", result)
            end
        end)
    end
end)

CustomEvents('store_open_card', function(e, data)
    if data == nil or data.PlayerID == nil then return end
    local player = PlayerResource:GetPlayer(data.PlayerID)
    if IsNull(player) then return end

    local playerInfo = GameRules.XW:GetPlayerInfo(data.PlayerID)
    if playerInfo == nil or playerInfo.IsEmpty then return end

    local hero = player:GetAssignedHero()
    if IsNull(hero) then return end

    local postData = {
        SteamAccountId = playerInfo.SteamAccountId,
        GameId = GameRules.XW.GameId,
        ItemName = data.itemName,
    }

    local itemCount = 0

    local storeItems = CustomNetTables:GetTableValue("PlayerStoreItems", tostring(data.PlayerID))
    if storeItems then
        local itemInfo = table.find(storeItems, "ItemName", data.itemName)
        if itemInfo ~= nil then
            itemCount = itemInfo.Count
        end
    end

    if itemCount >= 10 then
        HttpPost("api/MemberStore/OpenCardTenTimes", postData, function(result)
            CustomGameEventManager:Send_ServerToPlayer(player, "store_msg_response_opencard_ten_times", result)
        end)
    else
        HttpPost("api/MemberStore/OpenCard", postData, function(result)
            CustomGameEventManager:Send_ServerToPlayer(player, "store_msg_response_opencard", result)
        end)
    end
end)

CustomEvents('store_recycle_card', function(e, data)
    if data == nil or data.PlayerID == nil then return end
    local player = PlayerResource:GetPlayer(data.PlayerID)
    if IsNull(player) then return end

    local playerInfo = GameRules.XW:GetPlayerInfo(data.PlayerID)
    if playerInfo == nil or playerInfo.IsEmpty then return end

    local hero = player:GetAssignedHero()
    if IsNull(hero) then return end

    ModalDialog(hero, {
        type = "CommonForLua",
        title = "xxwar_dialog_recycle_card",
        text = "xxwar_dialog_recycle_card_confirm",
        style = "warning",
        options = {
            {
                key = "YES",
                func = function ()
                    local postData = {
                        SteamAccountId = playerInfo.SteamAccountId,
                        GameId = GameRules.XW.GameId,
                        ItemName = data.itemName,
                    }

                    HttpPost("api/MemberStore/RecycleCard", postData, function(result)
                        CustomGameEventManager:Send_ServerToPlayer(player, "store_msg_response", result)
                    end)
                end,
            },
            {
                key = "NO",
                func = function ()
                    CustomGameEventManager:Send_ServerToPlayer(player, "store_msg_response_cancel", {})
                end,
            },
        },
    })
end)

CustomEvents('store_present_card', function(e, data)
    if data == nil or data.PlayerID == nil then return end
    local player = PlayerResource:GetPlayer(data.PlayerID)
    if IsNull(player) then return end

    local playerInfo = GameRules.XW:GetPlayerInfo(data.PlayerID)
    if playerInfo == nil or playerInfo.IsEmpty then return end

    local hero = player:GetAssignedHero()
    if IsNull(hero) then return end

    local postData = {
        SteamAccountId = playerInfo.SteamAccountId,
        GameId = GameRules.XW.GameId,
        ItemName = data.itemName,
        TargetAccount = data.targetAccount
    }

    HttpPost("api/MemberStore/PresentCard", postData, function(result)
        CustomGameEventManager:Send_ServerToPlayer(player, "store_msg_response", result)
    end)
end)

CustomEvents('store_pay_request', function(e, data)
    if data == nil or data.PlayerID == nil then return end
    local player = PlayerResource:GetPlayer(data.PlayerID)
    if IsNull(player) then return end

    local playerInfo = GameRules.XW:GetPlayerInfo(data.PlayerID)
    if playerInfo == nil or playerInfo.IsEmpty then return end

    local hero = player:GetAssignedHero()
    if IsNull(hero) then return end

    local playerId = data.PlayerID
    local paytype = data.paytype
    local amount = data.amount

    local postData = {steamAccountId = playerInfo.SteamAccountId, depositType = paytype, depositAmount = amount }
    HttpPost("api/cashier/depositapply", postData, function(result)
        if(result.isSuccess) then
            CustomGameEventManager:Send_ServerToPlayer(player, "store_msg_response_pay", {url = result.message})
        else
            CustomGameEventManager:Send_ServerToPlayer(player, "store_msg_response", result)
        end
    end)
end)

CustomEvents('check_last_deposit', function(e, data)
    if data == nil or data.PlayerID == nil then return end
    local player = PlayerResource:GetPlayer(data.PlayerID)
    if IsNull(player) then return end

    local playerInfo = GameRules.XW:GetPlayerInfo(data.PlayerID)
    if playerInfo == nil or playerInfo.IsEmpty then return end

    local hero = player:GetAssignedHero()
    if IsNull(hero) then return end

    local playerId = data.PlayerID
    local paytype = data.paytype
    local amount = data.amount

    local postData = {steamAccountId = playerInfo.SteamAccountId, depositType = paytype, depositAmount = amount}
    HttpPost("api/cashier/checklastdeposit", postData, function(result)
        if(result.isSuccess) then
            CustomGameEventManager:Send_ServerToPlayer(player, "last_deposit_success", {})
        end
    end)
end)
