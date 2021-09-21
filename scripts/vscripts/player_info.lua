require "modifiers.hero_base_modifier"

if PlayerInfo == nil then
    PlayerInfo = {}
    PlayerInfo.__index = PlayerInfo
end

function PlayerInfo:New(o)
    o = o or {
        Hero = nil,
        IsOnline = false,
        IsAlive = false,
        SteamId = "",
        SteamAccountId = "",
        Grade = 1,
        IsVip = 0,
        PlayerName = "",
        IsBot = false,
        IsEmpty = true,
        Pack = nil,
        TeamId = DOTA_TEAM_NOTEAM,
        BlockRegionAccessCountDown = 10,
        NowRegionId = -1,
        InBlockadeTime = 0,
        LastInBlockadeTime = 0,
        IsInSafeArea = false,
        TombStone = nil,
        ShowDeathFrame = false,
        XXCoin = "..",
        RespawnCoin = "..",
        Bullion = "..",
        RespawnCount = 0,
        BountyBullion = 0,
        LastKillerPlayerId = nil,
        ReplacedItems = {},
        Rank = 0,
        TimeOfDeath = 0,
        SavedBullion = 0,
        SavedItems = {},
        ImgItem = {
            Crystal_Maiden_icon = 0,
            Meepo_icon = 0,
            Shadow_Fiend_icon = 0,
            Changeable = 0,
        },
        ServerTaskTable = {
            boss_kill_count = 0,
            player_kill_count = 0,
            win_count = 0,
            respawn_count = 0,
            open_treasure_count = 0,
            jump_count = 0,
            creep_kill_count = 0,
            use_repsawn_coin_count = 0,
            summon_boss_lv3_count = 0,
            buy_ability_book_count = 0,
            get_new_card_count = 0,
            use_pet_to_win_count = 0,
        },
        TaskTable = {
            boss_kill_count = 0,
            player_kill_count = 0,
            win_count = 0,
            respawn_count = 0,
            open_treasure_count = 0,
            jump_count = 0,
            creep_kill_count = 0,
            use_repsawn_coin_count = 0,
            summon_boss_lv3_count = 0,
            buy_ability_book_count = 0,
            get_new_card_count = 0,
            use_pet_to_win_count = 0,
        },
        LastPlayFightMusicTime = -15
    }
    setmetatable(o, self)
    self.__index = self

    return o
end

function PlayerInfo:PickHero(hero)
    local baseModifier = hero:FindModifierByName("modifier_hero_base")
    if(baseModifier == nil) then
        hero:AddNewModifier(hero, nil, "modifier_hero_base", {})
    end
    
    self.Hero = hero
    self.IsAlive = true

    for i = 1, 29 do
        hero:HeroLevelUp(false)
    end

    self:DownloadSavedItem(hero:GetName())
    self:DownloadImgItem()

    self:CheckLoginGift()
    
    -- 所有英雄：0-4小技能 5预载小技能 6移动技能 7-11空技能位 12-17物品 18-31空技能位
    for i = 0, 31 do 
        local ability = hero:GetAbilityByIndex(i)
        -- if ability ~= nil and string.find(ability:GetName(), "special_bonus_") ~= nil then
        if ability ~= nil then
            hero:RemoveAbilityByHandle(ability)
            ability = nil
        end
        if ability == nil then
            hero:AddAbility("xxwar_empty_ability_" .. i)
        end
    end

    for i = 12, 17 do 
        local ability = hero:GetAbilityByIndex(i)
        if ability ~= nil then
            hero:RemoveAbilityByHandle(ability)
            hero:AddAbility(Custom_Item_Spell_Prefix .. (i - 11))
        end
    end

    local ability = hero:GetAbilityByIndex(6)
    if ability ~= nil then
        hero:RemoveAbilityByHandle(ability)
        hero:SetAbility("ability_xxwar_move")
    end

    for i = 18, 31 do
        local ability = hero:GetAbilityByIndex(i)
        if ability ~= nil then
            hero:RemoveAbilityByHandle(ability)
        end
    end
