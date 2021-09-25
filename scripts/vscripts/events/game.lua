---------- 游戏状态 - 设置队伍阶段 ----------
function GameEvents:GameStateCustomGameSetup()
	CreateTimer(function() GameEvents:KeepUpdateGameSetting() end, 1)
	ControllersInit()
end

function GameEvents:KeepUpdateGameSetting()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
        local hostPlayer = nil
        for playerId, playerInfo in pairs(GameRules.XW.PlayerList) do
            local checkPlayer = PlayerResource:GetPlayer(playerId)
            if(checkPlayer ~= nil and checkPlayer:IsNull() == false and playerInfo.IsOnline == true) then
            	if(GameRules.XW.MapName == "1x2") then
            		if(table.containsKey(GameRules.XW.TeamColor, checkPlayer:GetTeam()) == false) then
	                    local teamId = GameEvents:FindEmptyTeamForPlayer(playerId)
	                    PlayerResource:SetCustomTeamAssignment(playerId, teamId)
	                end
            	end
                
                playerInfo.TeamId = checkPlayer:GetTeam()
                
                if(GameRules:PlayerHasCustomGameHostPrivileges(checkPlayer)) then
                    hostPlayer = checkPlayer
                end
            end
        end
        
        local botCount = 0
        if(hostPlayer ~= nil) then
            for _, playerInfo in pairs(GameRules.XW.PlayerList) do
                if(playerInfo.IsBot == true) then
                    botCount = botCount + 1
                end
            end
            
            CustomGameEventManager:Send_ServerToPlayer(hostPlayer, "UPDATE_BOT_COUNT", {count = botCount})
        end
        
        if PlayerResource:GetPlayerCount() - botCount > 1 and GameRules:IsCheatMode() == true then
            CreateTimer(function() ShowGolbalMessage('SORRY DO NOT SUPPORTED CHEAT MODE FOR MUTIPLAYERS.') end, 3)
            GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
            return
        end
        
        CreateTimer(function() GameEvents:KeepUpdateGameSetting() end, 0.5)
    end
end

function GameEvents:FindEmptyTeamForPlayer(playerId)
    local assignTeam = PlayerResource:GetCustomTeamAssignment(playerId)
    if(table.containsKey(GameRules.XW.TeamColor, assignTeam)) then
        return assignTeam
    end
    
    local teamAssignedTable = {}
    for playerId, info in pairs(GameRules.XW.PlayerList) do
        local player = PlayerResource:GetPlayer(playerId)
        
        if(player ~= nil and player:IsNull() == false) then
            local teamId = player:GetTeam()
            if(table.containsKey(GameRules.XW.TeamColor, teamId)) then
                table.insert(teamAssignedTable, teamId)
            end
        end
    end
    
    for teamId = 6, 13 do
        if(table.contains(teamAssignedTable, teamId) == false) then
            return teamId
        end
    end
    
    return DOTA_TEAM_NOTEAM
end

---------- 游戏状态 - 选择英雄阶段 ----------
function GameEvents:GameStateHeroSelection()
	local postData = {}
	for playerId, info in pairs(GameRules.XW.PlayerList) do
        local teamId = PlayerResource:GetTeam(playerId)
        if GameRules.XW.TeamColor[teamId] then
        	table.insert(postData, {PlayerId = playerId, SteamId = info.SteamId,
            	SteamAccountId = info.SteamAccountId, SteamName = info.PlayerName, IsBot = info.IsBot})
        end
    end

    HttpPost("api/Member/GetPlayersInfo", postData, function(result)
        if(result.isSuccess and result.tag ~= nil) then
            for _, v in pairs(result.tag) do
                local playerInfo = GameRules.XW.PlayerList[v.PlayerId]
                if(playerInfo ~= nil) then
                    playerInfo.Grade = v.Grade
                    playerInfo.IsVip = v.IsVip
                    if(v.Status == 0) then
                        playerInfo.Life = 0
                    end
                end
				CustomNetTables:SetTableValue("PlayerInfo", tostring(v.PlayerId), {
					IsVip = playerInfo.IsVip,
				})
            end
        else
            ShowGlobalMessage(result.message)
        end
    end)
end

----------------- 决策阶段 -----------------
function GameEvents:GameStateStrategyTime()
	for playerId, playerInfo in pairs(GameRules.XW.PlayerList) do
        if playerInfo.IsEmpty == false and PlayerResource:HasSelectedHero(playerId) == false then
        	local player = PlayerResource:GetPlayer(playerId)
        	if player ~= nil then
				if playerInfo.PrePickHero == nil then
        			player:MakeRandomHeroSelection()
				else
					player:SetSelectedHero(playerInfo.PrePickHero)
				end
        	end
        end
    end
end

