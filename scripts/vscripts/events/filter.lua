------------------------------------------------------------------------------------------------------------
-- 伤害过滤器
------------------------------------------------------------------------------------------------------------
function Filter:DamageFilter( keys )
	local damage = keys.damage
	local damageType = keys.damagetype_const
	local attacker = EntIndexToHScript(keys.entindex_attacker_const or -1)
	local victim = EntIndexToHScript(keys.entindex_victim_const or -1)

	if IsNull(attacker) or IsNull(victim) then
		return true
	end
	
	-- 始终显示敌人血条
	if attacker.GetPlayerOwner ~= nil then
		local player = attacker:GetPlayerOwner()
		if IsNull(player) == false and attacker.GetPlayerID ~= nil then
			local playerInfo = GameRules.XW:GetPlayerInfo(attacker:GetPlayerID())
			if playerInfo ~= nil and playerInfo.IsAlive then
				if playerInfo.Hero == attacker then
					if attacker.LastShowEnemyUnitEntIndex ~= keys.entindex_victim_const then
						CustomGameEventManager:Send_ServerToPlayer(player, "update_enemy_info_target", { entindex = keys.entindex_victim_const }) 
					end

					attacker.LastShowEnemyUnitEntIndex = keys.entindex_victim_const
				end
			end
		end
	end

	if attacker.IsRealHero ~= nil and attacker:IsRealHero() then
		local victim_unitname = victim:GetUnitName()
		if BossConfigTable[victim_unitname] ~= nil then
			--BOSS易伤BUFF
			if victim:IsAlive() then
				local modifier = victim:FindModifierByName("modifier_boss_debuff")
				if modifier == nil then
					modifier = victim:AddNewModifier(victim, nil, "modifier_boss_debuff", {Duration = 5})
				else
					modifier:ForceRefresh()
				end
				-- keys.damage = keys.damage * math.pow(modifier.damageRate, modifier:GetStackCount())
			end
		end
	end

	return true
end

------------------------------------------------------------------------------------------------------------
-- 命令过滤器
------------------------------------------------------------------------------------------------------------
function Filter:ExecuteOrderFilter( params )
    if(params.order_type == 12) then
    	-- DOTA_UNIT_ORDER_GIVE_ITEM
        return false
    end

    if params.units == nil or params.units["0"] == nil then
        return false
    end

	local hero = EntIndexToHScript(params.units["0"])
	local target = EntIndexToHScript(params.entindex_target)

	if IsNull(hero) == false and hero.hasAI == true then
		return false
	end

	if params.order_type == 1 then
		-- DOTA_UNIT_ORDER_MOVE_TO_POSITION
		local pos = Vector(params.position_x, params.position_y, params.position_z)
		if hero:IsValidPosition(pos) == false then
			return false
		end

		local moveAb = hero:FindAbilityByName("ability_xxwar_move")
		if NotNull(moveAb) then
			if moveAb:GetCurrentAbilityCharges() > 0 then
				moveAb:SetCurrentAbilityCharges(moveAb:GetCurrentAbilityCharges() - 1)
				return true
			else
				return false
			end
		end

		return false
	end

	if params.order_type == 2 then
		-- DOTA_UNIT_ORDER_MOVE_TO_TARGET
		return false
	end

    if params.order_type == 4 then
    	-- DOTA_UNIT_ORDER_ATTACK_TARGET
	    if IsNull(hero) or IsNull(target) then
	        return false
	    end

		if hero:IsChanneling() then
	    	local currentActiveAbility = hero:GetCurrentActiveAbility()
	    	if currentActiveAbility ~= nil and currentActiveAbility:GetName() == "ability_xxwar_collection" then
	    		return false
            end
	    end

	    local abilityCollection = hero:FindAbilityByName("ability_xxwar_collection")
	    if abilityCollection ~= nil and target.HasAbility ~= nil then
		    -- 采集和开宝箱
		    if target:HasAbility("ability_collection_unit") then
	        	local charges = abilityCollection:GetCurrentAbilityCharges()
		        if abilityCollection:IsChanneling() == false and charges > 0 and abilityCollection:IsInAbilityPhase() == false then
		            hero:CastAbilityOnTarget(target, abilityCollection, hero:GetPlayerOwnerID())
		        elseif charges == 0 then
		            hero:ShowCustomMessage({type="bottom",msg="#xxwar_msg_can_not_collection",class="error"})
		        end
		        return false
		    end

		    -- 点击NPC
		    if target:HasAbility("ability_npc_unit") then
	        	hero:CastAbilityOnTarget(target, abilityCollection, hero:GetPlayerOwnerID())
		        return false
		    end

		    -- 点击传送点
		    if target:HasAbility("ability_npc_teleport") then
	        	hero:CastAbilityOnTarget(target, abilityCollection, hero:GetPlayerOwnerID())
		        return false
		    end

		    -- 复活队友
		    if target:HasAbility("ability_npc_tombstone") then
	        	hero:CastAbilityOnTarget(target, abilityCollection, hero:GetPlayerOwnerID())
		        return false
		    end
		end
    end

	return true
