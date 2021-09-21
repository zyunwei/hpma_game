
--@Class CDOTA_BaseNPC

local ____CDOTA_BaseNPC_SpawnOrigin = Avalon:Forever('____CDOTA_BaseNPC_SpawnOrigin',{})
function CDOTA_BaseNPC:SetSpawnOrigin(vec)
    ____CDOTA_BaseNPC_SpawnOrigin[self:GetEntityIndex()] = vec
end

function CDOTA_BaseNPC:GetSpawnOrigin()
    return ____CDOTA_BaseNPC_SpawnOrigin[self:GetEntityIndex()] or self:GetOrigin()
end

function CDOTA_BaseNPC:CameraLock(duration)
    PlayerResource:SetCameraTarget(self:GetPlayerOwnerID(), self)
    self:SetContextThink("__CDOTA_BaseNPC_CameraLock__", function ()
        if GameRules:IsGamePaused() then return 0.1 end
        PlayerResource:SetCameraTarget(self:GetPlayerOwnerID(), nil)
        return nil
    end, duration or 0.1)
end

function CDOTA_BaseNPC:HasItem( item )
    if not item or item:IsNull() then return false end
    if not self:HasInventory() then return false end

    for i=0,5 do
        local t = self:GetItemInSlot(i)
        if t and not t:IsNull() and t == item then
            return true
        end
    end

    return false
end

function CDOTA_BaseNPC:GetHealthPercent()
    return self:GetHealth() / self:GetMaxHealth() * 100
end

function CDOTA_BaseNPC:SetAbility(abilityName, activated, level)
    if level == nil then level = 1 end
    if activated == nil then activated = true end

    if self.FindAbilityByName then
        local ability = self:FindAbilityByName(abilityName)
        if ability == nil then
            ability = self:AddAbility(abilityName)
        end

        if ability ~= nil then
            ability:SetLevel(level)
            ability:SetActivated(activated)
            return ability
        end
    end

    return nil
end

function CDOTA_BaseNPC:AppendAbility(abilityName, activated, level)
    if level == nil then level = 1 end
    if activated == nil then activated = true end

    if self.FindAbilityByName then
        local ability = self:FindAbilityByName(abilityName)
        if ability == nil then
            for i = 0, 31 do 
                local chkAbility = self:GetAbilityByIndex(i)
                if chkAbility ~= nil and string.find(chkAbility:GetName(), "xxwar_empty_ability_") ~= nil then
                    self:RemoveAbilityByHandle(chkAbility)
                    ability = self:AddAbility(abilityName)
                    break
                end
            end
        end

        if ability ~= nil then
            ability:SetLevel(level)
            ability:SetActivated(activated)
        end
    end
end

function CDOTA_BaseNPC:GetMagicFind()
    local magicFind = 0
    if self.GetCustomAttribute ~= nil then
        magicFind = self:GetCustomAttribute('magic_find')
    end
    for _, parent_modifier in pairs(self:FindAllModifiers()) do
        if parent_modifier.GetBonusMagicFind and parent_modifier:GetBonusMagicFind() then
            magicFind = magicFind + parent_modifier:GetBonusMagicFind()
        end
    end
    return magicFind
end

function CDOTA_BaseNPC:CanUseEquipSkill()
    if self:IsHexed() or self:IsStunned() or self:IsSilenced() then
        return false
    end
    return true
end

-- 替换GetAssociatedPrimaryAbilities方法，有些技能没有关联，如嗜血术和多重施法
function CDOTA_BaseNPC:GetAddonMainAbilities()
    local addonAbilities = {}
    for i = 0, 7 do 
        local ability = self:GetAbilityByIndex(i)
        if IsNull(ability) == false then
            local secondaryAbilityName = ability:GetAssociatedSecondaryAbilities()
            if secondaryAbilityName ~= nil and string.find(secondaryAbilityName, ";") == nil and
                table.contains(GameRules.XW.IndependentAbilities, secondaryAbilityName) == false then
                table.insert(addonAbilities, secondaryAbilityName)
            end
        end
    end

    return addonAbilities
end

