ability_custom_essence_aura = ability_custom_essence_aura or class({})

LinkLuaModifier("modifier_ability_custom_essence_aura_buff", "abilities/custom/ability_custom_essence_aura", LUA_MODIFIER_MOTION_NONE)

function ability_custom_essence_aura:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
    if caster:GetManaPercent() <= 20 then
        return
    end
    EmitSoundOn("Hero_ObsidianDestroyer.EssenceFlux.Cast", caster)
    local health_per_mana = self:GetSpecialValueFor("health_per_mana")
    local duration = self:GetSpecialValueFor("duration")
    local needHeal = caster:GetHealthDeficit()
    local needMana = needHeal / health_per_mana
    local mana = caster:GetMana() - caster:GetMaxMana() * 0.2
    local heal_per_sec
    if mana >= needMana then
        heal_per_sec = needHeal / duration
        caster:ReduceMana(needMana)
    else
        heal_per_sec = mana * health_per_mana / duration
        caster:ReduceMana(mana)
    end
    local modifierParams = {
        heal_per_sec = heal_per_sec,
        duration = self:GetSpecialValueFor("duration"),
    }
    caster:AddNewModifier(caster, nil, "modifier_ability_custom_essence_aura_buff", modifierParams)
    caster:ModifyCustomAttribute("mana", "ability_custom_essence_aura", self:GetSpecialValueFor("bonus_max_mana"))
end

modifier_ability_custom_essence_aura_buff = modifier_ability_custom_essence_aura_buff or class({})

function modifier_ability_custom_essence_aura_buff:IsHidden() return false end
function modifier_ability_custom_essence_aura_buff:IsDebuff() return false end
function modifier_ability_custom_essence_aura_buff:IsPurgable() return false end
function modifier_ability_custom_essence_aura_buff:RemoveOnDeath() return true end

function modifier_ability_custom_essence_aura_buff:GetEffectName()
    return "particles/items5_fx/essence_ring.vpcf"
end

-- function modifier_ability_custom_essence_aura_buff:GetEffectAttachType()
--     return PATTACH_OVERHEAD_FOLLOW
-- end

function modifier_ability_custom_essence_aura_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_BONUS,
    }
end

function modifier_ability_custom_essence_aura_buff:GetTexture()
    return "ability_custom_essence_aura"
end

function modifier_ability_custom_essence_aura_buff:GetModifierHealthBonus()
    if IsServer() then
        return self.heal_per_sec * self:GetDuration()
    end
end

function modifier_ability_custom_essence_aura_buff:OnCreated(params)
    if not IsServer() then return end
    local parent = self:GetParent()
    if IsNull(parent) then return end
    self.heal_per_sec = params.heal_per_sec
    self:StartIntervalThink(0.1)
end

function modifier_ability_custom_essence_aura_buff:OnIntervalThink()
    local parent = self:GetParent()
    if IsNull(parent) then return end
    parent:Heal(self.heal_per_sec * 0.1, nil)
    SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, parent, self.heal_per_sec * 0.1, nil)
end



