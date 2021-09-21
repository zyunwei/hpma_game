-- if not IsInToolsMode() then return end

if CustomTest == nil then
	CustomTest = {}
	CustomTest.__print = _G["print"]
	setmetatable(CustomTest,CustomTest)
end

local public = CustomTest

function public:__call(name, playerId, player, args)
	if self[name] ~= nil then
		self[name](self, playerId, player, player:GetAssignedHero(), args)
	elseif name ~= "item" then
		print("Similar:")
		for k in pairs(self) do
			if string.find(k,name) then
				print("-- @"..k)
			end
		end
	end
end

function public:bag(playerId, player, hero, args)
	local bag = hero:GetBag()
	if #args == 0 then
		bag:Look(function(bagSlot,itemIndex,item)
			print("[Bag] Slot: " .. bagSlot .. "\titemIndex: " .. itemIndex)
		end)

	elseif args[1] == "create" and type(args[2]) == "string" then
		local charges = tonumber(args[3] or 1)
		if bag:CreateItem(args[2], charges) then
			print("Create Item:"..args[2].." success")
		else
			print("Create Item:"..args[2].." fail")
		end
	end
end

function public:createunit(playerId, player, hero, args)
	if #args == 0 then
		local unit = CreateUnitByName("npc_dota_lesser_eidolon", hero:GetOrigin() + RandomVector(200), true, nil, nil, DOTA_TEAM_BADGUYS)
	elseif args[1] == "health" then
		local unit = CreateUnitByName("npc_dota_lesser_eidolon", hero:GetOrigin() + RandomVector(200), true, nil, nil, DOTA_TEAM_BADGUYS)

		local health = tonumber(args[2])
		if health then
			unit:SetMaxHealth(health)
			unit:SetBaseMaxHealth(health)
			unit:SetHealth(unit:GetMaxHealth())
		end
	else
		local unitname = args[1]
		local unit = CreateUnitByName(unitname, hero:GetOrigin() + RandomVector(200), true, nil, nil, DOTA_TEAM_BADGUYS)
		unit:SetControllableByPlayer(playerId, true)

		if unit then
			for i,v in ipairs(args) do
				if v == "health" then
					local health = tonumber(args[i+1])
					if health then
						unit:SetMaxHealth(health)
						unit:SetBaseMaxHealth(health)
						unit:SetHealth(unit:GetMaxHealth())
					end
				end
			end
		end

		if unit.HeroLevelUp ~= nil then
			for i = 1, 30 do
				unit:HeroLevelUp(false)
			end
		end

		unit:AutoUpgradeAbility(true)

		-- CreateTimer(function() 
		-- 	local invisiAb = unit:FindAbilityByName("nyx_assassin_vendetta")
		-- 	if invisiAb ~= nil then
		-- 		print("cast")
		-- 		unit:CastAbilityNoTarget(invisiAb, 0)
		-- 	end
		-- end, 3)
		
	end
end

function public:attrs(playerId, player, hero, args)
	for k,v in pairs(hero:GetAllCustomAttribute()) do
		print(string.format("%15s:%d",k,v))
	end
end

function public:attrs2(playerId, player, hero, args)
	for k,v in pairs(hero:StatisticalAttributes()) do
		print(string.format("%15s:%d",k,v))
	end
end

function public:attrchildren(playerId, player, hero, args)
	if type(args[1]) == "string" then
		for k,v in pairs(hero:GetCustomAttributeChildren(args[1])) do
			print(string.format("%15s:%d",k,v))
		end
	else
		DeepPrintTable(hero.__CustomAttributesChildren)
	end
end

function public:item_attrs(playerId, player, hero, args)
	for i=0,5 do
		local item = hero:GetItemInSlot(i)
		if item then
			print("--- "..i,item:GetAbilityName())
			for k,v in pairs(item:GetAllCustomAttribute()) do
				print(string.format("%15s:%d",k,v))
			end
		end
	end
end

local MessageRandom = {
	{
		type = "bottom",
		class= "error",
	},
	{
		type = "bottom",
		class= "success",
	},
	{
		type = "bottom",
		class= "info",
	},
	{
		type = "bottom",
		class= "warning",
	},
	{
		type = "left",
		class= "warning",
	},
	{
		type = "left",
		class= "success",
	},
}