function CDOTA_BaseNPC:AppendMainAbility(abilityName, activated, level, max_size)
    if max_size == nil then max_size = 4 end

    local mainAbilityCount = 0
    local addonAbilities = self:GetAddonMainAbilities()
    for i = 0, 7 do 
        local chkAbility = self:GetAbilityByIndex(i)
        if chkAbility ~= nil and string.find(chkAbility:GetName(), "xxwar_empty_ability_") == nil then
            if table.contains(addonAbilities, chkAbility:GetName()) == false then
                mainAbilityCount = mainAbilityCount + 1
            end
        end
    end

    if mainAbilityCount >= 4 then
        return false
    end

    local success = self:AppendAbilityInRange(abilityName, activated, level, 0, max_size - 1)
    -- 附带技能
    if success and table.contains(GameRules.XW.IndependentAbilities, abilityName) == false then
        local ability = self:FindAbilityByName(abilityName)
        if IsNull(ability) == false then
            local secondaryAbilityName = ability:GetAssociatedSecondaryAbilities()
            if secondaryAbilityName and string.find(secondaryAbilityName, ";") == nil then
                self:AppendAbilityInRange(secondaryAbilityName, activated, level, 0, max_size - 1)
            end
        end
    end

    return success
end

function CDOTA_BaseNPC:AppendMinorAbility(abilityName, activated, level, max_size)
    if max_size == nil then max_size = 4 end
    local result = self:AppendAbilityInRange(abilityName, activated, level, 0, max_size - 1)
    return result
end

function CDOTA_BaseNPC:AppendAbilityInRange(abilityName, activated, level, startIndex, endIndex)
    if startIndex == nil then
        startIndex = 0
    end
    if endIndex == nil then
        endIndex = 7
    end
    if level == nil then level = 1 end
    if activated == nil then activated = true end

    if self.FindAbilityByName then
        local ability = self:FindAbilityByName(abilityName)
        if ability == nil then
            for i = startIndex, endIndex do
                local chkAbility = self:GetAbilityByIndex(i)
                if chkAbility ~= nil and string.find(chkAbility:GetName(), "xxwar_empty_ability_") ~= nil then
                    self:RemoveAbilityByHandle(chkAbility)
                    ability = self:AddAbility(abilityName)
                    break
                end
            end
        end

        if ability ~= nil then
            ability:SetLevel(level)
            ability:SetActivated(activated)
            return true
        end

        self:CheckAbilitySlots()
        return false
    end
    return false
end

function CDOTA_BaseNPC:RemoveMainAbilityByIndex(index, removeSecondary)
    local ability = self:GetAbilityByIndex(index)
    if IsNull(ability) then return end
    removeSecondary = removeSecondary or false

    local abilityName = ability:GetName()
    local addonAbilities = self:GetAddonMainAbilities()
    if table.contains(addonAbilities, abilityName) and removeSecondary == false then
        return
    end

    local secondaryAbilities = ability:GetAssociatedSecondaryAbilities()
    if secondaryAbilities ~= nil and string.find(secondaryAbilities, ";") ~= nil then
        secondaryAbilities = nil
    end

    local modifiers = self:FindAllModifiers()
    for _, v in pairs(modifiers) do
        if v:GetAbility() == ability then
            self:RemoveModifierByName(v:GetName())
        end
    end
    self:RemoveAbilityByHandle(ability)

    self:AddAbility("xxwar_empty_ability_" .. index)

    if table.contains(GameRules.XW.IndependentAbilities, abilityName) == false then
        if secondaryAbilities then
            self:RemoveAbilityByName(secondaryAbilities, true)
        end
    end

    self:CheckAbilitySlots()
end

function CDOTA_BaseNPC:RemoveAbilityByName(abilityName, removeSecondary)
    if string.find(abilityName, "xxwar_empty_ability_") ~= nil then
        return -1
    end

    for i = 0, 31 do 
        local chkAbility = self:GetAbilityByIndex(i)
        if chkAbility ~= nil and chkAbility:GetName() == abilityName then
            if chkAbility.OnFold ~= nil then
                chkAbility:OnFold()
            end
            -- print(self:GetAbilityPoints())
            -- print(chkAbility:GetLevel())
            self:SetAbilityPoints(self:GetAbilityPoints() + chkAbility:GetLevel())
            self:RemoveMainAbilityByIndex(i, removeSecondary)
            return i
        end
    end

    return -1
end

function CDOTA_BaseNPC:CheckAbilitySlots()
    for i = 0, 11 do 
        local ability = self:GetAbilityByIndex(i)
        if ability == nil then
            self:AddAbility("xxwar_empty_ability_" .. i)
        end
    end

    for i = 12, 17 do 
        local ability = self:GetAbilityByIndex(i)
        if ability == nil then
            self:AddAbility(Custom_Item_Spell_Prefix .. (i - 11))
        end
    end

    for i = 18, 22 do
        local ability = self:GetAbilityByIndex(i)
        if ability == nil then
            self:AddAbility("xxwar_empty_ability_" .. i)
        end
    end
end

