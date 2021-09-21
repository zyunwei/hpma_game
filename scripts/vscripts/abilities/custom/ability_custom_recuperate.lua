ability_custom_recuperate = ability_custom_recuperate or class({})

LinkLuaModifier("modifier_ability_custom_recuperate_buff", "abilities/custom/ability_custom_recuperate", LUA_MODIFIER_MOTION_NONE)

function ability_custom_recuperate:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
    local modifierParams = {
        health_regen_pct = self:GetSpecialValueFor("health_regen_pct"),
        mana_regen_pct = self:GetSpecialValueFor("mana_regen_pct"),
        duration = self:GetSpecialValueFor("duration"),
    }
    caster:AddNewModifier(caster, nil, "modifier_ability_custom_recuperate_buff", modifierParams)
end

modifier_ability_custom_recuperate_buff = modifier_ability_custom_recuperate_buff or class({})

function modifier_ability_custom_recuperate_buff:IsHidden() return false end
function modifier_ability_custom_recuperate_buff:IsDebuff() return false end
function modifier_ability_custom_recuperate_buff:IsPurgable() return false end
function modifier_ability_custom_recuperate_buff:RemoveOnDeath() return true end

function modifier_ability_custom_recuperate_buff:GetTexture()
    return "ability_custom_recuperate"
end

function modifier_ability_custom_recuperate_buff:OnCreated(params)
    if not IsServer() then return end
    local parent = self:GetParent()
    if IsNull(parent) then return end
    self.health_regen_pct = params.health_regen_pct or 3
    self.mana_regen_pct = params.mana_regen_pct or 3
    self.in_fight = false
    self.start_time = GameRules:GetGameTime()
    self:StartIntervalThink(1)
end

function modifier_ability_custom_recuperate_buff:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
        MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE,
    }
end

function modifier_ability_custom_recuperate_buff:GetModifierHealthRegenPercentage()
    if self.in_fight then
        return self.health_regen_pct / 2
    else
        return self.health_regen_pct
    end
end

function modifier_ability_custom_recuperate_buff:GetModifierTotalPercentageManaRegen()
    if self.in_fight then
        return self.mana_regen_pct / 2
    else
        return self.mana_regen_pct
    end
end

function modifier_ability_custom_recuperate_buff:OnTakeDamage(keys)
    local parent = self:GetParent()
    local attacker = keys.attacker
    local target = keys.unit
    if IsNull(parent) or IsNull(attacker) or IsNull(target) then return end
    if parent == target or parent == attacker then
        self.in_fight = true
        self.start_time = GameRules:GetGameTime()
    end
end

function modifier_ability_custom_recuperate_buff:OnIntervalThink()
    local pastTime = GameRules:GetGameTime() - self.start_time
    if pastTime >= 3 then
        self.in_fight = false
    end
    local parent = self:GetParent()
    if IsNull(parent) then return end
    if parent:HasModifier("modifier_yangjingxuruixinfa") then
        if parent:GetHealthPercent() == 100 then
            parent:ModifyCustomAttribute("hp", "ability_custom_recuperate", parent:GetMaxHealth() * 0.001)
        end
        if parent:GetManaPercent() == 100 then
            parent:ModifyCustomAttribute("mana", "ability_custom_recuperate", parent:GetMaxMana() * 0.001)
        end
    end
end