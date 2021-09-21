if RadarCtrl == nil then
	RadarCtrl = RegisterController('radars')
    RadarCtrl.__radars = {}
end

local public = RadarCtrl

function public:OnTouched(entIndex, caster)
    local radar = EntIndexToHScript(entIndex)
    if IsNull(radar) then return end
    local pos = radar:GetAbsOrigin()
    local duration = 20
    AddFOWViewer(caster:GetTeamNumber(), pos, 1200, duration, false)
    local players = GameRules.XW:FindPlayerInSameRegion(caster:GetPlayerID())
    for _, hero in ipairs(players) do
        hero:AddNewModifier(caster, nil, "modifier_item_dustofappearance", {duration = duration})
    end
    local path = "particles/world_outpost/world_outpost_radiant_ambient_shockwave.vpcf"
    local particleIndex = ParticleManager:CreateParticle(path, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particleIndex, 1, pos)

    local path2 = "particles/econ/items/jakiro/jakiro_ti10_immortal/jakiro_ti10_macropyre_screenshake.vpcf"
    local player = PlayerResource:GetPlayer(caster:GetPlayerID())
    local effect_cast = ParticleManager:CreateParticleForPlayer(path2, PATTACH_EYES_FOLLOW, caster, player)

    -- 同时照亮本区域其他玩家
    self:ShowOtherHeroesInRegion(caster, duration)
end

function public:ShowOtherHeroesInRegion(hero, duration)
    local info = GameRules.XW:GetPlayerInfo(hero:GetPlayerID())
    local regionId = info:GetStayRegionId()
    local teamId = info.TeamId
    local heroList = {}
    for _, playerInfo in pairs(GameRules.XW.PlayerList) do
        if playerInfo.TeamId ~= teamId and playerInfo:GetStayRegionId() == regionId then
            if IsAlive(playerInfo.Hero) then
                AddFOWViewer(teamId, playerInfo.Hero:GetAbsOrigin(), 500, duration, false)
            end
        end
    end
end
