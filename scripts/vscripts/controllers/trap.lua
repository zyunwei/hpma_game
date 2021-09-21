if TrapCtrl == nil then
	TrapCtrl = RegisterController('trap')
    TrapCtrl.TrapName = "npc_supply_trap"
    TrapCtrl.Traps = {}
    TrapCtrl.DamageMultipler = 30
    TrapCtrl.Particles = {}
    TrapCtrl.Quality = {}
    TrapCtrl.QualityProb = {
        [2] = 0.6,
        [3] = 0.3,
        [4] = 0.1,
    }
end

local public = TrapCtrl

function public:CreateTrap(hero, damageMultipler, duration)
    if IsNull(hero) then return end
    TrapCtrl.DamageMultipler = damageMultipler
    local targetPosition = hero:GetAbsOrigin() + hero:GetForwardVector():Normalized() * 100
    local safeRegions = BlockadeSystem:GetSafeRegions()
    if safeRegions and #safeRegions ~= 0 then
        local regionId = table.random(safeRegions)
        local region = BlockadeSystem:GetRegionById(regionId)
        if region then
            targetPosition = region:RandomPointInRegion()
        end
    end
    local unit = CreateUnitByName(self.TrapName, targetPosition, true, nil, hero, DOTA_TEAM_NEUTRALS)
    local quality = RandomFromProbValues(TrapCtrl.QualityProb)
    TrapCtrl.Quality[unit:entindex()] = quality
    if NotNull(unit) then
        local particalIndex = ParticleManager:CreateParticle(self:GetEffectPath(quality), PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(particalIndex, 0, targetPosition)
        TrapCtrl.Particles[unit:entindex()] = particalIndex
        unit:SetHullRadius(0)
        unit:SetAbility("ability_collection_unit")
        TrapCtrl.Traps[unit:entindex()] = hero:entindex()
        local pos = {
            x = (targetPosition.x + GameRules.XW.MapBorderSize) / (2 * GameRules.XW.MapBorderSize),
            y = (GameRules.XW.MapBorderSize - targetPosition.y) / (2 * GameRules.XW.MapBorderSize)
        }
        CustomNetTables:SetTableValue("TreasureIcon", tostring(unit:entindex()), { pos = pos, quality = quality})
    end

    Timers:CreateTimer(duration, function()
        if IsNull(unit) then return end
        self:DestroyTrap(unit:entindex())
    end)
end

function public:GetEffectPath(quality)
    if quality >= 5 then
        return "particles/ring_orange.vpcf"
    end
    if quality >= 4 then
        return "particles/ring_purple.vpcf"
    end
    if quality >= 3 then
        return "particles/ring_blue.vpcf"
    end
    return "particles/ring_green.vpcf"
end

function public:OnOpenTrap(trapIndex, caster)
    local trap = EntIndexToHScript(trapIndex)
    local hero = self:GetOwnerHero(trapIndex)
    if IsNull(trap) or IsNull(caster) or IsNull(hero) then return end
    if caster:GetTeamNumber() ~= hero:GetTeamNumber() then
        local particalIndex = ParticleManager:CreateParticle("particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_alliance_explosion.vpcf", PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(particalIndex, 0, trap:GetAbsOrigin())
        caster:EmitSound("Hero_Abaddon.AphoticShield.Destroy")
        local damageTable = {
            victim = caster,
            attacker = hero,
            damage = caster:GetMaxHealth() * self.DamageMultipler / 100,
            damage_type = DAMAGE_TYPE_MAGICAL,
        }
        ApplyDamage(damageTable)

        local item = GetRandomItemQuality({TrapCtrl.Quality[trapIndex]}, false)
        if item then
            hero:AddOwnerItemByName(item)
        end
    end
    self:DestroyTrap(trapIndex)
end

function public:GetOwnerHero(trapIndex)
    local hero = EntIndexToHScript(self.Traps[trapIndex])
    if NotNull(hero) then
        return hero
    end
    return nil
end

function public:DestroyTrap(trapIndex)
    local trap = EntIndexToHScript(trapIndex)
    if IsNull(trap) then return end
    CustomNetTables:SetTableValue("TreasureIcon", tostring(trapIndex), nil)
    CustomGameEventManager:Send_ServerToAllClients("destory_supply", {supplyIndex = trapIndex})
    ParticleManager:DestroyParticle(self.Particles[trapIndex], true)
    trap:Destroy()
    self.Particles[trapIndex] = nil
    self.Traps[trapIndex] = nil
end