end

function PlayerInfo:SetInfoOnConnectFull(playerId)
    self.SteamId = tostring(PlayerResource:GetSteamID(playerId))
    self.SteamAccountId = tostring(PlayerResource:GetSteamAccountID(playerId))
    self.PlayerName = tostring(PlayerResource:GetPlayerName(playerId))
    self.IsOnline = true
    self.IsBot = false
    self.IsEmpty = false
    CustomNetTables:SetTableValue("PlayerReadyInfo", tostring(playerId), {steamid = self.SteamId, msg = "xxwar_msg_selecting"})
    CardGroupSystem:InitPlayerCardGroups(playerId)
end

function PlayerInfo:SetAsBot(playerId)
    self.IsEmpty = false
    self.IsBot = true
    self.PlayerName = tostring(PlayerResource:GetPlayerName(playerId))
    self.IsOnline = true
    self.IsAlive = true
    -- self.BountyBullion = 150

    local heroes = HeroList:GetAllHeroes()
    for _, hero in pairs (heroes) do
        if hero ~= nil and hero:IsNull() == false then
            if hero:GetPlayerOwnerID() == playerId then
                self.Hero = hero
                -- hero:AddNewModifier(hero, nil, "modifier_black_king_bar_immune", {})
                -- for i = 1, 29 do
                --     hero:HeroLevelUp(false)
                -- end
                -- local ab = hero:AddAbility("riki_permanent_invisibility")
                -- hero:UpgradeAbility(ab)

                AttributesCtrl(hero)
                CustomNetTables:SetTableValue("PlayerHero", tostring(playerId), {HeroEntityIndex = hero:GetEntityIndex()})
                break
            end
        end
    end
end

function PlayerInfo:UpdatePlayerRegion(playerId)
    if self.Hero == nil or self.Hero:IsNull() then
        return
    end
    local changeRegion = false
    local pos = self.Hero:GetAbsOrigin()
    local preRegionId = self.NowRegionId
    self.NowRegionId = BlockadeSystem:GetPointRegionId(pos)
    self.IsInSafeArea = BlockadeSystem:IsInSafeArea(self)
    if preRegionId ~= self.NowRegionId then
        CustomGameEventManager:Send_ServerToPlayer( self.Hero:GetPlayerOwner(), "update_player_region", {RegionId = self.NowRegionId} )
        -- print("player " .. tostring(playerId) .. " to region: " .. tostring(self.NowRegionId))
    end
end

function PlayerInfo:GetStayRegionId()
    return self.NowRegionId
end

function PlayerInfo:OnEnterBlockadeRegion()
    self.LastInBlockadeTime = GameRules:GetGameTime()
end

function PlayerInfo:ApplyBlockadeTime()
    local hero = self.Hero
    if IsNull(hero) then return end
    if not hero:HasModifier("modifier_ability_custom_outlaw_maniac_buff") then
        self.InBlockadeTime = self.InBlockadeTime + GameRules:GetGameTime() - self.LastInBlockadeTime
    end
    self.LastInBlockadeTime = GameRules:GetGameTime()
end

function PlayerInfo:GetInBlockadeTime()
    return self.InBlockadeTime
end

function PlayerInfo:UploadImgItem(itemInfo)
    if itemInfo.name == nil or itemInfo.value == nil then
        return
    end
    local count = 0
    for _, v in pairs(self.ImgItem) do
        count = count + v
    end
    if count >= 9 and itemInfo.value > 0 then return end
    self.ImgItem[itemInfo.name] = self.ImgItem[itemInfo.name] + itemInfo.value
    local postData = { SteamAccountId = self.SteamAccountId, GameId = GameRules.XW.GameId, HeroName = "xxwar_event", ItemInfo = itemInfo }
    HttpPost("api/Member/UpdateSavedItem", postData, function(result)
        if(result.isSuccess) then
            if itemInfo.value > 0 then
                self.Hero:ShowCustomMessage({
                    type="message-box", 
                    role="xxwar_event_message",
                    styles={color="#8b1bf4"},
                    list={{text={"xxwar_get_img", "xxwar_"..itemInfo.name}, args={}}},
                })
            end
        else
            self.Hero:ShowCustomMessage({type="bottom", msg={"xxwar_get_img_fail"}, class="error"})
        end
    end)
