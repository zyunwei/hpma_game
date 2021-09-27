if CallHeroPool == nil then
	CallHeroPool = RegisterController('call_hero_pool')
	setmetatable(CallHeroPool, CallHeroPool)
end

local public = CallHeroPool

function public:init()
    self.PlayerCallHeroInfos = {}
end

function public:OnPlayerCallHero(playerId, hero)
    if self.PlayerCallHeroInfos[playerId] == nil then
        self.PlayerCallHeroInfos[playerId] = {}
    end
    local entIndex = hero:entindex()

    if table.contains(self.PlayerCallHeroInfos[playerId], entIndex) == false then
        table.insert(self.PlayerCallHeroInfos[playerId], entIndex)
        CustomNetTables:SetTableValue("PlayerSummonHeroes", tostring(playerId), self.PlayerCallHeroInfos[playerId])
    end
end

function public:GetPlayerHeroPets(playerId)
    if playerId == nil then return nil end
    return self.PlayerCallHeroInfos[playerId]
end

function public:GetPlayerPet(playerId, petName)
    local pets = self:GetPlayerHeroPets(playerId)
    if pets == nil then return end
    for _, petIndex in pairs(pets) do
        local pet = EntIndexToHScript(petIndex)
        if NotNull(pet) then
            if pet:GetUnitName() == petName then
                return pet
            end
        end
    end
    return nil
end

function public:GetPlayerPets(playerId)
    local pets = self:GetPlayerHeroPets(playerId)
    if pets == nil then return {} end

    local petList = {}
    for _, petIndex in pairs(pets) do
        local pet = EntIndexToHScript(petIndex)
        if NotNull(pet) then
            table.insert(petList, pet)
        end
    end
    return petList
end

function public:SummonHero(caster, duration, unitName)
    if IsNull(caster) then
        return
    end
    local unit_name = unitName
    if unit_name == nil then
        return
    end

    local tougyuBuff = caster:FindModifierByName("modifier_ability_custom_tongyu_buff")
    if NotNull(tougyuBuff) then
        duration = duration + tougyuBuff:GetBonusDuartion()
    end

    local affixAttr = caster:GetCustomAttribute("pet_duration")
    if affixAttr and affixAttr > 0 then
        duration = duration + affixAttr
    end

    local playerId = caster:GetPlayerID()

    if caster:HasModifier("modifier_ability_custom_jiasulunhui_buff") then
        caster:RemoveModifierByName("modifier_ability_custom_jiasulunhui_buff")
    end

    if caster:HasModifier("modifier_ability_custom_tongyu_buff") then
        caster:RemoveModifierByName("modifier_ability_custom_tongyu_buff")
    end

    local spawn_point = self:FindValidPathPoint(caster:GetAbsOrigin(), 100, 300)
    -- local spawn_particle = "particles/units/heroes/hero_beastmaster/beastmaster_call_boar.vpcf"
    -- caster:EmitSound("Hero_Beastmaster.Call.Boar")
    -- local spawn_particle_fx = ParticleManager:CreateParticle(spawn_particle, PATTACH_ABSORIGIN, caster)
    -- ParticleManager:SetParticleControl( spawn_particle_fx, 0, spawn_point )
    local unit = self:GetPlayerPet(playerId, unit_name)
    -- if NotNull(unit) and unit:IsAlive() then
    --     local killModifier = unit:FindModifierByName("modifier_kill")
    --     if NotNull(killModifier) then
    --         unit:AddNewModifier(caster, nil, "modifier_kill", { duration = duration + killModifier:GetRemainingTime()})
    --         unit:SetHealth(unit:GetMaxHealth())
    --         unit:SetMana(unit:GetMaxMana())
    --         unit:EndAbilitiesCooldown()
    --         unit:EndItemsCooldown()
    --         return unit
    --     end
    -- end

    if IsNull(unit) then
        unit = CreateUnitByName(unit_name, spawn_point, true, caster, caster, caster:GetTeamNumber())
        unit:SetOwner(caster)
        unit:InitHeroTalent()
        unit.IsPet = true
        unit:AddNewModifier(unit, nil, "modifier_pet_passive", {})

        PlayerInfo:PetSay(playerId, unit, "#xxwar_pet_say_born")

        local defaultItems = DEFAULT_PET_ITEM[unitName]
        if defaultItems then 
            for _, defaultItem in ipairs(defaultItems) do
                unit:AddItemByName(defaultItem)
            end
        end
        unit:AddExperience(PetExpCtrl:GetTotalExp(), 0, false, false)
        local heroLevel = caster:GetLevel()
        if heroLevel > 1 then
            if unit.CreatureLevelUp ~= nil then
                unit:CreatureLevelUp(heroLevel - 1)
            elseif unit.IsHero ~= nil and unit:IsHero() then
                for i = 1, 9 do
                    unit:HeroLevelUp(false)
                    unit:AutoUpgradeAbility(true)
                end
            end
        end

        PetTalentCtrl:SaveTalent(unit)
    elseif unit:IsAlive() == false then
        PlayerInfo:PetSay(playerId, unit, "#xxwar_pet_say_respawn")
        unit:SetRespawnPosition(spawn_point)
        unit:RespawnHero(false, false)
        unit:EndAbilitiesCooldown()
        unit:EndItemsCooldown()
    end

    local modifierPetEnhancement = caster:FindModifierByName("modifier_ability_custom_devour_pet_buff")
    if NotNull(modifierPetEnhancement) then
        local modifierParams = {
            pet_bonus_health = modifierPetEnhancement:GetPetBonusHealth(),
            pet_bonus_attack_damage = modifierPetEnhancement:GetPetBonusAttackDamage(),
        }
        unit:AddNewModifier(caster, nil, "modifier_pet_enhancement", modifierParams)
    end

    local modifierPetArmor = caster:FindModifierByName("modifier_ability_custom_pet_armor_up_buff")
    if NotNull(modifierPetArmor) then
        unit:AddNewModifier(caster, nil, "modifier_pet_armor_up", {})
    end

    -- unit:AddNewModifier(caster, nil, "modifier_kill", { duration = duration })
    
    unit:SetContextThink("OnHeroThink", function() return SummonAI:OnHeroThink(unit) end, 1)
    self:OnPlayerCallHero(playerId, unit)

    -- for i = 1, 3 do
    --     PlayerInfo:AddRandomItemForPet(playerId, false)
    -- end

    -- local randomItemModifier = caster:FindModifierByName("modifier_pet_random_item")
    -- if NotNull(randomItemModifier) then
    --     if PlayerInfo:AddRandomItemForPet(playerId, false) then
    --         randomItemModifier:DecrementStackCount()
    --     end
    -- end

    return unit
end

function public:FindValidPathPoint(pos, radiusMin, radiusMax)
    local targetPos = pos + RandomVector(RandomInt(radiusMin, radiusMax))
    for var = 1, 100 do
        if not GridNav:CanFindPath(pos, targetPos) then
            if var >= 100 then
                targetPos = pos
            else
                targetPos = pos + RandomVector(RandomInt(radiusMin,radiusMax))
            end
        else
            break
        end
    end
    return targetPos
end