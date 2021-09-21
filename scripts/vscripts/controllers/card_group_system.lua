if CardGroupSystem == nil then
	CardGroupSystem = RegisterController('card_group_system')
end

local public = CardGroupSystem

function public:init()
    if self.__initialized then
        return
    end
    self.__initialized = true
    self.__allAbilities = {}
    local abilityTable = LoadKeyValues("scripts/npc/abilities/custom_minor_abilities.kv")
    for abilityName, v in pairs(abilityTable) do
        if v.IsObsoleted ~= 1 then
            local crystalCost = 0
            for _, spValue in pairs(v.AbilitySpecial) do
                if spValue.crystal_cost ~= nil then
                    crystalCost = tonumber(spValue.crystal_cost)
                    break
                end
            end

            table.insert(self.__allAbilities, {
                AbilityName = abilityName,
                CrystalCost = crystalCost,
                IsHidden = v.IsHidden or 0,
                ForSell = v.ForSell or 0,
                CardType = v.CardType or ""
            })
        end
    end

    self.__cardGroupSize = 10

    self.__playerCardGroups = {}
    self.__playerUsingCardGroup = {}
end

function public:GetDefaultCardGroup(playerId)
    local defaultCardGroup = CardGroup({}, "")
    local allCards = self:PlayerGetAllCards(playerId)
    local count = 0

    local selectedCards = CustomNetTables:GetTableValue("PlayerSelectedCards", tostring(playerId))
    if selectedCards ~= nil then
        for _, v in pairs(selectedCards) do
            defaultCardGroup:AddCardToGroup(v)
            count = count + 1
        end
    end

    if count < 10 then
        for _, v in ipairs(allCards) do
            if v.IsHidden == 0 and v.ForSell == 0 then
                for i = 1, v.MaxCount do
                    defaultCardGroup:AddCardToGroup(v.AbilityName)
                    count = count + 1
                end
            end
            if count >= 10 then break end
        end
    end

    defaultCardGroup:InitDrawCards()
    return defaultCardGroup
end

function public:GetCardInfo(cardName)
    for _, v in pairs(self.__allAbilities) do
        if v.AbilityName == cardName then
            return {
                AbilityName = v.AbilityName,
                CrystalCost = v.CrystalCost,
                CardType = v.CardType,
            }
        end
    end

    return nil
end

function public:InitPlayerCardGroups(playerId)
    if not self.__initialized then
        self:init()
    end
    self.__playerCardGroups[playerId] = {}
end

function public:GetPlayerCardGroups(playerId)
    local result = {}
    if self.__playerCardGroups[playerId] == nil then
        return {}
    end
    for _, v in pairs(self.__playerCardGroups[playerId]) do
        table.insert(result, v:GetCards())
    end
    return result
end

function public:GetPlayerUsingCards(playerId)
    local cardGroup = self.__playerUsingCardGroup[playerId]
    if cardGroup == nil then
        return {}
    end

    local cards = {}
    local cardList = cardGroup:GetCards()
    for _, v in pairs(cardList) do
        table.insert(cards, v.AbilityName)
    end

    return cards
end

function public:GetPlayerCardGroupByIndex(playerId, index)
    if self.__playerCardGroups[playerId] == nil or self.__playerCardGroups[playerId][index] == nil then
        return nil
    end
    return self.__playerCardGroups[playerId][index]:GetCards()
end

function public:PlayerSelectCardGroup(playerId, index)
    if self.__playerCardGroups[playerId] == nil or self.__playerCardGroups[playerId][index] == nil then
        return false
    end

    self.__playerUsingCardGroup[playerId] = CardGroup({}, "")

    self.__playerUsingCardGroup[playerId]:Copy(self.__playerCardGroups[playerId][index])
    self.__playerUsingCardGroup[playerId]:InitDrawCards()

    return true
end

function public:InitPlayerCards(playerId)
    local cardGroup = self.__playerUsingCardGroup[playerId]
    if cardGroup == nil then
        self.__playerUsingCardGroup[playerId] = self:GetDefaultCardGroup(playerId)
        cardGroup = self.__playerUsingCardGroup[playerId]
    end

    if cardGroup == nil then
        return
    end

    local handCardSize = cardGroup.__maxHandsCard
    for i = 1, handCardSize do
        self:PlayerDrawCard(playerId)
    end

    self:PeekCard(playerId)
    self:UpdatePlayerCardGroupState(playerId)
end

function public:UpdatePlayerCardGroupState(playerId)
    local playerInfo = GameRules.XW:GetPlayerInfo(playerId)
    if playerInfo and playerInfo.Hero ~= nil then
        local entIndex = playerInfo.Hero:entindex()
        CustomNetTables:SetTableValue("PlayerCardGroup", "UsingCardGroup_" .. tostring(entIndex), self.__playerUsingCardGroup[playerId]:GetCardStateInfos())
    end
end

