if DropperCtrl == nil then
    DropperCtrl = RegisterController("dropper")
    setmetatable(DropperCtrl, DropperCtrl)
end

local public = DropperCtrl

function public:init()
    for unitName, v in pairs(Drop_Items) do
        for _, dropInfo in pairs(v) do
            local itemList = dropInfo.ItemList
            local weightSum = 0
            for _, value in pairs(itemList) do
                weightSum = weightSum + value[2]
            end
            for _, value in pairs(itemList) do
                value[2] = value[2] / weightSum
            end 
        end
    end
end

function public:__call(attacker, victim)
    if IsNull(attacker) or IsNull(victim) then
        return
    end

    if victim:GetTeam() ~= DOTA_TEAM_NEUTRALS then
        return
    end
    local unitName = victim:GetUnitName()
    local datas = {}

    local victimIsBoss = false

    if BOSS_ITEMS ~= nil and BOSS_ITEMS[unitName] ~= nil then
        datas = BOSS_ITEMS[unitName]
        victimIsBoss = true
    end

    if #datas == 0 then
        datas = Drop_Items[unitName]
    end

    if datas == nil or #datas == 0 then
        return
    end

    local magicFind =  0
    if attacker.GetMagicFind then
        magicFind = attacker:GetMagicFind()
    end
    local creepMagicFind = 0
    if victim:HasModifier("modifier_ability_creep_enhancement") then
        local creep_modifier = victim:FindModifierByName("modifier_ability_creep_enhancement")
        if creep_modifier ~= nil then
            local stacks = creep_modifier:GetStackCount()
            if stacks > 1 then
                creepMagicFind = creepMagicFind + (stacks - 1) * 15
            end
        end
    end

    for _, data in pairs(datas) do
        local dropCount = data.DropCount
        for i = 1, dropCount do
            local randomValue = math.random()
            local prob = tonumber(data.DropProb)
            prob = prob * (1 + tonumber(magicFind) / 100) * (1 + tonumber(creepMagicFind) / 100)
            if randomValue < prob then
                randomValue = math.random()
                local sumValue = 0
                local targetItemName = nil
                for _, dropItem in pairs(data.ItemList) do
                    if dropItem[2] + sumValue >= randomValue then
                        targetItemName = dropItem[1]
                        break
                    end
                    sumValue = sumValue + dropItem[2]
                end
                if targetItemName ~= nil and targetItemName ~= "null" then
                    self:DropItem(targetItemName, victim:GetAbsOrigin(), attacker)
                end
            end
        end
    end

    -- 存档属性
    if attacker.GetPlayerID and victimIsBoss and RollPercentage(100) then
        local playerInfo = GameRules.XW:GetPlayerInfo(attacker:GetPlayerID())
        if playerInfo ~= nil and NotNull(playerInfo.Hero) then
            local attrTypes = {"str", "agi", "int", "armor", "magic_armor"}
            local itemInfo = {
                name = table.random(attrTypes),
                value = 0.01,
            }
            playerInfo:UploadSavedItem(playerInfo.Hero:GetName(), itemInfo)
            playerInfo.Hero:ShowCustomMessage({
                type="message-box", 
                role="xxwar_save_item_notification",
                styles={color="#8b1bf4"},
                list={{text={"xxwar_msg_save_item_" .. itemInfo.name, tostring(itemInfo.value)}, args={}}},
            })
        end

        local imgPro = 0
        local targetImg = nil
        local chance = math.random()
        for k, v in pairs(IMG_PROBABLITY) do
            if chance <= v + imgPro then
                targetImg = k
                break
            else
                imgPro = imgPro + v
            end
        end
        if targetImg then
            playerInfo:UploadImgItem({name = targetImg, value = 1})
        end

        if RollPercentage(EXTRA_BONUS_PROBAALITY) then
            playerInfo:UploadImgItem({name = "Changeable", value = 1})
        end
    end
end

function public:FindReachablePoint(pos, radiusMin, radiusMax)
    local launchPos = pos + RandomVector(RandomInt(radiusMin, radiusMax))
    for var = 1, 100 do
        if not GridNav:IsTraversable(launchPos) then
            if var >= 100 then
                launchPos = pos
            else
                launchPos = pos + RandomVector(RandomInt(radiusMin,radiusMax))
            end
        else
            break
        end
    end
    return launchPos
end

function public:DropItem(targetItemName, pos, owner)
    local newItem = CreateItem(targetItemName, owner, owner)
    if NotNull(owner) then
        newItem:SetOwner(owner)
    end
    local itemConfig = ItemConfig[targetItemName]
    if NotNull(newItem) and itemConfig then
        local launchDuration = 0.4
        local dropPos = self:FindReachablePoint(pos, 50, 150)
        local drop = CreateItemOnPositionSync(pos, newItem)
        newItem:LaunchLoot( false, 100, launchDuration, dropPos )
        if itemConfig.quality >= 2 then
            Timers:CreateTimer(launchDuration + 0.1, function()
                if IsNull(drop) == false then
                    self:ShowDropEffect(drop, itemConfig.quality)
                end
            end)
        end
    end
end

function public:ShowDropEffect(drop, quality)
    if quality == nil or quality < 2 or quality > 5 then
        return
    end

    local droppedParticle = "particles/item_quality_lv".. tostring(quality) ..".vpcf"
    if IsAlive(drop) then

        local colorVector = {
            [2] = Vector(0, 255, 0),
            [3] = Vector(30, 144, 255),
            [4] = Vector(138, 43, 226),
            [5] = Vector(255, 76, 0),
        }
        local particleColor = Vector(0, 255, 0)
        if colorVector[quality] then
            particleColor = colorVector[quality]
        end

        local p1 = ParticleManager:CreateParticle(ParticleRes.ItemDrop, PATTACH_ABSORIGIN_FOLLOW, drop)
        ParticleManager:SetParticleControl(p1, 0, drop:GetAbsOrigin())
        ParticleManager:SetParticleControl(p1, 60, particleColor)
        ParticleManager:SetParticleControl(p1, 61, Vector(1, 0, 0))
        ParticleManager:ReleaseParticleIndex(p1)

        local p2 = ParticleManager:CreateParticle(droppedParticle, PATTACH_ABSORIGIN_FOLLOW, drop)
        ParticleManager:SetParticleControl(p2, 0, drop:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(p2)
    end
end