--------------- 队伍展示阶段 ---------------
function GameEvents:GameStateTeamShowcase()
end

------------- 等待地图加载阶段 -------------
function GameEvents:GameStateWaitForMapToLoad()
end

------------ 游戏状态 - 预备阶段 ------------
function GameEvents:GameStatePreGame()
	for playerId, info in pairs(GameRules.XW.PlayerList) do
        local teamId = PlayerResource:GetTeam(playerId)
        local color = GameRules.XW.TeamColor[teamId]
        if color then
        	SetTeamCustomHealthbarColor(teamId, color[1], color[2], color[3])
        	PlayerResource:SetCustomPlayerColor(playerId, color[1], color[2], color[3])
        end
    end
end

------------ 游戏状态 - 游戏开始 ------------
function GameEvents:GameStateInProgress()
	GameManager.StartTimeStamp = GameRules:GetGameTime()
	GameManager:CheckGameStart()
   	SpawnCreepsCtrl:StartSpawnCreeps()
	for _, playerInfo in pairs(GameRules.XW.PlayerList) do
        if playerInfo.Hero ~= nil and playerInfo.Hero:IsNull() == false then
        	if playerInfo.Hero:HasModifier("modifier_out_of_game") then
        		playerInfo.Hero:RemoveModifierByName("modifier_out_of_game")
        	end

            -- playerInfo.Hero:AddItemByName("item_consumable_ability")
        end
    end
end

------------ 游戏状态 - 游戏结束 ------------
function GameEvents:GameStatePostGame()
end

------------------------------------------------------------------------------------------------------------

---当玩家选择英雄
StoreHasCreateVIP = {}
function GameEvents:OnCustomSelectHero(hero)
	-- 初始化
	BagCtrl(hero, BAG_NAME_COMMON)
	CurrenciesCtrl(hero)
end

function GameEvents:OnPickHero(playerIndex, heroIndex)
	if not IsServer() then return end
	local player = EntIndexToHScript(playerIndex)
	local hero = EntIndexToHScript(heroIndex)
	if player == nil or hero == nil then
		return
	end

	local playerId = hero:GetPlayerID()
    local playerInfo = GameRules.XW.PlayerList[playerId]
    if playerInfo ~= nil and playerInfo.Hero == nil then
		hero:AddNewModifier(hero, nil, "modifier_out_of_game", {})
        playerInfo:PickHero(hero)
		CustomNetTables:SetTableValue("PlayerHero", tostring(playerId), {HeroEntityIndex = heroIndex})

		hero:SetCustomAttribute("max_crystal", "max_crystal", 1)
	    hero:SetCustomAttribute("crystal_regen", "crystal_regen", 0.2)
	    hero:SetCustomAttribute("crystal", "crystal", 1)

	    hero:SetCustomAttribute("crit_chance", "crit_chance_base", 5) -- 基础暴击概率
	    hero:SetCustomAttribute("crit_mult", "crit_mult_base", 150) -- 基础暴击伤害
	    
		GameManager:CheckGameStart()
    end
end

------------------------------------------------------------------------------------------------------------

---第一次被创建
---function OnHeroFirstSpawn
-- @param {handle} hero
-- @param {int}    entindex
function GameEvents:OnUnitFirstSpawn( unit, entindex )
	if unit:IsHero() then
		Timer("GameEvents:OnUnitFirstSpawn", unit, 1, function ()
			if not unit:IsNull() and unit:IsIllusion() then
				return nil
			end
			if not unit:IsNull() and unit.IsRealHero ~= nil and unit:IsRealHero() then
				local playerInfo = GameRules.XW:GetPlayerInfo(unit:GetPlayerID())
				if playerInfo ~= nil and playerInfo.Hero == unit then
					print("Init " .. unit:GetUnitName())
					self:OnCustomSelectHero(unit)
				end

				return nil
			end
			return 1
		end)
	end
end

------------------------------------------------------------------------------------------------------------

---单位创建， 英雄重生
---function OnNpcSpawned
-- @param {handle} unit
-- @param {int}    entindex
function GameEvents:OnNPCSpawned( unit, entindex )
	if unit:IsHero() then
		AttributesCtrl(unit)
	else
		local unitName = unit:GetUnitName()
		if string.find(unitName, "npc_dota_lycan_wolf") == 1 then
			unit:SetContextThink("OnHeroThink", function() return HPMASummonAI:OnHeroThink(unit) end, 1)
			
			-- local enemy = unit:GetNearestEnemyForAI(1500, true, 100)
			-- if NotNull(enemy) then
			-- 	unit:MoveToPositionAggressive(enemy:GetAbsOrigin())
			-- end
		end
	end
end

------------------------------------------------------------------------------------------------------------

