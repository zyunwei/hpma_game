ability_custom_acid_spray = ability_custom_acid_spray or class({})

LinkLuaModifier("modifier_acid_spray", "abilities/hpma/ability_custom_acid_spray", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_acid_spray_debuff", "abilities/hpma/ability_custom_acid_spray", LUA_MODIFIER_MOTION_NONE)


function ability_custom_acid_spray:OnAbilityPhaseStart()
    return self:CheckPhaseStartWithMessage()
end

function ability_custom_acid_spray:GetAOERadius()
	return 500
end

function ability_custom_acid_spray:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
	local ability = self
    local target_point = caster:GetCursorPosition()
	if ability:CostCrystal() then
        CreateModifierThinker(caster, self, "modifier_acid_spray", {duration = 6, radius = 500}, target_point, caster:GetTeamNumber(), false)
	end
end


modifier_acid_spray = class({})

function modifier_acid_spray:IsAura()
	return true
end

function modifier_acid_spray:GetAuraRadius()
	return 500
end

function modifier_acid_spray:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_acid_spray:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP
end

function modifier_acid_spray:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_acid_spray:GetModifierAura()
	return "modifier_acid_spray_debuff"
end

function modifier_acid_spray:OnCreated(params)
	if not IsServer() then return end
    self.radius = params.radius

    self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_alchemist/alchemist_acid_spray.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.particle, 0, (Vector(0, 0, 0)))
    ParticleManager:SetParticleControl(self.particle, 1, (Vector(self.radius, 1, 1)))
    ParticleManager:SetParticleControl(self.particle, 15, (Vector(25, 150, 25)))
    ParticleManager:SetParticleControl(self.particle, 16, (Vector(0, 0, 0)))
    self:AddParticle(self.particle, false, false, -1, false, false)
end

modifier_acid_spray_debuff = class({})

function modifier_acid_spray_debuff:IsPurgable() return false end
function modifier_acid_spray_debuff:IsHidden() return false end
function modifier_acid_spray_debuff:IsDebuff() return true end

function modifier_acid_spray_debuff:GetTexture()
    return "ability_custom_acid_spray"
end

function modifier_acid_spray_debuff:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(1)
end

function modifier_acid_spray_debuff:OnIntervalThink()
    local parent = self:GetParent()
    if IsNull(parent) then return end
    ApplyDamage({
        victim = parent,
        attacker = self:GetCaster(),
        damage = 27,
        damage_type = DAMAGE_TYPE_MAGICAL,
    })

end 