function public:PlayerDrawCard(playerId)
    if playerId == nil then return false end
    local cardGroup = self.__playerUsingCardGroup[playerId]
    if cardGroup == nil then
        return false
    end
    local card = cardGroup:DrawCard()
    if card == nil then
        return false
    end

    local playerInfo = GameRules.XW:GetPlayerInfo(playerId)
    if playerInfo == nil or playerInfo.IsEmpty then
        return false
    end

    local hero = playerInfo.Hero
    if IsAlive(hero) == false then
        return false
    end
    local abilityName = card.AbilityName
    if hero:HasAbility(abilityName) then
        return false
    end
    local isSuccess = hero:AppendMinorAbility(abilityName, true, 1, 5)
    self:UpdatePlayerCardGroupState(playerId)

    local max_crystal = hero:GetCustomAttribute("max_crystal")
    if max_crystal ~= nil and max_crystal < card.CrystalCost then
        local ability = hero:FindAbilityByName(abilityName)
        if NotNull(ability) then
            ability:StartCooldownByReduction(ability:GetCooldown(1))
            ability:MinorAbilityUsed()
        end
    end

    return isSuccess
end

function public:PeekCard(playerId)
    if playerId == nil then return nil end
    local cardGroup = self.__playerUsingCardGroup[playerId]
    if cardGroup == nil then
        return nil
    end

    local playerInfo = GameRules.XW:GetPlayerInfo(playerId)
    if playerInfo == nil or playerInfo.IsEmpty or IsNull(playerInfo.Hero) then
        return nil
    end

    local ability = playerInfo.Hero:GetAbilityByIndex(5)
    local preAbilityName = cardGroup:PeekCard()
    if ability ~= nil then
        playerInfo.Hero:RemoveAbilityByHandle(ability)
        playerInfo.Hero:SetAbility(preAbilityName)
    end

    return preAbilityName
end

function public:PlayerFoldCard(playerId, abilityName)
    if playerId == nil then return nil end
    local cardGroup = self.__playerUsingCardGroup[playerId]
    if cardGroup == nil then
        return nil
    end
    local playerInfo = GameRules.XW:GetPlayerInfo(playerId)
    if playerInfo == nil or playerInfo.IsEmpty then
        return nil
    end

    local hero = playerInfo.Hero
    if IsAlive(hero) == false then
        return nil
    end

    hero:RemoveAbilityByName(abilityName)
    cardGroup:FoldCard(abilityName)
    self:UpdatePlayerCardGroupState(playerId)
end

function public:ShowPlayerCardGroupState(playerId)
    table.print(self:GetPlayerCardGroups(playerId))
end

function public:PlayerCreateCardGroup(playerId)
    if not self.__initialized then
        self:init()
    end
    local card_group = CardGroup({}, "")
    if self.__playerCardGroups[playerId] == nil then
        self.__playerCardGroups[playerId] = {}
    end
    table.insert(self.__playerCardGroups[playerId], card_group)
    return #self.__playerCardGroups[playerId]
end

function public:PlayerAddCardToGroup(playerId, cardGroupIndex, cardName)
    if self.__playerCardGroups[playerId] == nil or self.__playerCardGroups[playerId][cardGroupIndex] == nil then
        return false
    end
    local cardGroup = self.__playerCardGroups[playerId][cardGroupIndex]
    return cardGroup:AddCardToGroup(cardName)
end

function public:PlayerGetAllCards(playerId)
    local result = {}
    for _, v in pairs(self.__allAbilities) do
        local cardType = ""
        table.insert(result, {
            AbilityName = v.AbilityName,
            CrystalCost = v.CrystalCost,
            MaxCount = 1,
            HeroLimit = "none",
            CardType = v.CardType,
            IsHidden = v.IsHidden,
            ForSell = v.ForSell,
        })
    end
    return result
end

function public:CheckCardValid(cardName)
    for _, v in pairs(self.__allAbilities) do
        if v.AbilityName == cardName then
            return true
        end
    end
    return false
end

function public:ReplaceCard(playerId, oldCardName, newCardName, replaceHandCards)
    local cardGroup = self.__playerUsingCardGroup[playerId]
    if cardGroup == nil then
        return
    end

    for i = 0, 1 do
        local removeCount = cardGroup:RemoveCardFromGroupByName(oldCardName, replaceHandCards)
        while removeCount > 0 do
            cardGroup:AddCardToGroup(newCardName)
            removeCount = removeCount - 1
        end
    end

    self:UpdatePlayerCardGroupState(playerId)
end

function public:CheckPlayerHasCard(playerId, cardName)
    local cardGroup = self.__playerUsingCardGroup[playerId]
    if cardGroup == nil then
        return false
    end

    local cardList = cardGroup:GetCards()

    local cards = {}
    for _, v in pairs(cardList) do
        table.insert(cards, v.AbilityName)
    end

    if string.find(cardName, "*") ~= nil then
        cardName = string.gsub(cardName, "*", "")
        for _, v in pairs(cards) do
            if string.find(v, cardName) ~= nil then
                return 1
            end
        end
    end

    return table.contains(cards, cardName)
end

function public:CheckHasPetCard(playerId)
    local cards = self:GetPlayerUsingCards()
    for _, v in ipairs(cards) do
        if string.find(v,"ability_custom_call_summon") ~= nil then
            return true
        end
    end
    return false
end
