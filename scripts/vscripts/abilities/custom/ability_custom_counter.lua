ability_custom_counter = ability_custom_counter or class({})

function ability_custom_counter:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        if IsNull(caster) then return end
        local modifierParams = {
            duration = self:GetSpecialValueFor("duration"),
            chance = self:GetSpecialValueFor("chance"),
            damage = self:GetSpecialValueFor("damage"),
        }
        caster:AddNewModifier(caster, nil, "modifier_ability_custom_counter", modifierParams)
    end
end

LinkLuaModifier("modifier_ability_custom_counter", "abilities/custom/ability_custom_counter", LUA_MODIFIER_MOTION_NONE)

modifier_ability_custom_counter = class({})

function modifier_ability_custom_counter:IsHidden() return false end
function modifier_ability_custom_counter:IsDebuff() return false end
function modifier_ability_custom_counter:IsPurgable() return false end
function modifier_ability_custom_counter:RemoveOnDeath() return true end

function modifier_ability_custom_counter:GetTexture()
    return "ability_custom_counter"
end

function modifier_ability_custom_counter:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACKED,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_ability_custom_counter:OnAttacked(keys)
    if not IsServer() then return end
    local target = keys.target
    local parent = self:GetParent()
    local attacker = keys.attacker
    if IsNull(target) or IsNull(parent) or IsNull(attacker) then return end
	if target == parent and RollPercentage(self.chance) then
        self:TakeEffect()
	end
end


function modifier_ability_custom_counter:OnAttackLanded(keys)
    if not IsServer() then return end
    local attacker = keys.attacker
    local target = keys.target
    local parent = self:GetParent()
    if IsNull(attacker) or IsNull(target) or IsNull(parent) then return end

    if attacker == parent and parent:HasModifier("modifier_counterxinfa") and RollPercentage(self.chance) then
        self:TakeEffect()
    end
end

function modifier_ability_custom_counter:OnCreated(params)
    if IsServer() then
        self.damage = params.damage
        self.chance = params.chance
    end
end

function modifier_ability_custom_counter:TakeEffect()
    local parent = self:GetParent()
    if IsNull(parent) then return end
    local particle = ParticleManager:CreateParticle("particles/econ/items/axe/axe_weapon_bloodchaser/axe_attack_blur_counterhelix_bloodchaser.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
    ParticleManager:SetParticleControl(particle, 0, parent:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)
    local enemies = FindUnitsInRadius(
        parent:GetTeamNumber(),
        parent:GetAbsOrigin(),
        nil,
        500,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS,
        FIND_ANY_ORDER,
        false)
    for _, enemy in pairs(enemies) do
        if NotNull(enemy) then 
            ApplyDamage({
                victim = enemy,
                attacker = parent,
                damage = self.damage,
                damage_type = DAMAGE_TYPE_PURE,
            })
        end
    end
end