function CDOTA_BaseNPC:UpdateMinorAbilityState()
    if self.GetPlayerID == nil then return end
    local playerId = self:GetPlayerID()
    local abilities = {}
    for i = 0, 4 do
        local ability = self:GetAbilityByIndex(i)
        if NotNull(ability) and string.find(ability:GetName(), "xxwar_empty_ability_") == nil then
            table.insert(abilities, ability)
        end
    end

    for _, ability in pairs(abilities) do
        if NotNull(ability) and ability:IsActivated() == false and ability:IsCooldownReady() then
            CardGroupSystem:PlayerFoldCard(playerId, ability:GetName())

            local ability = self:GetAbilityByIndex(5)
            if ability ~= nil then
                self:RemoveAbilityByHandle(ability)
                self:CheckAbilitySlots()
            end

            CardGroupSystem:PlayerDrawCard(playerId)
            CardGroupSystem:PeekCard(playerId)
        end
    end
end

function CDOTA_BaseNPC:GetLifesteal()
	local lifesteal = 0
	local multiplier = 0

	for _, parent_modifier in pairs(self:FindAllModifiers()) do
		if parent_modifier.GetModifierLifesteal and parent_modifier:GetModifierLifesteal() then
			lifesteal = lifesteal + parent_modifier:GetModifierLifesteal()
		end
	end

	for _, parent_modifier in pairs(self:FindAllModifiers()) do
		if parent_modifier.GetModifierLifestealAmplify and parent_modifier:GetModifierLifestealAmplify() then
			multiplier = multiplier + parent_modifier:GetModifierLifestealAmplify()
		end
	end

	if lifesteal ~= 0 and multiplier ~= 0 then
		lifesteal = lifesteal * (multiplier / 100)
	end

	return lifesteal
end

function CDOTA_BaseNPC:GetSpellLifesteal()
    local lifesteal = 0
    local multiplier = 0

    for _, parent_modifier in pairs(self:FindAllModifiers()) do
        if parent_modifier.GetModifierSpellLifesteal and parent_modifier:GetModifierSpellLifesteal() then
            lifesteal = lifesteal + parent_modifier:GetModifierSpellLifesteal()
        end

        if parent_modifier.GetModifierSpellLifestealAmplify and parent_modifier:GetModifierSpellLifestealAmplify() then
            multiplier = multiplier + parent_modifier:GetModifierSpellLifestealAmplify()
        end
    end

    if lifesteal ~= 0 and multiplier ~= 0 then
        lifesteal = lifesteal * (multiplier / 100)
    end

    return lifesteal
end

function CDOTA_BaseNPC:GetHealthPercentEnemyHero(radius, includeMagicImmune, healthPercent)
    local target_type = DOTA_UNIT_TARGET_HERO
    local target_team =  DOTA_UNIT_TARGET_TEAM_ENEMY
    local target_flags = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE

    local enemies = FindUnitsInRadius(self:GetTeam(), self:GetAbsOrigin(), nil, radius, target_team, target_type, target_flags, FIND_CLOSEST, false)

    local target = nil
    for _, enemy in pairs(enemies) do
        if NotNull(enemy) and IsAlive(enemy) and enemy.IsRealHero ~= nil and enemy:IsRealHero() and enemy:GetHealthPercent() <= healthPercent then
            if includeMagicImmune == true or enemy:IsMagicImmune() == false then
                target = enemy
                break
            end
        end
    end

    return target
end

function CDOTA_BaseNPC:GetNearestEnemyHero(radius, includeMagicImmune)
    local target_type = DOTA_UNIT_TARGET_HERO
    local target_team =  DOTA_UNIT_TARGET_TEAM_ENEMY
    local target_flags = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE

    local enemies = FindUnitsInRadius(self:GetTeam(), self:GetAbsOrigin(), nil, radius, target_team, target_type, target_flags, FIND_CLOSEST, false)

    local target = nil
    for _, enemy in pairs(enemies) do
        if NotNull(enemy) and IsAlive(enemy) and enemy.IsRealHero ~= nil and enemy:IsRealHero() then
            if includeMagicImmune == true or enemy:IsMagicImmune() == false then
                target = enemy
                break
            end
        end
    end

    return target
end

function CDOTA_BaseNPC:GetNearestBoss(radius, includeMagicImmune)
    local target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
    local target_team =  DOTA_UNIT_TARGET_TEAM_ENEMY
    local target_flags = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE

    local enemies = FindUnitsInRadius(self:GetTeam(), self:GetAbsOrigin(), nil, radius, target_team, target_type, target_flags, FIND_CLOSEST, false)

    local target = nil
    for _, enemy in pairs(enemies) do
        if NotNull(enemy) and IsAlive(enemy) and enemy.IsBoss == true then
            if includeMagicImmune == true or enemy:IsMagicImmune() == false then
                target = enemy
                break
            end
        end
    end

    return target
