ability_custom_burn_around = ability_custom_burn_around or class({})

LinkLuaModifier("modifier_ability_custom_burn_around", "abilities/custom/ability_custom_burn_around", LUA_MODIFIER_MOTION_HORIZONTAL)

LinkLuaModifier("modifier_ability_custom_burn_around_debuff", "abilities/custom/ability_custom_burn_around", LUA_MODIFIER_MOTION_HORIZONTAL)

function ability_custom_burn_around:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if IsNull(caster)  then return end

    local modifierName = "modifier_ability_custom_burn_around"

	if caster:HasModifier(modifierName) then
		caster:RemoveModifierByName(modifierName)
	end

	local modifierParams = {
		duration = self:GetSpecialValueFor("duration"),
        radius = self:GetSpecialValueFor("radius"),
        damage = caster:GetIntellect() * self:GetSpecialValueFor("int_damage_multiple"),
        bonus_damage_pct = self:GetSpecialValueFor("bonus_damage_pct"),
	}

    local modifier = caster:FindModifierByName("modifier_xianjixinfa")
    if NotNull(modifier) then
        modifierParams.radius = modifierParams.radius + modifier:GetBonusRadius()
    end

    local affixAttr = self:GetCaster():GetCustomAttribute("flame")
    if affixAttr and affixAttr > 0 then
        modifierParams.damage = modifierParams.damage * (1 + affixAttr * 0.01)
    end

	caster:AddNewModifier(caster, self, modifierName, modifierParams)

    caster:EmitSound("Hero_EmberSpirit.FlameGuard.Cast")
    caster:EmitSound("Hero_EmberSpirit.FlameGuard.Loop")
end

modifier_ability_custom_burn_around = class({})
function modifier_ability_custom_burn_around:IsHidden() return false end
function modifier_ability_custom_burn_around:IsDebuff() return false end
function modifier_ability_custom_burn_around:IsPurgable() return false end
function modifier_ability_custom_burn_around:RemoveOnDeath() return true end
function modifier_ability_custom_burn_around:GetTexture()
    return "ability_custom_burn_around"
end

function modifier_ability_custom_burn_around:IsAura()
    return true
end

function modifier_ability_custom_burn_around:GetEffectName()
    return "particles/units/heroes/hero_ember_spirit/ember_spirit_flameguard.vpcf"
end

function modifier_ability_custom_burn_around:GetModifierAura()
	return "modifier_ability_custom_burn_around_debuff"
end

function modifier_ability_custom_burn_around:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_ability_custom_burn_around:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP
end

function modifier_ability_custom_burn_around:GetAuraRadius()
	return self.radius
end

function modifier_ability_custom_burn_around:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_ability_custom_burn_around:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_ability_custom_burn_around:OnCreated(params)
    if not IsServer() then return end

    self.radius = params.radius
end

function modifier_ability_custom_burn_around:OnDestroy()
    if IsServer() then
        if IsNull(self:GetParent()) then return end
        self:GetParent():StopSound("Hero_EmberSpirit.FlameGuard.Loop")
    end
end

modifier_ability_custom_burn_around_debuff = class({})

function modifier_ability_custom_burn_around_debuff:IsHidden() return false end
function modifier_ability_custom_burn_around_debuff:IsDebuff() return true end
function modifier_ability_custom_burn_around_debuff:IsPurgable() return false end
function modifier_ability_custom_burn_around_debuff:RemoveOnDeath() return true end
function modifier_ability_custom_burn_around_debuff:GetTexture()
    return "ability_custom_burn_around"
end

function modifier_ability_custom_burn_around_debuff:OnCreated()
    if IsServer() then
        self:StartIntervalThink(0.2)
    end
end

function modifier_ability_custom_burn_around_debuff:OnIntervalThink()
    local parent = self:GetParent()
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    if IsNull(parent) or IsNull(caster) or IsNull(ability) then
        return
    end

    if parent:IsMagicImmune() then
        return
    end

    local damage = caster:GetIntellect() * ability:GetSpecialValueFor("int_damage_multiple")
    damage = damage * 0.2
    local affixAttr = caster:GetCustomAttribute("flame")
    if affixAttr and affixAttr > 0 then
        damage = damage * (1 + affixAttr * 0.01)
    end
    if parent.IsRealHero == nil or not parent:IsRealHero() then
        damage = damage * (1 + ability:GetSpecialValueFor("bonus_damage_pct") / 100)
    end
    ApplyDamage({victim = parent, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})

end