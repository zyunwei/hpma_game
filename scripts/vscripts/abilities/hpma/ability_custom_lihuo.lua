ability_custom_lihuo = ability_custom_lihuo or class({})
function ability_custom_lihuo:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
	local ability = self
	

	local spawn_point = CallHeroPool:FindValidPathPoint(caster:GetAbsOrigin(), 100, 300)

	unit = CreateUnitByName("npc_hpma_lihuo", spawn_point, true, caster, caster, caster:GetTeamNumber())
    unit:SetOwner(caster)
    unit.IsPet = true
    unit:AddNewModifier(unit, nil, "modifier_pet_passive", {})
	unit:SetContextThink("OnHeroThink", function() return HPMASummonAI:OnHeroThink(unit) end, 1)
end