function public:msg(playerId, player, hero, args)
	local index = tonumber(args[1]) or RandomInt(1, #MessageRandom)
	local msg = MessageRandom[index]
	CustomMessage:all( msg )
end

function public:gold(playerId, player, hero, args)
	local gold = tonumber(args[1]) or RandomInt(10000, 100000)
	if gold > 1000000 then
		gold = 1000000
	end
	hero:ModifyCurrency(CURRENCY_TYPE_GOLD, gold)
end

function public:endgame(playerId, player, hero, args)
	GameManager.WinnerTeam = DOTA_TEAM_GOODGUYS
	GameManager:GameOver()
end

function public:motion(playerId, player, hero, args)
	local motion = hero:CreateMotion()
	local forward = hero:GetForwardVector()

	motion:Jump(hero:GetOrigin(), hero:GetOrigin() + forward*1000, 3000, 0.3, "modifier_custom_stun")
end

function public:dialog(playerId, player, hero, args)
	ModalDialog(hero, {
		type = "CommonForLua",
		title = "dialog_title_warning",
		text = "shushan_do_you_want_to_go_to_jifengya",
		style = "warning",
		options = {
			{
				key = "YES",
				func = function ()
					print("YES")
				end,
			},
			{
				key = "NO",
				func = function ()
					print("NO")
				end,
			},
		},
	})
end

function public:debug()
	local path = "particles/generic_gameplay/screen_death_indicator.vpcf"
	path = "particles/ring_green.vpcf"
	path = "particles/units/heroes/hero_tinker/tinker_defense_matrix.vpcf"
	path = "particles/units/heroes/hero_tinker/tinker_defense_matrix_ball.vpcf"
	path = "particles/econ/items/templar_assassin/templar_assassin_butterfly/templar_assassin_trap_butterfly_rings_flash.vpcf"
	path = "particles/test_line.vpcf"

	local playerInfo = GameRules.XW.PlayerList[0]
	local hero = playerInfo.Hero

	-- AbilityRewardCtr:RandomRewardsForPlayer(0)

	-- local index = ParticleManager:CreateParticle(path, PATTACH_WORLDORIGIN, hero)
	-- ParticleManager:SetParticleControl(index, 0, hero:GetAbsOrigin())
	print("creat particle:" .. path)
	-- RefreshCreepSystem:LoadAllCreeps()
	-- RefreshCreepSystem:RefreshCreeps(12)
	-- RefreshCreepSystem:UpgradeCreeps(12)
	-- modifier_creep

	-- hero:AddNewModifier(nil, nil, "modifier_creep", {Duration=20, health_bouns= 1000, armor_bouns=20, magical_resistance_bouns=30, gold_gain_bouns = 10, xp_gain_bouns = 10})	
	-- hero:RemoveAbility("ability_custom_burn_around")
	-- AbilityRewardCtr:LoadCandidateAbilities()
end

function public:showability(playerId, player, hero, args)
	AbilityRewardCtrl:ShowAbilityRewardForPlayer(playerId, args[1])
end

function public:region()
	BlockadeSystem:RandomBlockadeRegion()
	local playerInfo = GameRules.XW.PlayerList[0]
	local hero = playerInfo.Hero
	CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "update_minimap_region_state", {})
end	

function public:modifiers(playerId, player, hero, args)
	for i, v in pairs(hero:FindAllModifiers()) do
		print(v:GetName())
	end
end

function public:abilities(playerId, player, hero, args)
    for i = 0, 31 do 
        local chkAbility = hero:GetAbilityByIndex(i)
        if chkAbility ~= nil then
            print(i, chkAbility:GetName())
        else
        	print(i, chkAbility)
        end
    end
end

function public:test(playerId, player, hero, args)
	-- hero:AppendMainAbility("ogre_magi_bloodlust")
    -- hero:AppendMinorAbility("ability_custom_life_line")

	hero:SetCustomAttribute("max_crystal", "max_crystal", 10)
	hero:SetCustomAttribute("crystal_regen", "crystal_regen", 1.9)
end

function public:dgtest(playerId, player, hero, args)
	hero:AppendMainAbility("slardar_bash")
end

function public:testtest(playerId, player, hero, args)
	-- local pet = CallHeroPool:GetPlayerPet(playerId, "npc_dota_hero_venomancer")
	-- -- table.print(pet:FindAllModifiers())
	-- for key, value in pairs(pet:FindAllModifiers()) do
	-- 	print(value:GetName())
	-- end
	hero:AddNewModifier( hero, self, "modifier_stunned", { duration = 25 } )
	-- for i = 1, 10 do
	-- 	CustomMessage:all({
	-- 		type="message-box", 
	-- 		role="xxwar_system_notification",
	-- 		list={{text={"xxwar_boss_in", "1", "xxwar_boss_release"}, args={}}},
	-- 	})
	-- end
	-- print(GetRandomItemQuality({1}, false))
