ability_custom_overgrowth = ability_custom_overgrowth or class({})

LinkLuaModifier("modifier_ability_custom_overgrowth_debuff", "abilities/custom/ability_custom_overgrowth", LUA_MODIFIER_MOTION_NONE)

function ability_custom_overgrowth:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end

    caster:EmitSound("Hero_Treant.Overgrowth.Cast")

	local cast_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_treant/treant_overgrowth_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(cast_particle)

    local target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
    local target_team =  DOTA_UNIT_TARGET_TEAM_ENEMY
    local target_flags = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE
    local enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 1000, target_team, target_type, target_flags, FIND_ANY_ORDER, false)
    for _, enemy in pairs(enemies) do
        if NotNull(enemy) then 
            local modifierParams = {
                duration = self:GetSpecialValueFor("duration") * (1 - enemy:GetStatusResistance()),
                damage = self:GetSpecialValueFor("damage"),
            }
            enemy:AddNewModifier(caster, nil, "modifier_ability_custom_overgrowth_debuff", modifierParams)
        end
    end

end

modifier_ability_custom_overgrowth_debuff = modifier_ability_custom_overgrowth_debuff or class({})

function modifier_ability_custom_overgrowth_debuff:IsHidden() return false end
function modifier_ability_custom_overgrowth_debuff:IsDebuff() return false end
function modifier_ability_custom_overgrowth_debuff:IsPurgable() return false end
function modifier_ability_custom_overgrowth_debuff:RemoveOnDeath() return true end

function modifier_ability_custom_overgrowth_debuff:GetEffectName()
    return "particles/units/heroes/hero_treant/treant_overgrowth_vines.vpcf"
end

function modifier_ability_custom_overgrowth_debuff:GetTexture()
    return "ability_custom_overgrowth"
end

function modifier_ability_custom_overgrowth_debuff:OnCreated(params)
    if not IsServer() then return end
    local parent = self:GetParent()
    if IsNull(parent) then return end
    self.damage = params.damage or 50
    self:StartIntervalThink(0.5 * (1 - parent:GetStatusResistance()))
end

function modifier_ability_custom_overgrowth_debuff:OnIntervalThink()
    local parent = self:GetParent()
    local caster = self:GetCaster()
    if IsNull(parent) or IsNull(caster) then return end
	ApplyDamage({
		victim 			= parent,
		damage 			= self.damage,
		damage_type		= DAMAGE_TYPE_MAGICAL,
		attacker 		= caster,
	})
end

function modifier_ability_custom_overgrowth_debuff:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_INVISIBLE] = false
	}
end