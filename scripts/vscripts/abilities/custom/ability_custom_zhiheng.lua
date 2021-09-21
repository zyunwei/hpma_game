ability_custom_zhiheng = ability_custom_zhiheng or class({})

function ability_custom_zhiheng:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
    local modifierParams = {
        duration = self:GetSpecialValueFor("duration"),
        damage_rate = self:GetSpecialValueFor("damage_rate"),
        base_damage = self:GetSpecialValueFor("base_damage"),
        damgeType = self:GetAbilityDamageType(),
    }
    caster:AddNewModifier(caster, nil, "modifier_ability_custom_zhiheng_buff", modifierParams)

    local sound_cast = "Hero_NyxAssassin.SpikedCarapace"
    EmitSoundOn(sound_cast, caster)
end

LinkLuaModifier("modifier_ability_custom_zhiheng_buff", "abilities/custom/ability_custom_zhiheng", LUA_MODIFIER_MOTION_NONE)

modifier_ability_custom_zhiheng_buff = modifier_ability_custom_zhiheng_buff or class({})

function modifier_ability_custom_zhiheng_buff:IsHidden() return false end
function modifier_ability_custom_zhiheng_buff:IsDebuff() return false end
function modifier_ability_custom_zhiheng_buff:IsPurgable() return false end
function modifier_ability_custom_zhiheng_buff:RemoveOnDeath() return true end

function modifier_ability_custom_zhiheng_buff:GetTexture()
    return "ability_custom_zhiheng"
end

function modifier_ability_custom_zhiheng_buff:GetEffectName()
    return "particles/econ/items/nyx_assassin/nyx_ti9_immortal/nyx_ti9_carapace.vpcf"
end

function modifier_ability_custom_zhiheng_buff:GetEffectAttachType()
    return PATTACH_CENTER_FOLLOW
end

function modifier_ability_custom_zhiheng_buff:OnCreated(params)
    self.damage_rate = params.damage_rate or 150
    self.base_damage = params.base_damage or 50
end

function modifier_ability_custom_zhiheng_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ATTACKED,
    }
end

function modifier_ability_custom_zhiheng_buff:OnAttackLanded(keys)
    if not IsServer() then return end

    local parent = self:GetParent()
    if IsNull(keys.target) or IsNull(parent) or IsNull(keys.attacker) then return end

    if keys.attacker ~= self:GetParent() or keys.target:IsBuilding() or keys.target:IsOther() then
        return
    end

    local damage = self:CalculateDamage(parent, keys.target)

    ApplyDamage({attacker = parent, victim = keys.target, damage_type = DAMAGE_TYPE_MAGICAL, damage = damage})
end

function modifier_ability_custom_zhiheng_buff:OnAttacked(keys)
    if not IsServer() then return end

    local parent = self:GetParent()
    if IsNull(keys.target) or IsNull(parent) or IsNull(keys.attacker) then return end

    if keys.target ~= self:GetParent() then
        return
    end

    local damage = self:CalculateDamage(parent, keys.attacker)

    ApplyDamage({attacker = parent, victim = keys.attacker, damage_type = DAMAGE_TYPE_MAGICAL, damage = damage})
end

function modifier_ability_custom_zhiheng_buff:CalculateDamage(me, enemy)
    local damage = self.base_damage

    if enemy:IsHero() then
        local delta = enemy:GetMaxHealth() - me:GetMaxHealth()
        if delta > 0 then
            damage = delta * self.damage_rate * 0.01
        end
    end

    local affixAttr = self:GetCaster():GetCustomAttribute("zhiheng")
    if affixAttr and affixAttr > 0 then
        damage = damage * (1 + affixAttr * 0.01)
    end

    return damage
end

function modifier_ability_custom_zhiheng_buff:OnTooltip()
    return self.damage_rate
end
