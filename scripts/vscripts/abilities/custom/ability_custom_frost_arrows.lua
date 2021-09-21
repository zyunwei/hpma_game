ability_custom_frost_arrows = ability_custom_frost_arrows or class({})

LinkLuaModifier("modifier_ability_custom_frost_arrows_buff", "abilities/custom/ability_custom_frost_arrows", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_ability_custom_frost_arrows_debuff", "abilities/custom/ability_custom_frost_arrows", LUA_MODIFIER_MOTION_NONE)

function ability_custom_frost_arrows:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
    local modifierParams = {
        debuff_duration = self:GetSpecialValueFor("debuff_duration"),
        max_stack = self:GetSpecialValueFor("max_stack"),
        damage = self:GetSpecialValueFor("damage"),
        reduce_pct = self:GetSpecialValueFor("reduce_pct"),
        duration = self:GetSpecialValueFor("duration"),
    }
    caster:AddNewModifier(caster, nil, "modifier_ability_custom_frost_arrows_buff", modifierParams)

end

modifier_ability_custom_frost_arrows_buff = modifier_ability_custom_frost_arrows_buff or class({})

function modifier_ability_custom_frost_arrows_buff:IsHidden() return false end
function modifier_ability_custom_frost_arrows_buff:IsDebuff() return false end
function modifier_ability_custom_frost_arrows_buff:IsPurgable() return false end
function modifier_ability_custom_frost_arrows_buff:RemoveOnDeath() return true end

function modifier_ability_custom_frost_arrows_buff:GetTexture()
    return "ability_custom_frost_arrows"
end

function modifier_ability_custom_frost_arrows_buff:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ATTACK_START,
        MODIFIER_EVENT_ON_ATTACK,
    }
end

function modifier_ability_custom_frost_arrows_buff:OnCreated(params)
    if not IsServer() then return end
    local parent = self:GetParent()
    if IsNull(parent) then return end
    self.debuff_duration = params.debuff_duration
    self.max_stack = params.max_stack
    self.damage = params.damage
    self.reduce_pct = params.reduce_pct
end

function modifier_ability_custom_frost_arrows_buff:OnAttackStart(keys)
    if not IsServer() then return end
    local attacker = keys.attacker
    local target = keys.target
    local parent = self:GetParent()
    if IsNull(attacker) or IsNull(target) or IsNull(parent) then return end
    if parent ~= attacker then return end
    attacker:SetRangedProjectileName("particles/units/heroes/hero_drow/drow_marksmanship_frost_arrow.vpcf")
end

function modifier_ability_custom_frost_arrows_buff:OnAttack(keys)
    if not IsServer() then return end
    local attacker = keys.attacker
    local target = keys.target
    local parent = self:GetParent()
    if IsNull(attacker) or IsNull(target) or IsNull(parent) then return end
    if parent ~= attacker then return end
    EmitSoundOn("Hero_DrowRanger.FrostArrows", attacker)
end

function modifier_ability_custom_frost_arrows_buff:OnAttackLanded(keys)
    if not IsServer() then return end
    local attacker = keys.attacker
    local target = keys.target
    local parent = self:GetParent()
    if IsNull(attacker) or IsNull(target) or IsNull(parent) then return end
    if parent ~= attacker then return end
    local modifier = target:FindModifierByName("modifier_ability_custom_frost_arrows_debuff")
    if NotNull(modifier) then
        modifier:IncreaseStackCount()
    else
        local modifierParams = {
            duration = self.debuff_duration,
            damage = self.damage,
            reduce_pct = self.reduce_pct,
            max_stack = self.max_stack,
        }
        target:AddNewModifier(parent, nil, "modifier_ability_custom_frost_arrows_debuff", modifierParams)
    end
end

modifier_ability_custom_frost_arrows_debuff = modifier_ability_custom_frost_arrows_debuff or class({})

function modifier_ability_custom_frost_arrows_debuff:IsHidden() return false end
function modifier_ability_custom_frost_arrows_debuff:IsDebuff() return true end
function modifier_ability_custom_frost_arrows_debuff:IsPurgable() return true end
function modifier_ability_custom_frost_arrows_debuff:RemoveOnDeath() return true end

function modifier_ability_custom_frost_arrows_debuff:GetTexture()
    return "ability_custom_frost_arrows"
end

function modifier_ability_custom_frost_arrows_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_frost_lich.vpcf"
end

function modifier_ability_custom_frost_arrows_debuff:StatusEffectPriority()
	return 10
end

function modifier_ability_custom_frost_arrows_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
    }
end

function modifier_ability_custom_frost_arrows_debuff:OnCreated(params)
    if not IsServer() then return end
    local parent = self:GetParent()
    if IsNull(parent) then return end
    self.max_stack = params.max_stack
    self.damage = params.damage
    self.reduce_pct = params.reduce_pct
    self:SetStackCount(1)
    self:StartIntervalThink(1)
end

function modifier_ability_custom_frost_arrows_debuff:GetModifierHPRegenAmplify_Percentage()
    if IsServer() then
	   return -self.reduce_pct
    end
end

function modifier_ability_custom_frost_arrows_debuff:GetModifierMoveSpeedBonus_Percentage()
    if IsServer() then
	   return -self.reduce_pct
    end
end

function modifier_ability_custom_frost_arrows_debuff:GetModifierLifestealAmplify()
    if IsServer() then
	   return -self.reduce_pct
    end
end

function modifier_ability_custom_frost_arrows_debuff:IncreaseStackCount()
    if self:GetStackCount() < self.max_stack then
        self:IncrementStackCount()
    end
    self:ForceRefresh()
end

function modifier_ability_custom_frost_arrows_debuff:OnIntervalThink()
    local caster = self:GetCaster()
    local parent = self:GetParent()
    if IsNull(caster) or IsNull(parent) then return end
    local damageTable = {
        victim = parent,
        attacker = caster,
        damage = self.damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
    }
    ApplyDamage(damageTable)
end