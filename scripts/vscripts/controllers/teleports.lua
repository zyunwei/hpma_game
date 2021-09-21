if TeleportsCtrl == nil then
	TeleportsCtrl = RegisterController('teleports')
	TeleportsCtrl.__teleports = {}
end

local public = TeleportsCtrl

function public:init()
    -- for i, pos in ipairs(TELEPORT_POSITION) do
    --     local teleportUnit = CreateUnitByName("npc_teleport", pos, false, nil, nil, DOTA_TEAM_NEUTRALS)
    --     if teleportUnit ~= nil then
    --         teleportUnit:SetHullRadius(0)
    --         teleportUnit:SetAbility("ability_npc_teleport")
    --         table.insert(TeleportsCtrl.__teleports, teleportUnit:GetEntityIndex())

    --         local particle = ParticleManager:CreateParticle(ParticleRes.TELEPORT_POINT, PATTACH_WORLDORIGIN, teleportUnit)
    --         ParticleManager:SetParticleControl(particle, 0, teleportUnit:GetAbsOrigin())

    --         for teamId, _ in pairs(GameRules.XW.TeamColor) do
    --             AddFOWViewer(teamId, pos, 200, 9999, false)
    --         end
    --     end
    -- end
end
