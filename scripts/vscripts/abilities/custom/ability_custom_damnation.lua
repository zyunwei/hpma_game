ability_custom_damnation = ability_custom_damnation or class({})

function ability_custom_damnation:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        if IsNull(caster) then return end
        local modifierParams = {
            duration = self:GetSpecialValueFor("duration"),
            bonus_magic_damage = self:GetSpecialValueFor("bonus_magic_damage"),
            bonus_spell_amp = self:GetSpecialValueFor("bonus_spell_amp"),
        }
        caster:AddNewModifier(caster, nil, "modifier_ability_custom_damnation", modifierParams)
    end
end

LinkLuaModifier("modifier_ability_custom_damnation", "abilities/custom/ability_custom_damnation", LUA_MODIFIER_MOTION_NONE)

modifier_ability_custom_damnation = class({})

function modifier_ability_custom_damnation:IsHidden() return false end
function modifier_ability_custom_damnation:IsDebuff() return false end
function modifier_ability_custom_damnation:IsPurgable() return false end
function modifier_ability_custom_damnation:RemoveOnDeath() return true end

function modifier_ability_custom_damnation:GetTexture()
    return "ability_custom_damnation"
end

function modifier_ability_custom_damnation:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    }
end

function modifier_ability_custom_damnation:OnCreated(params)
    if IsServer() then
        self.last_kill_time = GameManager:GetGameTime()
        self.bonus_magic_damage = params.bonus_magic_damage
        self.bonus_spell_amp = params.bonus_spell_amp
        self.interval = 5
        self.is_active = false
        self:StartIntervalThink(1)
    end
end

function modifier_ability_custom_damnation:OnIntervalThink()
    local pastTime = GameManager:GetGameTime() - self.last_kill_time
    if pastTime >= self.interval then
        self.is_active = true
    else
        self.is_active = false
    end
end


function modifier_ability_custom_damnation:OnDeath(keys)
    if not IsServer() then return end
    local attacker = keys.attacker
    local caster = self:GetCaster()
    local unit = keys.unit
    if IsNull(attacker) or IsNull(caster) or IsNull(unit) then return end
    if attacker == caster and not unit:IsHero() then
        self.last_kill_time = GameManager:GetGameTime()
    end
end

function modifier_ability_custom_damnation:OnAttackLanded(keys)
    if not IsServer() then return end
    if not self.is_active then return end
    local attacker = keys.attacker
    local target = keys.target
    local parent = self:GetParent()
    if IsNull(attacker) or IsNull(target) or IsNull(parent) then return end

    if attacker ~= parent then return end

    local damage = self.bonus_magic_damage
    local damageTable = {
        victim = target,
        attacker = attacker,
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
    }
    ApplyDamage(damageTable)
end

function modifier_ability_custom_damnation:GetModifierSpellAmplify_Percentage()
    if self.is_active then
        return self.bonus_spell_amp
    end
end
