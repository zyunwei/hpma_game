ability_custom_chaos_attack = ability_custom_chaos_attack or class({})

function ability_custom_chaos_attack:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        if IsNull(caster) then return end
        local modifierParams = {
            target_count = self:GetSpecialValueFor("target_count"),
            duration = self:GetSpecialValueFor("duration")
        }

        caster:AddNewModifier(caster, nil, "modifier_ability_custom_chaos_attack", modifierParams)
        caster:ModifyCustomAttribute("attack_speed", "ability_custom_chaos_attack", self:GetSpecialValueFor("bonus_attack_speed"))
    end
end

LinkLuaModifier("modifier_ability_custom_chaos_attack", "abilities/custom/ability_custom_chaos_attack", LUA_MODIFIER_MOTION_NONE)

modifier_ability_custom_chaos_attack = class({})

function modifier_ability_custom_chaos_attack:IsHidden() return false end
function modifier_ability_custom_chaos_attack:IsDebuff() return false end
function modifier_ability_custom_chaos_attack:IsPurgable() return false end
function modifier_ability_custom_chaos_attack:RemoveOnDeath() return true end

function modifier_ability_custom_chaos_attack:GetTexture()
    return "ability_custom_chaos_attack"
end

function modifier_ability_custom_chaos_attack:GetEffectName()
	return "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodrage.vpcf"
end

function modifier_ability_custom_chaos_attack:OnCreated(params)
    if IsServer() then
         self.target_count = params.target_count or 5
    end
end

function modifier_ability_custom_chaos_attack:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK,
    }
end

function modifier_ability_custom_chaos_attack:OnAttack(keys)
    if not IsServer() then return end
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