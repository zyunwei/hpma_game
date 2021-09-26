ability_custom_hawk = ability_custom_hawk or class({})

function ability_custom_hawk:OnAbilityPhaseStart()
    return self:CheckPhaseStartWithMessage()
end

function ability_custom_hawk:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
	local ability = self
	if ability:CostCrystal() then
		local spawn_particle = "particles/units/heroes/hero_beastmaster/beastmaster_call_bird.vpcf"

		caster:EmitSound("Hero_Beastmaster.Call.Boar")
		for i = 1, 3 do
			local spawn_point = CallHeroPool:FindValidPathPoint(caster:GetAbsOrigin(), 100, 300)
			local spawn_particle_fx = ParticleManager:CreateParticle(spawn_particle, PATTACH_ABSORIGIN, caster)
			ParticleManager:SetParticleControl( spawn_particle_fx, 0, spawn_point )
			unit = CreateUnitByName("npc_hpma_hawk", spawn_point, true, caster, caster, caster:GetTeamNumber())
		    unit:SetOwner(caster)
		    unit:SetForwardVector(caster:GetForwardVector())
		end
	end
end
