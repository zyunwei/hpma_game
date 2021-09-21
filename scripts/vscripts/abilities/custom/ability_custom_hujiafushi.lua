ability_custom_hujiafushi = ability_custom_hujiafushi or class({})

function ability_custom_hujiafushi:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
    local modifierParams = {
        duration = self:GetSpecialValueFor("duration"),
        armor_reduction = self:GetSpecialValueFor("armor_reduction"),
        debuff_duration = self:GetSpecialValueFor("debuff_duration"),
    }

    local affixAttr = self:GetCaster():GetCustomAttribute("mowang")
    if affixAttr and affixAttr > 0 then
        modifierParams.duration = modifierParams.duration + affixAttr
        modifierParams.debuff_duration = modifierParams.debuff_duration + affixAttr
    end

    EmitSoundOn("Hero_Slardar.Amplify_Damage", caster)
    caster:AddNewModifier(caster, nil, "modifier_ability_custom_hujiafushi_buff", modifierParams)
end

function ability_custom_hujiafushi:OnFold()
	local caster = self:GetCaster()
	if IsNull(caster)  then return end

	if caster:HasModifier("modifier_mowangxinfa") then
		CardGroupSystem:ReplaceCard(caster:GetPlayerID(), "ability_custom_hujiafushi", "ability_custom_mowangjiangling", true)
	end
end

LinkLuaModifier("modifier_ability_custom_hujiafushi_buff", "abilities/custom/ability_custom_hujiafushi", LUA_MODIFIER_MOTION_NONE)

modifier_ability_custom_hujiafushi_buff = modifier_ability_custom_hujiafushi_buff or class({})

function modifier_ability_custom_hujiafushi_buff:IsHidden() return false end
function modifier_ability_custom_hujiafushi_buff:IsDebuff() return false end
function modifier_ability_custom_hujiafushi_buff:IsPurgable() return false end
function modifier_ability_custom_hujiafushi_buff:RemoveOnDeath() return true end

function modifier_ability_custom_hujiafushi_buff:GetTexture()
    return "ability_custom_hujiafushi"
end

function modifier_ability_custom_hujiafushi_buff:GetEffectName()
    return "particles/econ/items/enigma/ti9_cache_enigma_lord_armor/ti9_cache_enigma_lord_armor_ambient_edge.vpcf"
end

function modifier_ability_custom_hujiafushi_buff:GetEffectAttachType()
    return PATTACH_CENTER_FOLLOW
end

function modifier_ability_custom_hujiafushi_buff:OnCreated(params)
    self.armor_reduction = params.armor_reduction or 1
    self.debuff_duration = params.debuff_duration or 5
end


function modifier_ability_custom_hujiafushi_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function modifier_ability_custom_hujiafushi_buff:OnAttackLanded(keys)
    if not IsServer() then return end
    if IsNull(keys.target) or IsNull(self:GetParent()) then return end

    if keys.attacker ~= self:GetParent() or keys.target:IsBuilding() or keys.target:IsOther() then
        return
    end

    local modifierParams = {
        duration = self.debuff_duration,
        armor_reduction = self.armor_reduction,
    }

    local debuff = keys.target:FindModifierByName("modifier_ability_custom_hujiafushi_debuff")
    if NotNull(debuff) then
        debuff:IncrementStackCount()
        debuff:ForceRefresh()
    else
        keys.target:AddNewModifier(self:GetParent(), nil, "modifier_ability_custom_hujiafushi_debuff", modifierParams)
    end

end

function modifier_ability_custom_hujiafushi_buff:OnTooltip()
    return self.armor_reduction
end

LinkLuaModifier("modifier_ability_custom_hujiafushi_debuff", "abilities/custom/ability_custom_hujiafushi", LUA_MODIFIER_MOTION_NONE)

modifier_ability_custom_hujiafushi_debuff = modifier_ability_custom_hujiafushi_debuff or class({})

function modifier_ability_custom_hujiafushi_debuff:IsHidden() return false end
function modifier_ability_custom_hujiafushi_debuff:IsDebuff() return true end
function modifier_ability_custom_hujiafushi_debuff:IsPurgable() return true end
function modifier_ability_custom_hujiafushi_debuff:RemoveOnDeath() return true end

function modifier_ability_custom_hujiafushi_debuff:GetTexture()
    return "ability_custom_hujiafushi"
end

function modifier_ability_custom_hujiafushi_debuff:GetEffectName()
    return "particles/units/heroes/hero_slardar/slardar_amp_damage.vpcf"
end

function modifier_ability_custom_hujiafushi_debuff:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_ability_custom_hujiafushi_debuff:OnCreated(params)
    self.armor_reduction = params.armor_reduction or 1
    if IsServer() then
        self:SetStackCount(1)
    end
end

function modifier_ability_custom_hujiafushi_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS 
    }
end

function modifier_ability_custom_hujiafushi_debuff:OnTooltip()
    return self.armor_reduction
end

function modifier_ability_custom_hujiafushi_debuff:GetModifierPhysicalArmorBonus()
    return -self.armor_reduction * self:GetStackCount()
end