end

------------------------------------------------------------------------------------------------------------
-- Modifier过滤器
------------------------------------------------------------------------------------------------------------
function Filter:ModifierGainedFilter( keys )
	-- keys.entindex_parent_const
	-- keys.name_const
	-- keys.duration
	-- keys.entindex_caster_const
	
	return true
end

------------------------------------------------------------------------------------------------------------
-- 物品添加到物品栏过滤器
------------------------------------------------------------------------------------------------------------
function Filter:ItemAddedToInventory( keys )
	local iItemParentIndex = keys.item_parent_entindex_const
	local hItemParent = EntIndexToHScript(keys.item_parent_entindex_const)
	local hItem = EntIndexToHScript(keys.item_entindex_const)

	if NotNull(hItemParent) and hItemParent.IsPet then
		local playerId = hItemParent:GetPlayerID()
		local playerInfo = GameRules.XW:GetPlayerInfo(playerId)
		if playerInfo ~= nil then
			PlayerInfo:PetSay(playerId, hItemParent, "#xxwar_pet_say_item_thanks")
		end

		if NotNull(hItem) and hItem.SuggestSlot ~= nil then
			keys.suggested_slot = hItem.SuggestSlot
		end

		return true
	end

	-- 防止宝宝物品进入背包
	if NotNull(hItem) then
		if table.contains(KV_PET_ITEMS, hItem:GetName()) then
			return false
		end
	end

	return BagCtrl:InventoryFilter(keys)
end

------------------------------------------------------------------------------------------------------------
-- 投射物过滤器
------------------------------------------------------------------------------------------------------------

function Filter:TrackingProjectileFilter( keys )
	return true
end

------------------------------------------------------------------------------------------------------------
-- 金币过滤器
------------------------------------------------------------------------------------------------------------
function Filter:ModifyGoldFilter( keys )
	local playerId = keys.player_id_const
	local reason_const = keys.reason_const
	local reliable = keys.reliable

	local player = PlayerResource:GetPlayer(keys.player_id_const)
	if player == nil then return false end

	local hero = player:GetAssignedHero()
	if hero == nil then return false end

	local goldBounty = hero:GetCustomAttribute('gold_gain')
	if goldBounty and goldBounty > 0 then
		keys.gold = keys.gold + keys.gold * goldBounty * 0.01
	end

	keys.gold = keys.gold * 0.5

	hero:GiveGold(keys.gold)

	return true
end

------------------------------------------------------------------------------------------------------------
-- 经验过滤器
------------------------------------------------------------------------------------------------------------
function Filter:ModifyExperienceFilter( keys )
	local player = PlayerResource:GetPlayer(keys.player_id_const)
	if player == nil then return false end

	local hero = player:GetAssignedHero()
	if hero == nil then return false end

	local expBounty = hero:GetCustomAttribute('exp_gain')
	if expBounty and expBounty > 0 then
		keys.experience = keys.experience + keys.experience * expBounty * 0.01
	end

	keys.experience = keys.experience * 0.5

	return true
end

------------------------------------------------------------------------------------------------------------
-- 技能值过滤器
------------------------------------------------------------------------------------------------------------
function Filter:AbilityTuningValueFilter( keys )
	return true
end

------------------------------------------------------------------------------------------------------------
-- 神符捡起过滤器
------------------------------------------------------------------------------------------------------------
function Filter:BountyRunePickupFilter( keys )
	return true
end

------------------------------------------------------------------------------------------------------------
-- 神符过滤器
------------------------------------------------------------------------------------------------------------
function Filter:RuneSpawnFilter( keys )
	return true
end
