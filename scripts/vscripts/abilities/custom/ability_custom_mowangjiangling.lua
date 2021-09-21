ability_custom_mowangjiangling = ability_custom_mowangjiangling or class({})

function ability_custom_mowangjiangling:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
    local modifierParams = {
        duration = self:GetSpecialValueFor("duration"),
        armor_reduction = self:GetSpecialValueFor("armor_reduction"),
        debuff_duration = self:GetSpecialValueFor("debuff_duration"),
        radius = self:GetSpecialValueFor("radius"),
    }

    local affixAttr = self:GetCaster():GetCustomAttribute("mowang")
    if affixAttr and affixAttr > 0 then
        modifierParams.duration = modifierParams.duration + affixAttr
        modifierParams.debuff_duration = modifierParams.debuff_duration + affixAttr
    end

    EmitSoundOn("Hero_Slardar.Amplify_Damage", caster)
    caster:AddNewModifier(caster, self, "modifier_ability_custom_mowangjiangling_buff", modifierParams)
end

LinkLuaModifier("modifier_ability_custom_mowangjiangling_buff", "abilities/custom/ability_custom_mowangjiangling", LUA_MODIFIER_MOTION_NONE)

modifier_ability_custom_mowangjiangling_buff = modifier_ability_custom_mowangjiangling_buff or class({})

function modifier_ability_custom_mowangjiangling_buff:IsHidden() return false end
function modifier_ability_custom_mowangjiangling_buff:IsDebuff() return false end
function modifier_ability_custom_mowangjiangling_buff:IsPurgable() return false end
function modifier_ability_custom_mowangjiangling_buff:RemoveOnDeath() return true end
function modifier_ability_custom_mowangjiangling_buff:IsAura() return true end

function modifier_ability_custom_mowangjiangling_buff:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY 
end

function modifier_ability_custom_mowangjiangling_buff:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE 
end

function modifier_ability_custom_mowangjiangling_buff:GetAuraSearchType()
	return DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO
end

function modifier_ability_custom_mowangjiangling_buff:GetModifierAura()
	return "modifier_ability_custom_mowangjiangling_aura"
end

function modifier_ability_custom_mowangjiangling_buff:GetAuraRadius()
	return self.radius
end

function modifier_ability_custom_mowangjiangling_buff:GetTexture()
    return "ability_custom_mowangjiangling"
end

function modifier_ability_custom_mowangjiangling_buff:GetEffectName()
    return "particles/econ/items/enigma/ti9_cache_enigma_lord_armor/ti9_cache_enigma_lord_armor_ambient_edge.vpcf"
end

function modifier_ability_custom_mowangjiangling_buff:GetEffectAttachType()
    return PATTACH_CENTER_FOLLOW
end

function modifier_ability_custom_mowangjiangling_buff:OnCreated(params)
    self.armor_reduction = params.armor_reduction or 1
    self.debuff_duration = params.debuff_duration or 5
    self.radius = params.radius or 600
end


function modifier_ability_custom_mowangjiangling_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function modifier_ability_custom_mowangjiangling_buff:OnAttackLanded(keys)
    if not IsServer() then return end
    if IsNull(keys.target) or IsNull(keys.attacker) or IsNull(self:GetParent()) then return end

    if keys.attacker ~= self:GetParent() or keys.target:IsBuilding() or keys.target:IsOther() then
        return
    end

    local modifierParams = {
        duration = self.debuff_duration,
        armor_reduction = self.armor_reduction,
    }

    local debuff = keys.target:FindModifierByName("modifier_ability_custom_mowangjiangling_debuff")
    if debuff then
        debuff:IncrementStackCount()
        debuff:ForceRefresh()
    else
        keys.target:AddNewModifier(self:GetParent(), nil, "modifier_ability_custom_mowangjiangling_debuff", modifierParams)
    end

end

function modifier_ability_custom_mowangjiangling_buff:OnTooltip()
    return self.armor_reduction
end

LinkLuaModifier("modifier_ability_custom_mowangjiangling_debuff", "abilities/custom/ability_custom_mowangjiangling", LUA_MODIFIER_MOTION_NONE)

modifier_ability_custom_mowangjiangling_debuff = modifier_ability_custom_mowangjiangling_debuff or class({})

function modifier_ability_custom_mowangjiangling_debuff:IsHidden() return false end
function modifier_ability_custom_mowangjiangling_debuff:IsDebuff() return true end
function modifier_ability_custom_mowangjiangling_debuff:IsPurgable() return true end
function modifier_ability_custom_mowangjiangling_debuff:RemoveOnDeath() return true end

function modifier_ability_custom_mowangjiangling_debuff:GetTexture()
    return "ability_custom_mowangjiangling"
end

function modifier_ability_custom_mowangjiangling_debuff:GetEffectName()
    return "particles/units/heroes/hero_slardar/slardar_amp_damage.vpcf"
end

function modifier_ability_custom_mowangjiangling_debuff:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_ability_custom_mowangjiangling_debuff:OnCreated(params)
    self.armor_reduction = params.armor_reduction or 1
    if IsServer() then
        self:SetStackCount(1)
    end
end

function modifier_ability_custom_mowangjiangling_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS 
    }
end

function modifier_ability_custom_mowangjiangling_debuff:OnTooltip()
    return self.armor_reduction
end

function modifier_ability_custom_mowangjiangling_debuff:GetModifierPhysicalArmorBonus()
    return -self.armor_reduction * self:GetStackCount()
end

LinkLuaModifier("modifier_ability_custom_mowangjiangling_aura", "abilities/custom/ability_custom_mowangjiangling", LUA_MODIFIER_MOTION_NONE)

modifier_ability_custom_mowangjiangling_aura = modifier_ability_custom_mowangjiangling_aura or class({})

function modifier_ability_custom_mowangjiangling_aura:IsHidden() return false end
function modifier_ability_custom_mowangjiangling_aura:IsDebuff() return true end
function modifier_ability_custom_mowangjiangling_aura:IsPurgable() return false end
function modifier_ability_custom_mowangjiangling_aura:RemoveOnDeath() return true end

function modifier_ability_custom_mowangjiangling_aura:GetTexture()
    return "ability_custom_mowangjiangling"
end

function modifier_ability_custom_mowangjiangling_aura:OnCreated(params)
    self.armor_reduction = 7
    if IsServer() then
        local ability = self:GetAbility()
        if NotNull(ability) then
            self.armor_reduction = ability:GetSpecialValueFor("aura_armor_reduction")
        end
    end
end

function modifier_ability_custom_mowangjiangling_aura:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS 
    }
end

function modifier_ability_custom_mowangjiangling_aura:OnTooltip()
    return self.armor_reduction
end

function modifier_ability_custom_mowangjiangling_aura:GetModifierPhysicalArmorBonus()
    return -self.armor_reduction
end