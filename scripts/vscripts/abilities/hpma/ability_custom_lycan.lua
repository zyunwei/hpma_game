ability_custom_lycan = ability_custom_lycan or class({})

function ability_custom_lycan:OnAbilityPhaseStart()
    return self:CheckPhaseStartWithMessage()
end

function ability_custom_lycan:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
	local ability = self
	if ability:CostCrystal() then
		local spawn_point = CallHeroPool:FindValidPathPoint(caster:GetAbsOrigin(), 100, 300)
		unit = CreateUnitByName("npc_hpma_lycan", spawn_point, true, caster, caster, caster:GetTeamNumber())
	    unit:SetOwner(caster)
		unit:SetContextThink("OnHeroThink", function() return HPMASummonAI:OnHeroThink(unit) end, 1)
	end
end
