ability_custom_sniper = ability_custom_sniper or class({})

function ability_custom_sniper:OnAbilityPhaseStart()
    return self:CheckPhaseStartWithMessage()
end

function ability_custom_sniper:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
	local ability = self
	if ability:CostCrystal() then
		local spawn_point = CallHeroPool:FindValidPathPoint(caster:GetAbsOrigin(), 100, 300)
		unit = CreateUnitByName("npc_hpma_sniper", spawn_point, true, caster, caster, caster:GetTeamNumber())
	    unit:SetOwner(caster)
		unit:SetContextThink("OnHeroThink", function() return HPMASummonAI:OnHeroThink(unit) end, 1)
	end
end