---玩家英雄升级
---function OnPlayerLevelUp
-- @param player handle 玩家
-- @param hero handle 英雄
-- @param level number 等级
function GameEvents:OnPlayerLevelUp( player, hero, level )
	if IsNull(hero) then return end
	local playerInfo = GameRules.XW:GetPlayerInfo(hero:GetPlayerID())
	if playerInfo == nil or IsNull(playerInfo.Hero) then return end

	local currentRealm = playerInfo.Hero:GetCustomAttribute("max_crystal")
	if currentRealm >= 10 then
		return
	end

	local newRealm = math.floor(level / 3)
	if newRealm < 1 then newRealm = 1 end
	if newRealm > 10 then newRealm = 10 end
	if newRealm ~= currentRealm and newRealm > 1 then
		playerInfo.Hero:SetCustomAttribute("max_crystal", "max_crystal", newRealm)
		playerInfo.Hero:SetCustomAttribute("crystal", "crystal", newRealm)
		playerInfo.Hero:ModifyCustomAttribute("crystal_regen", "crystal_regen", 0.1)
		playerInfo.Hero:ModifyCustomAttribute("status_resistance", "realm", 2)
		CreateParticle(ParticleRes.LEVEL_UP, PATTACH_ABSORIGIN_FOLLOW, playerInfo.Hero, 5)
	    EmitSoundOn(SoundRes.LEVEL_UP, playerInfo.Hero)
	end
end

------------------------------------------------------------------------------------------------------------

---单位被击杀
---function OnEntityKilled
-- @param attacker handle 伤害来源
-- @param victim handle 受害者
-- @param ability handle 技能
-- @param damagebits number 未知