end

function PlayerInfo:DownloadImgItem()
    local postData = { SteamAccountId = self.SteamAccountId, GameId = GameRules.XW.GameId, HeroName = "xxwar_event" }
    HttpPost("api/Member/GetMemberSavedItem", postData, function(result)
        if(result.isSuccess) then
            for _, v in ipairs(result.tag) do
                if self.ImgItem ~= nil then
                    self.ImgItem[v.name] = v.value
                end
            end
        end
    end)
end

function PlayerInfo:UploadSavedItem(heroName, itemInfo)
    if itemInfo.name == nil or itemInfo.value == nil or IsNull(self.Hero) then
        return
    end
    local postData = { SteamAccountId = self.SteamAccountId, GameId = GameRules.XW.GameId, HeroName = heroName, ItemInfo = itemInfo }
    HttpPost("api/Member/UpdateSavedItem", postData, function(result)
        if(result.isSuccess) then
            self.Hero:ShowCustomMessage({
                type="message-box", 
                role="xxwar_save_item_notification",
                styles={color="#8b1bf4"},
                list={{text={"xxwar_msg_save_item_upload_success"}, args={}}},
            })
        else
            self.Hero:ShowCustomMessage({
                type="message-box", 
                role="xxwar_save_item_notification",
                styles={color="#8b1bf4"},
                list={{text={"xxwar_msg_save_item_upload_failed"}, args={}}},
            })
        end
    end)
end

function PlayerInfo:DownloadSavedItem(heroName)
    local postData = { SteamAccountId = self.SteamAccountId, GameId = GameRules.XW.GameId, HeroName = heroName }
    HttpPost("api/Member/GetMemberSavedItem", postData, function(result)
        if(result.isSuccess) then
            self.SavedItems = result.tag
            if NotNull(self.Hero) then
                local modifierParams = {}
                for _, v in pairs(self.SavedItems) do
                    modifierParams[v.name] = v.value

                    self.Hero:ShowCustomMessage({
                        type="message-box", 
                        role="xxwar_save_item_notification",
                        styles={color="#8b1bf4"},
                        list={{text={"xxwar_save_item_" .. v.name, ' ' .. string.format("%.2f", tonumber(v.value))}, args={}}},
                    })
                end

                self.Hero:AddNewModifier(self.Hero, nil, "modifier_saved_item", modifierParams)
            end
        end
    end)
end

function PlayerInfo:CheckLoginGift()
    local postData = { SteamAccountId = self.SteamAccountId, GameId = GameRules.XW.GameId }
    HttpPost("api/Member/CheckLoginGift", postData, function(result)
        if(result.isSuccess) then
            self.Hero:ShowCustomMessage({
                type="message-box", 
                role="xxwar_daily_gift_notification",
                styles={color="#82cc00"},
                list={{text={"xxwar_daily_gift_msg"}, args={}}},
            })
        end
    end)
end