end

function CDOTA_BaseNPC:GetNearestEnemy(radius, includeMagicImmune, healthPercent)
    local target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
    local target_team =  DOTA_UNIT_TARGET_TEAM_ENEMY
    local target_flags = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE

    local enemies = FindUnitsInRadius(self:GetTeam(), self:GetAbsOrigin(), nil, radius, target_team, target_type, target_flags, FIND_CLOSEST, false)

    local target = nil
    for _, enemy in pairs(enemies) do
        if NotNull(enemy) and IsAlive(enemy) then
            if (includeMagicImmune == true or enemy:IsMagicImmune() == false) and enemy:GetHealthPercent() <= healthPercent then
                target = enemy
                break
            end
        end
    end

    return target
end

function CDOTA_BaseNPC:GetNearestEnemyForAI(radius, includeMagicImmune, healthPercent)
    local target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
    local target_team =  DOTA_UNIT_TARGET_TEAM_ENEMY
    local target_flags = DOTA_UNIT_TARGET_FLAG_NONE

    local enemies = FindUnitsInRadius(self:GetTeam(), self:GetAbsOrigin(), nil, radius, target_team, target_type, target_flags, FIND_CLOSEST, false)

    local target = nil
    for _, enemy in pairs(enemies) do
        if NotNull(enemy) and IsAlive(enemy) then
            if (includeMagicImmune == true or enemy:IsMagicImmune() == false) and enemy:GetHealthPercent() <= healthPercent then
                target = enemy
                break
            end
        end
    end

    return target
end

function CDOTA_BaseNPC:GetLowHealthAlliesHero(radius, withoutModiferName)
    local target_type = DOTA_UNIT_TARGET_HERO
    local target_team =  DOTA_UNIT_TARGET_TEAM_FRIENDLY
    local target_flags = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE

    local allies = FindUnitsInRadius(self:GetTeam(), self:GetAbsOrigin(), nil, radius, target_team, target_type, target_flags, FIND_CLOSEST, false)

    local target = nil
    local minHealthPercent = 100

    for _, ally in pairs(allies) do
        if NotNull(ally) and IsAlive(ally) and ally.IsRealHero ~= nil and ally:IsRealHero() and ally:IsIllusion() == false then
            if withoutModiferName == nil or ally:HasModifier(withoutModiferName) == false then
                if ally:GetHealthPercent() <= minHealthPercent then
                    minHealthPercent = ally:GetHealthPercent()
                    target = ally
                end
            end
        end
    end

    return target
end

function CDOTA_BaseNPC:GetCreepInRadius(radius, exceptAncients)
    local target_type = DOTA_UNIT_TARGET_CREEP
    local target_team =  DOTA_UNIT_TARGET_TEAM_ENEMY
    local target_flags = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE
    local creeps = FindUnitsInRadius(self:GetTeam(), self:GetAbsOrigin(), nil, radius, target_team, target_type, target_flags, FIND_CLOSEST, false)

    local target = nil
    for _, creep in pairs(creeps) do
        if NotNull(creep) and IsAlive(creep) then
            if (exceptAncients == false or creep:IsAncient() == false) and creep:HasModifier("modifier_animal") == false then
                target = creep
                break
            end
        end
    end
    return target
end

function CDOTA_BaseNPC:GetTreeInRadius(radius)
    local trees = GridNav:GetAllTreesAroundPoint(self:GetAbsOrigin(), radius, true)
    local target = nil
    local minDistance = 99999999999
    for _, tree in pairs(trees) do
        if tree:IsStanding() then
            local distance = (self:GetAbsOrigin() - tree:GetAbsOrigin()):Length()
            if distance < minDistance then
                minDistance = distance
                target = tree
            end
        end
    end
    return target
end

function CDOTA_BaseNPC:CenterCameraOnEntity(hTarget, iDuration)
	PlayerResource:SetCameraTarget(self:GetPlayerID(), hTarget)
	if iDuration == nil then iDuration = FrameTime() end
	if iDuration ~= -1 then
		Timers:CreateTimer(iDuration, function()
			PlayerResource:SetCameraTarget(self:GetPlayerID(), nil)
			Timers:CreateTimer(FrameTime(), function() --fail-safe
				PlayerResource:SetCameraTarget(self:GetPlayerID(), nil)
			end)
			Timers:CreateTimer(FrameTime() * 3, function() --fail-safe
				PlayerResource:SetCameraTarget(self:GetPlayerID(), nil)
			end)
		end)
	end
end
