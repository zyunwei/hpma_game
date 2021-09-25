ability_custom_cat = ability_custom_cat or class({})

LinkLuaModifier("modifier_custom_cat", "abilities/hpma/ability_custom_cat", LUA_MODIFIER_MOTION_NONE)

function ability_custom_cat:OnAbilityPhaseStart()
    return self:CheckPhaseStartWithMessage()
end

function ability_custom_cat:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
	local ability = self
	if ability:CostCrystal() then
        local spawn_point = CallHeroPool:FindValidPathPoint(caster:GetAbsOrigin(), 100, 300)
        local unit = CreateUnitByName("npc_hpma_cat", spawn_point, true, caster, caster, caster:GetTeamNumber())
        unit:SetOwner(caster)
        unit:SetContextThink("OnHeroThink", function() return HPMASummonAI:OnHeroThink(unit) end, 1)
		unit:AddNewModifier(caster, nil, "modifier_custom_cat", {})
	end
end


modifier_custom_cat = class({})

function modifier_custom_cat:IsHidden()		return true end
function modifier_custom_cat:IsPurgable()		return false end
function modifier_custom_cat:RemoveOnDeath()	return false end

function modifier_custom_cat:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end

function modifier_custom_cat:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local parent = self:GetParent()
	if IsNull(caster) or IsNull(parent) then return end
	if parent:GetHealth() <= 100 then 
		parent:SetHealth(parent:GetMaxHealth())
		local spawn_point = CallHeroPool:FindValidPathPoint(caster:GetAbsOrigin(), 100, 300)
		for i = 1,2 do
			local spawn_point = CallHeroPool:FindValidPathPoint(parent:GetAbsOrigin(), 100, 300)
        	local unit = CreateUnitByName("npc_hpma_cat_small", spawn_point, true, caster, caster, caster:GetTeamNumber())
			unit:SetOwner(caster)
			unit:SetContextThink("OnHeroThink", function() return HPMASummonAI:OnHeroThink(unit) end, 1)
		end
		self:Destroy()
	end
end