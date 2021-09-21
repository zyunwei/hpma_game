ability_custom_anger = ability_custom_anger or class({})

function ability_custom_anger:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        if IsNull(caster) then return end
        local modifierParams = {
            duration = self:GetSpecialValueFor("duration"),
            bonus_attack_speed_per_anger = self:GetSpecialValueFor("bonus_attack_speed_per_anger"),
            damage = self:GetSpecialValueFor("damage"),
        }
        caster:AddNewModifier(caster, nil, "modifier_ability_custom_anger", modifierParams)
    end
end

LinkLuaModifier("modifier_ability_custom_anger", "abilities/custom/ability_custom_anger", LUA_MODIFIER_MOTION_NONE)

modifier_ability_custom_anger = class({})

function modifier_ability_custom_anger:IsHidden() return false end
function modifier_ability_custom_anger:IsDebuff() return false end
function modifier_ability_custom_anger:IsPurgable() return false end
function modifier_ability_custom_anger:RemoveOnDeath() return true end

function modifier_ability_custom_anger:GetTexture()
    return "ability_custom_anger"
end

function modifier_ability_custom_anger:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACKED,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
end

function modifier_ability_custom_anger:OnAttacked(keys)
    if not IsServer() then return end
    local target = keys.target
    local parent = self:GetParent()
    local attacker = keys.attacker
    if IsNull(target) or IsNull(parent) or IsNull(attacker) then return end
	if target == parent then
        self.last_attack_time = GameManager:GetGameTime()
        self.anger = self.anger + 5
        self:SetStackCount(self.anger)
	end
end

function modifier_ability_custom_anger:OnAttackLanded(keys)
    if not IsServer() then return end
    local attacker = keys.attacker
    local target = keys.target
    local parent = self:GetParent()
    if IsNull(attacker) or IsNull(target) or IsNull(parent) then return end
    if attacker == parent then
        self.last_attack_time = GameManager:GetGameTime()
        self.anger = self.anger + 5
        self:SetStackCount(self.anger)
    end
end

function modifier_ability_custom_anger:OnCreated(params)
    if IsServer() then
        self.damage = params.damage
        self.bonus_attack_speed_per_anger = params.bonus_attack_speed_per_anger
        self.last_attack_time = 0
        self.radius = 800
        self.anger = 0
        self:StartIntervalThink(0.5)
    end
end

function modifier_ability_custom_anger:OnIntervalThink()
    local parent = self:GetParent()
    if IsNull(parent) then return end
    local pastTime = GameManager:GetGameTime() - self.last_attack_time
    if pastTime >= 2 then
        self.anger = self.anger - 1
        if self.anger <= 0 then
            self.anger = 0
        end
        self:SetStackCount(self.anger)
    end
    if self.anger >= 100 then
        local nearby_enemies = FindUnitsInRadius(parent:GetTeamNumber(), parent:GetAbsOrigin(), 
        nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES, FIND_ANY_ORDER, false)
        for _, enemy in pairs(nearby_enemies) do
            if NotNull(enemy) then
                local damage = self.damage / 5
                ApplyDamage({victim = enemy, attacker = parent, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
            end
        end
    end
end

function modifier_ability_custom_anger:GetModifierAttackSpeedBonus_Constant()
    if IsServer() then
        local bonus_attack_speed = self.anger * self.bonus_attack_speed_per_anger
        if self.anger >= 100 then
            bonus_attack_speed = bonus_attack_speed * 2
        end
        return bonus_attack_speed
    end
end

function modifier_ability_custom_anger:OnStackCountChanged(oldCount)
    if not IsServer() then return end
    local parent = self:GetParent()
    if IsNull(parent) then return end
    if self:GetStackCount() >= 100 then
        if self.particleIndex == nil then
            self.particleIndex = ParticleManager:CreateParticle("particles/econ/events/spring_2021/radiance_owner_spring_2021.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
            ParticleManager:SetParticleControl(self.particleIndex, 0, parent:GetAbsOrigin())
            self:AddParticle(self.particleIndex, false, false, -1, false, false)
        end
    elseif self.particleIndex then
        ParticleManager:DestroyParticle(self.particleIndex, true)
        self.particleIndex = nil
    end
end