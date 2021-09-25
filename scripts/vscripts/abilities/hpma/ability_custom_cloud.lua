ability_custom_cloud = ability_custom_cloud or class({})
LinkLuaModifier("modifier_custom_cloud", "abilities/hpma/ability_custom_cloud", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_custom_silence", "abilities/hpma/ability_custom_cloud", LUA_MODIFIER_MOTION_NONE)

function ability_custom_cloud:OnAbilityPhaseStart()
    return self:CheckPhaseStartWithMessage()
end

function ability_custom_cloud:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()

    local target_point = caster:GetCursorPosition()
	if IsNull(caster) then return end
	local ability = self
	if ability:CostCrystal() then
        local unit = CreateUnitByName("npc_dota_zeus_cloud", target_point, true, caster, caster, caster:GetTeamNumber())
        unit:SetOwner(caster)
        unit:AddNewModifier(caster, nil, "modifier_custom_cloud",{duration = 9.5})
	end
end

modifier_custom_cloud = class({})

function modifier_custom_cloud:CheckState()
	return {
        [MODIFIER_STATE_UNTARGETABLE]       = true,
        [MODIFIER_STATE_UNSELECTABLE]       = true,
	}
end


function modifier_custom_cloud:OnCreated()
    if not IsServer() then return end
    self.cloud_radius = 250
    local target_point = GetGroundPosition(self:GetParent():GetAbsOrigin(), self:GetParent())
    self.zuus_nimbus_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zeus/zeus_cloud.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())

    ParticleManager:SetParticleControl(self.zuus_nimbus_particle, 0, Vector(target_point.x, target_point.y, 450))

    ParticleManager:SetParticleControl(self.zuus_nimbus_particle, 1, Vector(self.cloud_radius, 0, 0))

    ParticleManager:SetParticleControl(self.zuus_nimbus_particle, 2, Vector(target_point.x, target_point.y, target_point.z + 450))	

    self:StartIntervalThink(0.5)
end

function modifier_custom_cloud:OnIntervalThink()
    local nearby_enemy_units = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(), 
        self:GetParent():GetAbsOrigin(), 
        nil, 
        self.cloud_radius, 
        DOTA_UNIT_TARGET_TEAM_ENEMY, 
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,
        false
    )

    for _,unit in pairs(nearby_enemy_units) do
        --particles/units/heroes/hero_zeus/zeus_cloud_death.vpcf
        
        local partic = ParticleManager:CreateParticle("particles/units/heroes/hero_zeus/zeus_cloud_death.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())

        ParticleManager:SetParticleControl(partic, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl(partic, 2, unit:GetAbsOrigin())

        ApplyDamage({
            victim = unit,
            attacker = self:GetCaster(),
            damage = 20,
            damage_type = DAMAGE_TYPE_MAGICAL,
        })
        unit:AddNewModifier(self:GetCaster(), nil,"modifier_custom_silence", {duration = 3.5})
    end

end

function modifier_custom_cloud:OnRemoved()
    ParticleManager:DestroyParticle(self.zuus_nimbus_particle, false)
    self:GetParent():ForceKill(false)
end

modifier_custom_silence = class({})

function modifier_custom_silence:IsDebuff() return true end

function modifier_custom_silence:CheckState()
	return {
        [MODIFIER_STATE_SILENCED]       = true,
	}
end