-- 为宝宝添加随机物品
function PlayerInfo:AddRandomItemForPet(playerId, forCheckOnly)
    local pets = CallHeroPool:GetPlayerPets(playerId)
    local petsWithSlots = {}
    local itemList = {}
    for _, v in pairs(KV_PET_ITEMS) do
        local hasItem = false
        for _, pet in pairs(pets) do
            if NotNull(pet) and pet:HasItemInInventory(v) then
                hasItem = true
            end

            local itemCount = 0
            for slotIndex = 0, 5 do
                local item = pet:GetItemInSlot(slotIndex)
                if item ~= nil then
                    itemCount = itemCount + 1
                end
            end

            if itemCount < 6 then
                table.insert(petsWithSlots, pet)
            end
        end

        if not hasItem then
            table.insert(itemList, v)
        end
    end

    local targetPet = table.random(petsWithSlots)
    local targetItemName = table.random(itemList)

    if targetItemName and NotNull(targetPet) then
        if forCheckOnly == false then
            local playerInfo = GameRules.XW:GetPlayerInfo(playerId)
            if playerInfo and NotNull(playerInfo.Hero) then
                playerInfo.Hero:ShowCustomMessage({type="bottom", msg={targetPet:GetName(), "xxwar_pet_get_item", "DOTA_Tooltip_ability_"..targetItemName}, class="success"})
            end
            local newItem = CreateItem(targetItemName, targetPet, targetPet)
            if(NotNull(newItem)) then
                newItem:SetPurchaseTime(0)
                newItem:StartCooldown(0)
                targetPet:AddItem(newItem)
            end
        end
        return true
    end

    return false
end

-- 获得玩家需要升级的心法
function PlayerInfo:GetXinFaToBeUpgrade(playerId)
    local playerInfo = GameRules.XW:GetPlayerInfo(playerId)
    if playerInfo == nil or IsNull(playerInfo.Hero) then
        return nil
    end

    local xinFaList = {}

    for xinfaModifier, config in pairs(XINFA_CONFIG) do
        if config.XinFaAbility ~= nil then
            if CardGroupSystem:CheckPlayerHasCard(playerId, config.XinFaAbility) and playerInfo.Hero:HasModifier(xinfaModifier) == false then
                table.insert(xinFaList, {
                    modifierName = xinfaModifier,
                    abilityName = config.XinFaAbility,
                    specialValue = config.SpecialValue,
                    upgradeAbilityName = config.UpgradeAbility,
                })
            end
        end
    end

    return table.random(xinFaList)
end

-- 宝宝气泡说话
function PlayerInfo:PetSay(playerId, pet, words)
    if IsNull(pet) then
        return
    end

    local entIndex = pet:GetEntityIndex()
    local gameTime = GameRules:GetGameTime()

    local petSayTable = CustomNetTables:GetTableValue("pet_say_words", tostring(entIndex))
    if petSayTable == nil then
        petSayTable = {}
    else
        local newTable = {}
        for i, v in pairs(petSayTable) do
            if v.expireTime > gameTime then
                table.insert(newTable, v)
            end
        end
        petSayTable = newTable
    end

    table.insert(petSayTable, {
        words = words,
        expireTime = GameRules:GetGameTime() + 3
    })

    CustomNetTables:SetTableValue("pet_say_words", tostring(entIndex), petSayTable)
end

-- 死亡时说话
function PlayerInfo:HeroSay(playerId, words)
    if IsNull(self.Hero) then
        return
    end

    local entIndex = self.Hero:GetEntityIndex()
    local gameTime = GameRules:GetGameTime()

    local petSayTable = CustomNetTables:GetTableValue("pet_say_words", tostring(entIndex))
    if petSayTable == nil then
        petSayTable = {}
    else
        local newTable = {}
        for i, v in pairs(petSayTable) do
            if v.expireTime > gameTime then
                table.insert(newTable, v)
            end
        end
        petSayTable = newTable
    end

    table.insert(petSayTable, {
        words = words,
        expireTime = GameRules:GetGameTime() + 3
    })

    CustomNetTables:SetTableValue("pet_say_words", tostring(entIndex), petSayTable)
end

function PlayerInfo:GetTaskData()
    local postData = { SteamAccountId = self.SteamAccountId }
    HttpPost("api/MemberTask/GetTaskData", postData, function(result)
        -- table.print(result)
        if result and result.isSuccess then
            self.ServerTaskTable = result.tag
        end
    end)
end

function PlayerInfo:SaveTaskData()
    local postData = { SteamAccountId = self.SteamAccountId, GameId = GameRules.XW.GameId, JsonData = self.TaskTable }
    HttpPost("api/MemberTask/SaveTaskData", postData, function(result)
        -- table.print(result)
    end)
end
