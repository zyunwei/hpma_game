if AbilityRewardCtrl == nil then
	AbilityRewardCtrl = RegisterController('ability_reward_ctrl')
    AbilityRewardCtrl.MainAbilities = {}
    AbilityRewardCtrl.MinorAbilities = {}
    AbilityRewardCtrl.RandomCount = 4
    AbilityRewardCtrl.MainAbilitySize = 8
end

local public = AbilityRewardCtrl

function public:init()
    self:LoadCandidateAbilities()
    self.MainAbilities = NormalizeProbFromTable(self.MainAbilities, "prob")
    self.PlayerAbilityOptions = {}
    CustomNetTables:SetTableValue("CustomAbilities", "MainAbilities", self.MainAbilities)
    CustomNetTables:SetTableValue("CustomAbilities", "MinorAbilities", self.MinorAbilities)
end

function public:LoadCandidateAbilities()
    local ability_table = LoadKeyValues("scripts/npc/abilities/custom_minor_abilities.kv")
    for abilityName, config in pairs(ability_table) do
        if not config.IsHidden then
            table.insert(self.MinorAbilities, {
                AbilityName = abilityName,
                prob = 1
            })
        end
    end

    for _, v in ipairs(MainAbilitiesPool) do
        table.insert(self.MainAbilities, {
            AbilityName = v,
            prob = 1
        })
    end
end

function public:RandomMainAbilityForPlayer(playerId)
    self:RandomRewardsForPlayer(playerId, self.MainAbilities)
end

function public:RandomRewardsForPlayer(playerId, ability_table)
    if playerId == nil then return end
    local player = PlayerResource:GetPlayer(playerId)
    if player == nil then
        return
    end

    local results = {}
    local count = 0
    local playerInfo = GameRules.XW:GetPlayerInfo(playerId)
    local hero = playerInfo.Hero
    if IsNull(hero) then
        return
    end
    
    while count < self.RandomCount do
        local index = RandomFromProbTable(ability_table, "prob")
        local abilityName = ability_table[index].AbilityName
        if table.find(results, "AbilityName", abilityName) == nil and hero:FindAbilityByName(abilityName) == nil then
            table.insert(results, {
                AbilityName = ability_table[index].AbilityName,
                Type = "Ability",
            })
            count = count + 1
        end
    end
    self.PlayerAbilityOptions[playerId] = results

    CustomGameEventManager:Send_ServerToPlayer(player, "ability_select", {datas = results})
end

function public:ShowAbilityRewardForPlayer(playerId, index)
    if playerId == nil then return end

    index = tonumber(index)
    local player = PlayerResource:GetPlayer(playerId)
    if player == nil then
        return
    end

    local results = {}
    local abilities = {}
    for _, v in pairs(self.MainAbilities) do
        table.insert(abilities, v)
    end
    local page = math.min(math.floor(#abilities / self.RandomCount), index)

    for i = 1, self.RandomCount do
        local p = math.min(page*self.RandomCount + i, #abilities)
        table.insert(results, {
            AbilityName = abilities[p].AbilityName,
            Type = "Ability",
        })
    end

    self.PlayerAbilityOptions[playerId] = results
    CustomGameEventManager:Send_ServerToPlayer(player, "ability_select", {datas = results})
end

function public:OnEntityKilled(attacker, victim)
    if IsNull(attacker) or IsNull(victim) then
        return
    end
    
    local unitName = victim:GetUnitName()
    local victimPos = victim:GetAbsOrigin()
    local isDropMainAbility = false
    if BOSS_ITEMS and BOSS_ITEMS[unitName] then

    elseif Drop_Ability and Drop_Ability[unitName] then
        local randomValue = math.random()
        isDropMainAbility = randomValue < Drop_Ability[unitName]
    end
    if isDropMainAbility == false then
        return
    end
    local target = nil
    if attacker.IsHero == nil or attacker:IsHero() == false then
        if attacker.GetOwner then
            target = attacker:GetOwner()
        end
    else
        target = attacker
    end
    if target == nil or target.GetPlayerID == nil then
        return
    end

    local playerId = target:GetPlayerID()
    if isDropMainAbility then
        -- 掉落宝宝物品
        if PlayerInfo:AddRandomItemForPet(playerId, true) then
            DropperCtrl:DropItem("item_consumable_0001", victimPos, nil)
        end

        -- 掉落心法书
        if RollPercentage(25) then
            if PlayerInfo:GetXinFaToBeUpgrade(playerId) ~= nil then
                DropperCtrl:DropItem("item_consumable_0003", victimPos, nil)
                return
            end
        end

        -- if RollPercentage(35) then
        --     DropperCtrl:DropItem("item_consumable_ability", victimPos)
        -- end
    end
end

function public:OnSelectAbility(playerId, index)
    if playerId == nil then return end

    local player = PlayerResource:GetPlayer(playerId)
	if player == nil then return end
    local abilityOption = self.PlayerAbilityOptions[playerId]
    if abilityOption == nil or abilityOption[index] == nil then
        return false, "wrong_index"
    end
    local abilityName = abilityOption[index].AbilityName
	local hero = player:GetAssignedHero()
    local targetLevel = 1
    if hero:HasAbility(abilityName) then
        local ability = hero:FindAbilityByName(abilityName)
        targetLevel = math.min(ability:GetLevel() + 1, ability:GetMaxLevel() )
    end
    
    local isSuccess = hero:AppendMainAbility(abilityName, true, targetLevel, self.MainAbilitySize)

    if isSuccess then
        self.PlayerAbilityOptions[playerId] = nil
    end
    return isSuccess, "full_ability"
end

function public:GetReplaceAbilities(playerId)
    if playerId == nil then return end
    local player = PlayerResource:GetPlayer(playerId)
	if player == nil then return end
    local hero = player:GetAssignedHero()
    if IsAlive(hero) == false then return end
    local results = {}
    local startIndex = 0
    local endIndex = self.MainAbilitySize - 1

    local addonAbilities = hero:GetAddonMainAbilities()
    for i = startIndex, endIndex do 
        local ability = hero:GetAbilityByIndex(i)
        if IsNull(ability) == false and table.contains(addonAbilities, ability:GetName()) == false and string.find(ability:GetName(), "xxwar_empty_ability_") == nil then
            table.insert(results, {
                AbilityName = ability:GetName(),
                Type = "Ability"
            })
        end
    end
    return results
end

function public:ReplaceAbility(playerId, targetAbilityName, newAbilityIndex)
    if playerId == nil then return end
    
    local startIndex = 0
    local endIndex = self.MainAbilitySize - 1

    local player = PlayerResource:GetPlayer(playerId)
	if player == nil then return end

    local abilityOption = self.PlayerAbilityOptions[playerId]
    if abilityOption == nil or abilityOption[newAbilityIndex] == nil then
        return
    end

    local abilityName = abilityOption[newAbilityIndex].AbilityName

    local hero = player:GetAssignedHero()
    if IsAlive(hero) == false then return end

    hero:RemoveAbilityByName(targetAbilityName)
    hero:AppendMainAbility(abilityName, true, 1, self.MainAbilitySize)
end
