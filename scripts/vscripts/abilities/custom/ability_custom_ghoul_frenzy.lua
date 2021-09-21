ability_custom_ghoul_frenzy = ability_custom_ghoul_frenzy or class({})

LinkLuaModifier("modifier_ability_custom_ghoul_frenzy_buff", "abilities/custom/ability_custom_ghoul_frenzy", LUA_MODIFIER_MOTION_NONE)

function ability_custom_ghoul_frenzy:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
    local modifierParams = {
        trigger_health_pct = self:GetSpecialValueFor("trigger_health_pct"),
        extra_damage_pct = self:GetSpecialValueFor("extra_damage_pct"),
        duration = self:GetSpecialValueFor("duration"),
    }
    caster:AddNewModifier(caster, nil, "modifier_ability_custom_ghoul_frenzy_buff", modifierParams)

end

modifier_ability_custom_ghoul_frenzy_buff = modifier_ability_custom_ghoul_frenzy_buff or class({})

function modifier_ability_custom_ghoul_frenzy_buff:IsHidden() return false end
function modifier_ability_custom_ghoul_frenzy_buff:IsDebuff() return false end
function modifier_ability_custom_ghoul_frenzy_buff:IsPurgable() return false end
function modifier_ability_custom_ghoul_frenzy_buff:RemoveOnDeath() return true end

function modifier_ability_custom_ghoul_frenzy_buff:GetTexture()
    return "ability_custom_ghoul_frenzy"
end

function modifier_ability_custom_ghoul_frenzy_buff:GetEffectName()
    return "particles/units/heroes/hero_lone_druid/lone_druid_battle_cry_overhead.vpcf"
end

function modifier_ability_custom_ghoul_frenzy_buff:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_ability_custom_ghoul_frenzy_buff:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_ability_custom_ghoul_frenzy_buff:OnCreated(params)
    if not IsServer() then return end
    local parent = self:GetParent()
    if IsNull(parent) then return end
    self.trigger_health_pct = params.trigger_health_pct
    self.extra_damage_pct = params.extra_damage_pct
end

function modifier_ability_custom_ghoul_frenzy_buff:OnAttackLanded(keys)
    if not IsServer() then return end
    local attacker = keys.attacker
    local target = keys.target
    local parent = self:GetParent()
    if IsNull(attacker) or IsNull(target) or IsNull(parent) then return end
    if parent ~= attacker then return end
    local damage = keys.damage * (1 - target:GetHealthPercent() / 100)
    local damageTable = {
        victim = target,
        attacker = attacker,
        damage = damage,
        damage_type = DAMAGE_TYPE_PHYSICAL,
    }
    ApplyDamage(damageTable)

    if target:GetHealthPercent() <= self.trigger_health_pct then
        ApplyDamage({
            victim = target,
            attacker = attacker,
            damage = damage * self.extra_damage_pct / 100,
            damage_type = DAMAGE_TYPE_PURE,
        })
    end
end

