ability_custom_broodmother = ability_custom_broodmother or class({})

function ability_custom_broodmother:OnAbilityPhaseStart()
    return self:CheckPhaseStartWithMessage()
end

function ability_custom_broodmother:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
	local ability = self
	if ability:CostCrystal() then
		caster:EmitSound("Hero_Broodmother.SpawnSpiderlings")
		local spawn_point = CallHeroPool:FindValidPathPoint(caster:GetAbsOrigin(), 100, 300)
		unit = CreateUnitByName("npc_hpma_broodmother", spawn_point, true, caster, caster, caster:GetTeamNumber())

		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_broodmother/broodmother_spiderlings_spawn.vpcf", PATTACH_ABSORIGIN, unit)
		ParticleManager:SetParticleControl(pfx, 0, unit:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(pfx)

	    unit:SetOwner(caster)
	    unit:SetForwardVector(caster:GetForwardVector())
	end
end
