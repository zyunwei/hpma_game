custom_ability_necromastery = custom_ability_necromastery or class({})

LinkLuaModifier("modifier_custom_ability_necromastery", "abilities/hpma/custom_ability_necromastery", LUA_MODIFIER_MOTION_NONE)

function custom_ability_necromastery:GetIntrinsicModifierName()
    return "modifier_custom_ability_necromastery"
end

modifier_custom_ability_necromastery = class({})

function modifier_custom_ability_necromastery:IsHidden()		return false end
function modifier_custom_ability_necromastery:IsPurgable()		return false end
function modifier_custom_ability_necromastery:RemoveOnDeath()	return false end
function modifier_custom_ability_necromastery:GetTexture() 
    return "custom_ability_necromastery"
end

function modifier_custom_ability_necromastery:OnCreated()
    self.max_stack_count = 12
    self.bonus_damage = 5
    self.bonus_health = 10
    self.bonus_model_scale = 20
    self.target_count = 2
end

function modifier_custom_ability_necromastery:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MODEL_SCALE,
        MODIFIER_EVENT_ON_ATTACK
    }
end

function modifier_custom_ability_necromastery:OnDeath(keys)
    if self:GetStackCount() < self.max_stack_count then
        self:IncrementStackCount()
    end
end

function modifier_custom_ability_necromastery:GetModifierPreAttack_BonusDamage()
    return self:GetStackCount() * self.bonus_damage
end

function modifier_custom_ability_necromastery:GetModifierHealthBonus()
    return self:GetStackCount() * self.bonus_health
end

function modifier_custom_ability_necromastery:GetModifierModelScale()
    return self:GetStackCount() * self.bonus_model_scale
end

function modifier_custom_ability_necromastery:OnAttack(keys)
    if not IsServer() then return end
    if self:GetStackCount() < self.max_stack_count then return end
    local attacker = keys.attacker
    local target = keys.target
    local parent = self:GetParent()
    if IsNull(attacker) or IsNull(target) or IsNull(parent) then return end

    if attacker ~= parent then return end

    if target:GetTeamNumber() ~= parent:GetTeamNumber() and not keys.no_attack_cooldown then
        local target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP
        local target_team =  DOTA_UNIT_TARGET_TEAM_ENEMY
        local target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE

        local targetCount = 1
        local enemies = FindUnitsInRadius(parent:GetTeam(), parent:GetAbsOrigin(), nil, parent:Script_GetAttackRange(), target_team, target_type, target_flags, FIND_CLOSEST, false)

        for _, enemy in pairs(enemies) do
            if NotNull(enemy) and enemy ~= target then 
                parent:PerformAttack(enemy, false, false, true, true, true, false, false)
                targetCount = targetCount + 1
                if targetCount >= self.target_count then break end
            end
        end
    end
end