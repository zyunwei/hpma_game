CustomEvents('xxwar_select_ability', function(e, data)
	if data == nil or data.PlayerID == nil then return end
    local isSelectSuccess, reason = AbilityRewardCtrl:OnSelectAbility(data.PlayerID, data.Index)
    if isSelectSuccess == false and reason == "full_ability" then
        local abilityReplaceList = AbilityRewardCtrl:GetReplaceAbilities(data.PlayerID)
        if abilityReplaceList then
            local player = PlayerResource:GetPlayer(data.PlayerID)
            CustomGameEventManager:Send_ServerToPlayer(player, "ability_replace", {datas = abilityReplaceList, Index = data.Index})    
        end
    end
end)

CustomEvents('xxwar_replace_ability', function (e, data)
	if data == nil or data.PlayerID == nil then return end
    AbilityRewardCtrl:ReplaceAbility(data.PlayerID, data.AbilityName, data.ReplaceIndex)
end)