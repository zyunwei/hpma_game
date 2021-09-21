ability_custom_bloodrage = ability_custom_bloodrage or class({})

function ability_custom_bloodrage:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        if IsNull(caster) then return end
        local modifierParams = {
            max_health_damage_pct = self:GetSpecialValueFor("max_health_damage_pct"),
            duration = self:GetSpecialValueFor("duration")
        }
        EmitSoundOn("hero_bloodseeker.bloodRage", caster)

        caster:AddNewModifier(caster, nil, "modifier_bloodrage", modifierParams)
    end
end

LinkLuaModifier("modifier_bloodrage", "abilities/custom/ability_custom_bloodrage", LUA_MODIFIER_MOTION_NONE)

modifier_bloodrage = class({})

function modifier_bloodrage:IsHidden() return false end
function modifier_bloodrage:IsDebuff() return false end
function modifier_bloodrage:IsPurgable() return false end
function modifier_bloodrage:RemoveOnDeath() return true end

function modifier_bloodrage:GetTexture()
    return "ability_custom_bloodrage"
end

function modifier_bloodrage:GetEffectName()
	return "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodrage.vpcf"
end

function modifier_bloodrage:GetStatusEffectName()
	return "particles/status_fx/status_effect_bloodrage.vpcf"
end

function modifier_bloodrage:StatusEffectPriority()
	return 8
end

function modifier_bloodrage:OnCreated(params)
    if IsServer() then
         self.max_health_damage_pct = params.max_health_damage_pct or 2
    end
end

function modifier_bloodrage:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_bloodrage:OnAttackLanded(keys)
    if not IsServer() then return end
    local attacker = keys.attacker
    local target = keys.target
    local parent = self:GetParent()
    if IsNull(attacker) or IsNull(target) or IsNull(parent) then return end

    if attacker ~= parent then return end
    if table.containsKey(BossConfigTable, target:GetUnitName()) then return end
    local damage = target:GetMaxHealth() * self.max_health_damage_pct / 100

    local damageTable = {
        victim = target,
        attacker = attacker,
        damage = damage,
        damage_type = DAMAGE_TYPE_PURE,
    }
    ApplyDamage(damageTable)
    parent:Heal(damage, nil)
    SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, parent, damage, nil)
end