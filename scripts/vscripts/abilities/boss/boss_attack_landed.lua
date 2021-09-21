boss_attack_landed = boss_attack_landed or class({})

function boss_attack_landed:GetIntrinsicModifierName() return "modifier_boss_attack_landed" end

LinkLuaModifier("modifier_boss_attack_landed", "abilities/boss/boss_attack_landed", LUA_MODIFIER_MOTION_NONE)

modifier_boss_attack_landed = class({})

function modifier_boss_attack_landed:IsHidden() return true end
function modifier_boss_attack_landed:IsDebuff() return false end
function modifier_boss_attack_landed:IsPurgable() return false end
function modifier_boss_attack_landed:RemoveOnDeath() return true end

function modifier_boss_attack_landed:OnCreated()
    if IsServer() then
        local ability = self:GetAbility()
        if NotNull(ability) then
            self.max_health_damage_pct = ability:GetSpecialValueFor("max_health_damage_pct")
        end
    end
end

function modifier_boss_attack_landed:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_boss_attack_landed:OnAttackLanded(keys)
    if not IsServer() then return end
    local attacker = keys.attacker
    local target = keys.target
    local parent = self:GetParent()
    if IsNull(attacker) or IsNull(target) or IsNull(parent) then return end

    if attacker ~= parent then return end

    local damage = target:GetMaxHealth() * self.max_health_damage_pct / 100
    local damageTable = {
        victim = target,
        attacker = attacker,
        damage = damage,
        damage_type = DAMAGE_TYPE_PURE,
    }
    ApplyDamage(damageTable)
end