end

function public:printSecAb(playerId, player, hero, args)
	local all_ability_table = LoadKeyValues("scripts/kv/main_abilities.kv")
	local result_table = {}
	for i, v in pairs(all_ability_table) do
		local ab = hero:AddAbility(v)
		if ab ~= nil then
			local ab2 = ab:GetAssociatedSecondaryAbilities()
			if ab ~= nil and ab ~= "" then
				result_table[v] = ab2
				hero:RemoveAbility(v)
			end
		end
	end
end

function public:uploaditem(playerId, player, hero, args)
	local playerInfo = GameRules.XW:GetPlayerInfo(playerId)
	if playerInfo and NotNull(playerInfo.Hero) then
		local itemInfo = {
			name = "Changeable",
			value = 1,
		}
		playerInfo:UploadImgItem(itemInfo)
	end
end

function public:downloaditem(playerId, player, hero, args)
	local playerInfo = GameRules.XW:GetPlayerInfo(playerId)
	if playerInfo and NotNull(playerInfo.Hero) then
		playerInfo:DownloadSavedItem(playerInfo.Hero:GetName())
	end
end

function public:testpet(playerId, player, hero, args)
	for i = 1, 30 do
		hero:HeroLevelUp(false)
		hero:AddItemByName("item_consumable_0001")
	end

	hero:SetCustomAttribute("max_crystal", "max_crystal", 10)
	hero:SetCustomAttribute("crystal_regen", "crystal_regen", 1.9)

	hero:EndAbilitiesCooldown()
	hero:EndItemsCooldown()
end

function public:testab(playerId, player, hero, args)
	hero:AppendMainAbility("nyx_assassin_vendetta")
end

function public:testmusic1(playerId, player, hero, args)
	EmitSoundOnLocationForAllies(hero:GetAbsOrigin(), "XXWAR.XIAODAOHUI", hero)
end

function public:testmusic2(playerId, player, hero, args)
	EmitGlobalSound("XXWAR.RIM_SOUND_2")
end

function public:testmusic3(playerId, player, hero, args)
	EmitSoundOn("XXWAR.QING_TIAN", hero)
end

function public:gettask(playerId, player, hero, args)
	local playerInfo = GameRules.XW:GetPlayerInfo(playerId)
	if playerInfo and NotNull(playerInfo.Hero) then
		playerInfo:GetTaskData()
	end
end

function public:savetask(playerId, player, hero, args)
	local playerInfo = GameRules.XW:GetPlayerInfo(playerId)
	if playerInfo and NotNull(playerInfo.Hero) then
		playerInfo:SaveTaskData()
	end
end

function public:setdynamicvision()
	GameRules.XW.DynamicVision = not GameRules.XW.DynamicVision
	    local status = "ON"
    if GameRules.XW.DynamicVision == false then
        status = "OFF"
    end
    ShowGolbalMessage("DynamicVision: " .. status)
end

function public:pullbot(playerId, player, hero, args)
	for _, info in pairs(GameRules.XW.PlayerList) do
		if info.IsBot and IsAlive(info.Hero) then
			FindClearSpaceForUnit(info.Hero, hero:GetAbsOrigin() + RandomVector(300), true)
		end
	end
end

function public:autouse(playerId, player, hero, args)
    GameRules.XW.EnableAutoUse = not GameRules.XW.EnableAutoUse
    local status = "ON"
    if GameRules.XW.EnableAutoUse == false then
        status = "OFF"
    end
    ShowGolbalMessage("AUTO USE: " .. status)
end

function public:creep(playerId, player, hero, args)
    GameRules.XW.EnableCreepRefresh = not GameRules.XW.EnableCreepRefresh
    local status = "ON"
    if GameRules.XW.EnableCreepRefresh == false then
        status = "OFF"
    end
    ShowGolbalMessage("EnableCreepRefresh: " .. status)
end

function public:minor(playerId, player, hero, args)
    GameRules.XW.EnableMinor = not GameRules.XW.EnableMinor
    local status = "ON"
    if GameRules.XW.EnableMinor == false then
        status = "OFF"
    end
    ShowGolbalMessage("EnableMinor: " .. status)
end
