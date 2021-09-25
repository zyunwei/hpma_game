ability_custom_ghost_book = ability_custom_ghost_book or class({})

function ability_custom_ghost_book:OnAbilityPhaseStart()
    return self:CheckPhaseStartWithMessage()
end

function ability_custom_ghost_book:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
	local ability = self
	if ability:CostCrystal() then
        for i = 1,3 do
            local spawn_point = CallHeroPool:FindValidPathPoint(caster:GetAbsOrigin(), 100, 300)
            local unit = CreateUnitByName("npc_hpma_ghost_book", spawn_point, true, caster, caster, caster:GetTeamNumber())
            unit:SetOwner(caster)
            unit:SetContextThink("OnHeroThink", function() return HPMASummonAI:OnHeroThink(unit) end, 1)
        end
	end
end
