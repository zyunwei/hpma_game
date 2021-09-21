ability_custom_root_attack = ability_custom_root_attack or class({})
LinkLuaModifier("modifier_ability_custom_root_attack", "abilities/custom/ability_custom_root_attack", LUA_MODIFIER_MOTION_NONE)

function ability_custom_root_attack:OnAbilityPhaseStart()
	return self:CheckPhaseStart()
end

function ability_custom_root_attack:OnSpellStart()
	return self:CheckSpellStart()
end

function ability_custom_root_attack:CastAbilityTarget(target)
	local caster = self:GetCaster()
    if IsNull(caster) or IsNull(target) then return end

    local resistance = target:GetStatusResistance()
    local modifierParams = {
        duration = self:GetSpecialValueFor("duration") * (1 - resistance),
        tick_interval = self:GetSpecialValueFor("tick_interval"),
        tick_damage = caster:GetAttackDamage() * self:GetSpecialValueFor("damage_multipler"),
        attacker = caster
    }

    caster:EmitSound("Hero_Treant.NaturesGrasp.Cast")
    target:EmitSound("Hero_Treant.NaturesGrasp.Spawn")

    target:AddNewModifier(caster, nil, "modifier_ability_custom_root_attack", modifierParams)
end

modifier_ability_custom_root_attack = class({})

function modifier_ability_custom_root_attack:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_INVISIBLE] = false
	}
end

function modifier_ability_custom_root_attack:IsHidden() return false end
function modifier_ability_custom_root_attack:IsDebuff() return true end
function modifier_ability_custom_root_attack:IsPurgable() return true end
function modifier_ability_custom_root_attack:RemoveOnDeath() return true end
function modifier_ability_custom_root_attack:GetTexture()
    return "ability_custom_root_attack"
end

function modifier_ability_custom_root_attack:GetEffectName()
    return "particles/units/heroes/hero_treant/treant_bramble_root.vpcf"
end

function modifier_ability_custom_root_attack:GetEffectAttachType()
    return PATTACH_CUSTOMORIGIN_FOLLOW
end

function modifier_ability_custom_root_attack:OnCreated(params)
    if IsServer() then
		self.attacker = params.attacker
		self.tick_damage = params.tick_damage

		self:OnIntervalThink()
		self:StartIntervalThink(params.tick_interval)
    end
end

function modifier_ability_custom_root_attack:OnIntervalThink()
	if not IsServer() then return end
	if IsNull(self.attacker) or IsNull(self:GetParent()) then return end

	local damageTable = {
		victim = self:GetParent(),
		attacker = self.attacker,
		damage = self.tick_damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = nil
	}

	ApplyDamage(damageTable)
end
