ability_custom_fury_swipes = ability_custom_fury_swipes or class({})

LinkLuaModifier("modifier_ability_custom_fury_swipes_buff", "abilities/custom/ability_custom_fury_swipes", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_ability_custom_fury_swipes_debuff", "abilities/custom/ability_custom_fury_swipes", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_custom_enrage_buff", "abilities/custom/ability_custom_fury_swipes", LUA_MODIFIER_MOTION_NONE)

function ability_custom_fury_swipes:OnAbilityPhaseStart()
    return self:CheckPhaseStart()
end

function ability_custom_fury_swipes:OnSpellStart()
    return self:CheckSpellStart()
end

function ability_custom_fury_swipes:CastAbilityTarget(target)
    local caster = self:GetCaster()
    if IsNull(caster) or IsNull(target) then return end

    local modifierParams = {
        duration = self:GetSpecialValueFor("duration"),
        damage = self:GetSpecialValueFor("damage"),
        reset_duration = self:GetSpecialValueFor("reset_duration"),
    }

    EmitSoundOn("Hero_Ursa.Overpower", caster)
    caster:AddNewModifier(caster, nil, "modifier_ability_custom_fury_swipes_buff", modifierParams)
end

modifier_ability_custom_fury_swipes_buff = class({})

function modifier_ability_custom_fury_swipes_buff:GetTexture()
	return "ability_custom_fury_swipes"
end

function modifier_ability_custom_fury_swipes_buff:IsDebuff()
	return false
end

function modifier_ability_custom_fury_swipes_buff:IsHidden()
	return false
end

function modifier_ability_custom_fury_swipes_buff:IsPurgable()
	return false
end

function modifier_ability_custom_fury_swipes_buff:OnCreated(params)
    if not IsServer() then return end
    self.damage = params.damage or 36
    self.reset_duration = params.reset_duration or 20
end

function modifier_ability_custom_fury_swipes_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL
	}
end

function modifier_ability_custom_fury_swipes_buff:GetModifierProcAttack_BonusDamage_Physical( keys )
    if not IsServer() then return end
    local target = keys.target
    local attacker = keys.attacker
    local parent = self:GetParent()
    if IsNull(target) or IsNull(attacker) or IsNull(parent) then return end
    if parent ~= attacker then return end
    local debuff = target:FindModifierByName("modifier_ability_custom_fury_swipes_debuff")
    if NotNull(debuff) then
        debuff:ForceRefresh()
        debuff:IncrementStackCount()
    else
        debuff = target:AddNewModifier(attacker, nil, "modifier_ability_custom_fury_swipes_debuff", {duration = self.reset_duration})
    end

    if NotNull(debuff) then
        if parent:HasModifier("modifier_nuyikuangjixinfa") and debuff:GetStackCount() % 6 == 0 then
            parent:AddNewModifier(parent, nil, "modifier_custom_enrage_buff", {duration = 1.5})
        end  
        return debuff:GetStackCount() * self.damage
    end
end

modifier_ability_custom_fury_swipes_debuff = class({})

function modifier_ability_custom_fury_swipes_debuff:GetTexture()
	return "ability_custom_fury_swipes"
end

function modifier_ability_custom_fury_swipes_debuff:GetEffectName()
	return "particles/units/heroes/hero_ursa/ursa_fury_swipes_debuff.vpcf"
end

function modifier_ability_custom_fury_swipes_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_ability_custom_fury_swipes_debuff:IsDebuff()
	return true
end

function modifier_ability_custom_fury_swipes_debuff:IsHidden()
	return false
end

function modifier_ability_custom_fury_swipes_debuff:IsPurgable()
	return false
end

function modifier_ability_custom_fury_swipes_debuff:OnCreated()
    if not IsServer() then return end
    self:SetStackCount(1)
end

modifier_custom_enrage_buff = class({})

function modifier_custom_enrage_buff:GetEffectName()
	return "particles/units/heroes/hero_ursa/ursa_enrage_buff.vpcf"
end

function modifier_custom_enrage_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_custom_enrage_buff:GetTexture()
	return "ursa_enrage"
end

function modifier_custom_enrage_buff:IsDebuff()
	return false
end

function modifier_custom_enrage_buff:IsHidden()
	return false
end

function modifier_custom_enrage_buff:IsPurgable()
	return false
end

function modifier_custom_enrage_buff:OnCreated(params)
	if IsServer() then
        local caster = self:GetCaster()
        if IsNull(caster) then return end
        -- EmitSoundOn("Hero_Ursa.Enrage", caster)
		caster:SetRenderColor(255,0,0)
	end
end

function modifier_custom_enrage_buff:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
	}
	return decFuncs
end

function modifier_custom_enrage_buff:GetModifierIncomingDamage_Percentage()
    return -80
end

function modifier_custom_enrage_buff:GetModifierStatusResistanceStacking()
	return 60
end