function GameEvents:OnEntityKilled( attacker, victim, ability, damagebits )
    if victim ~= nil and victim:IsNull() == false and victim:IsReincarnating() == false then
		-- 每周任务数据
		if IsAlive(attacker) == true and attacker.GetPlayerOwnerID ~= nil then
			local killerPlayerId = attacker:GetPlayerOwnerID()
			local killerPlayerInfo = GameRules.XW:GetPlayerInfo(killerPlayerId)
			if killerPlayerId ~= nil and killerPlayerInfo ~= nil then
				if victim.IsBoss == true then
					killerPlayerInfo.TaskTable.boss_kill_count = killerPlayerInfo.TaskTable.boss_kill_count + 1
				elseif victim.IsRealHero ~= nil and victim:IsRealHero() and not victim.IsPet then
					killerPlayerInfo.TaskTable.player_kill_count = killerPlayerInfo.TaskTable.player_kill_count + 1
				elseif victim:GetTeam() == DOTA_TEAM_NEUTRALS then
					killerPlayerInfo.TaskTable.creep_kill_count = killerPlayerInfo.TaskTable.creep_kill_count + 1
				end
			end
		end

    	if victim.IsBoss == true and victim.IsReleaseBoss == true then
    		GameRules.XW.AutoReleaseBossCount = GameRules.XW.AutoReleaseBossCount - 1
    	end

    	if victim.IsRealHero ~= nil and victim:IsRealHero() and victim:IsIllusion() == false then
    		local playerId = victim:GetPlayerID()
    		local playerInfo = GameRules.XW:GetPlayerInfo(playerId)
			local lastAliveTeamCount = GameManager:GetAliveTeamCount()
			if playerInfo ~= nil and victim.IsPet == true then
				PlayerInfo:PetSay(playerId, victim, "#xxwar_pet_say_killed")
			end

    		if playerInfo ~= nil and playerInfo.IsAlive == true and playerInfo.Hero == victim then
				playerInfo.IsAlive = false
				--玩家死亡发放奖励
				local itemName = GetRandomItemQuality({3}, false)
				if itemName ~= nil then
					victim:AddOwnerItemByName(itemName)
				end

				victim:ModifyCustomAttribute("str", "respawn", 10)
				victim:ModifyCustomAttribute("agi", "respawn", 10)
				victim:ModifyCustomAttribute("int", "respawn", 10)

				victim:ShowCustomMessage({
					type="message-box", 
					role="xxwar_system_notification",
					styles={color="#36B8FF"},
					list={{text={"xxwar_death_bonus"}, args={}}},
				})

				local aliveTeamCount = GameManager:GetAliveTeamCount()
				if lastAliveTeamCount ~= aliveTeamCount then
					if GameManager:CheckTeamIsAlive(playerInfo.TeamId) == false then
						GameManager:SetTeamDeathTime(playerInfo.TeamId, GameManager:GetGameTime())
					end
				end
				if victim:GetPlayerOwner() ~= nil then
					local tombstone = CreateUnitByName("npc_tombstone", victim:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_NEUTRALS)
				    tombstone:SetHullRadius(0)
				    tombstone:SetAbility("ability_npc_tombstone")
				    tombstone.PlayerId = playerId
				    if GetMapName() ~= "1x8" then
				    	playerInfo:HeroSay(playerId, "xxwar_pet_say_rescue")
				    end
				    playerInfo.TombStone = tombstone

				    local killerIsPlayer = false
				    if IsAlive(attacker) == true and attacker.GetPlayerOwnerID ~= nil then
				    	local killerPlayerId = attacker:GetPlayerOwnerID()
				    	local killerPlayerInfo = GameRules.XW:GetPlayerInfo(killerPlayerId)
				    	if killerPlayerId ~= nil and killerPlayerInfo ~= nil then
				    		playerInfo.LastKillerPlayerId = killerPlayerId
				    		killerIsPlayer = true

				    		if playerInfo.BountyBullion > 0 then
					    		local headBounty = math.ceil(playerInfo.BountyBullion / 2)

					    		-- 杀手头上挂元宝
					    		killerPlayerInfo.BountyBullion = killerPlayerInfo.BountyBullion + headBounty

					    		-- 杀手账户加元宝
					    		local bountyAmount = playerInfo.BountyBullion - headBounty

					    		-- 杀手是会员，账户元宝加倍
					    		if killerPlayerInfo.IsVip then
					    			bountyAmount = bountyAmount * 2
					    		end
					    		if bountyAmount > 0 and killerPlayerInfo.IsBot == false and NotNull(killerPlayerInfo.Hero) then
					    			killerPlayerInfo.SavedBullion = killerPlayerInfo.SavedBullion + bountyAmount
						    		local postData = { SteamAccountId = killerPlayerInfo.SteamAccountId, GameId = GameRules.XW.GameId, amount = bountyAmount, remark = 'KILL_BOUNTY' }
								    HttpPost("api/Member/DepositBullion", postData, function(result)
								        if(result.isSuccess) then
								        	killerPlayerInfo.Hero:ShowCustomMessage({type="bottom", msg={bountyAmount, "xxwar_increase_bullion"}, class="success"})
								        else
								        	ShowGlobalMessage(result.message)
								        end
								    end)
								end

					    		playerInfo.BountyBullion = 0
					    	end
				    	end
				    end

				    if playerInfo.BountyBullion > 0 and killerIsPlayer == false then
				    	-- 赏金放入奖池
				    	GameRules.XW.Jackpot = GameRules.XW.Jackpot + playerInfo.BountyBullion

        				CustomMessage:all({
	                        type="bottom",
	                        class="success",
	                        msg={"xxwar_jackpot_increased", playerInfo.BountyBullion, "xxwar_store_bullion"}
	                    })

				    	playerInfo.BountyBullion = 0
				    end

				    playerInfo.Hero:DelayRespawn(5 + playerInfo.RespawnCount * 2, playerInfo.Hero:GetAbsOrigin())

			    	playerInfo.ShowDeathFrame = true
				    playerInfo.XXCoin = ".."
				    playerInfo.Bullion = ".."
				    playerInfo.RespawnCoin = ".."

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
				end
    		end
    	end
    end
	if victim.OnEntityKilled then
		victim:OnEntityKilled(attacker)
	end
	DropperCtrl(attacker, victim)
	SpawnCreepsCtrl:OnEntityKilled(attacker, victim)
	RefreshCreepSystem:OnEntityKilled(attacker, victim)
	AbilityRewardCtrl:OnEntityKilled(attacker, victim)
end

------------------------------------------------------------------------------------------------------------

---玩家重连
---function OnPlayerReconnected
-- @param playerID number 玩家ID
-- @param player handle 玩家

function GameEvents:OnPlayerReconnected( playerID, player )
end

function GameEvents:OnPlayerConnectFull(playerID, player)
	local playerInfo = GameRules.XW.PlayerList[playerID]
	if playerInfo ~= nil then
		playerInfo:SetInfoOnConnectFull(playerID)
	end
end

------------------------------------------------------------------------------------------------------------

---物品被捡起
---function OnItemPickedUp
-- @param player handle 玩家
-- @param hero handle 英雄
-- @param item handle 物品
-- @param itemName string 物品名称

function GameEvents:OnItemPickedUp( player, hero, item, itemName )
	
end

------------------------------------------------------------------------------------------------------------

---玩家聊天
---function OnPlayerSay
-- @param isTeamOnly bool 是否只有同队可见
-- @param playerID number 玩家ID
-- @param player handle 玩家
-- @param text string 文本
function GameEvents:OnPlayerChat( isTeamOnly, playerID, player, text )
	if text == "-kill" then
		local hero = player:GetAssignedHero()
		hero:ForceKill(true)
	end
end

------------------------------------------------------------------------------------------------------------

function GameEvents:OnPlayerTeamChange(team, oldteam, isDisconnect)
end