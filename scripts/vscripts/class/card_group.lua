
if CardGroup == nil then
    CardGroup = class({})
    CardGroup.STATE_IN_HAND = 0
    CardGroup.STATE_IN_PEDING = 1
    CardGroup.STATE_IN_FOLD = 2
end

local public = CardGroup

function public:constructor(ability_infos, card_group_name)
    self.__name = card_group_name
    self.__maxHandsCard = 4
    self.__cards = {}
    self.__handCards = {}
    self.__candidateCardIndexs = Queue()
    self.__foldCardIndexs = {}
    for _, v in pairs(ability_infos) do
        table.insert(self.__cards, {
            AbilityName = v.AbilityName,
            CrystalCost = v.CrystalCost,
        })
    end
end

function public:Copy(card_group)
    self:constructor(card_group.__cards, card_group:GetName())
end

function public:GetName()
    return self.__name
end

function public:AddCardToGroup(cardName)
    local cardInfo = CardGroupSystem:GetCardInfo(cardName)
    if cardInfo ~= nil then
        table.insert(self.__cards, cardInfo)
        self.__candidateCardIndexs:push_back(#self.__cards)
        return true
    end

    return false
end

function public:RemoveCardFromGroupByName(abilityName, removeHandCards)
    local deleteIndexList = {}

    local removeCount = 0
    for index, v in pairs(self.__cards) do
        if v.AbilityName == abilityName then
            local isHandCards = table.contains(self.__handCards, index)
            if removeHandCards and isHandCards then
                self:FoldCard(abilityName)
                table.insert(deleteIndexList, index)
            elseif removeHandCards == false and isHandCards == false then
                table.insert(deleteIndexList, index)
            end
        end
    end

    for i = #deleteIndexList, 1, -1 do
        removeCount = removeCount + 1
        table.remove(self.__cards, deleteIndexList[i])
        self:OnRemoveCards(deleteIndexList[i])
    end

    return removeCount
end

function public:InitDrawCards()
    self.__candidateCardIndexs = Queue()
    self.__foldCardIndexs = {}
    self.__handCards = {}
    for index, v in pairs(self.__cards) do
        self.__candidateCardIndexs:push_back(index)
    end
end

function public:OnRemoveCards(del_index)
    local temp = {}
    for _, v in pairs(self.__handCards) do
        if v ~= del_index then
            local newIndex = v > del_index and v - 1 or v
            table.insert(temp, newIndex)
        end
    end
    self.__handCards = temp

    temp = {}
    for _, v in pairs(self.__candidateCardIndexs:to_list()) do
        if v ~= del_index then
            local newIndex = v > del_index and v - 1 or v
            table.insert(temp, newIndex)
        end
    end
    self.__candidateCardIndexs:clear()
    for _, v in pairs(temp) do
        self.__candidateCardIndexs:push_back(v)
    end

    temp = {}
    for _, v in pairs(self.__foldCardIndexs) do
        if v ~= del_index then
            local newIndex = v > del_index and v - 1 or v
            table.insert(temp, newIndex)
        end
    end
    self.__foldCardIndexs = temp
end

function public:DrawCard(isFinal)
    if isFinal == nil then
        isFinal = false
    end
    if self.__candidateCardIndexs:empty() then
        local list = table.shuffle(self.__foldCardIndexs)
        self.__candidateCardIndexs:clear()
        for _, v in pairs(list) do
            self.__candidateCardIndexs:push_back(v)
        end
        self.__foldCardIndexs = {}
    end

    local sameCards = {}
    local drawCardIndex = -1
    while not self.__candidateCardIndexs:empty() do
        local cardIndex = self.__candidateCardIndexs:pop_front()
        local isHaveSameCard = false
        -- 相同的技能牌不能同时存在
        for _, v in ipairs(self.__handCards) do
            if self.__cards[v].AbilityName == self.__cards[cardIndex].AbilityName then
                table.insert(sameCards, cardIndex)
                isHaveSameCard = true
                break
            end
        end
        if isHaveSameCard == false then
            drawCardIndex = cardIndex
            break
        end
    end
    if drawCardIndex ~= -1 then
        for i = #sameCards, 1, -1 do
            self.__candidateCardIndexs:push_front(sameCards[i])
        end
        table.insert(self.__handCards, drawCardIndex)
        return self.__cards[drawCardIndex]
    elseif isFinal == false then
        for i = #sameCards, 1, -1 do
            table.insert(self.__foldCardIndexs, sameCards[i])
        end
        return self:DrawCard(true)
    end
    return nil
end

function public:FoldCard(abilityName)
    local deleteIndex = -1
    for index, v in ipairs(self.__handCards) do
        if self.__cards[v].AbilityName == abilityName then
            deleteIndex = index
            break
        end
    end
    if deleteIndex ~= -1 then
        table.insert(self.__foldCardIndexs, self.__handCards[deleteIndex])
        table.remove(self.__handCards, deleteIndex)
    end
end

function public:GetCardStateInfos()
    local cardInfos = {}
    for _, v in ipairs(self.__handCards) do
        local card = self.__cards[v]
        table.insert(cardInfos, {
            AbilityName = card.AbilityName,
            CrystalCost = card.CrystalCost,
            State = self.STATE_IN_HAND,
        })
    end
    local pendingList = self.__candidateCardIndexs:to_list()
    for _, v in ipairs(pendingList) do
        local card = self.__cards[v]
        table.insert(cardInfos, {
            AbilityName = card.AbilityName,
            CrystalCost = card.CrystalCost,
            State = self.STATE_IN_PEDING,
        })
    end
    for _, v in ipairs(self.__foldCardIndexs) do
        local card = self.__cards[v]
        table.insert(cardInfos, {
            AbilityName = card.AbilityName,
            CrystalCost = card.CrystalCost,
            State = self.STATE_IN_FOLD,
        })
    end
    return cardInfos
end

function public:GetCards()
    return self.__cards
end