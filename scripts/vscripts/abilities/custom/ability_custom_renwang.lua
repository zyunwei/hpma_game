ability_custom_renwang = ability_custom_renwang or class({})

function ability_custom_renwang:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
    local modifierParams = {
        duration = self:GetSpecialValueFor("duration"),
        damage_rate = self:GetSpecialValueFor("damage_rate"),
        base_damage = self:GetSpecialValueFor("base_damage")
    }
    caster:AddNewModifier(caster, nil, "modifier_ability_custom_renwang_buff", modifierParams)

    local sound_cast = "Hero_NyxAssassin.SpikedCarapace"
    EmitSoundOn(sound_cast, caster)

end

function ability_custom_renwang:OnFold()
	local caster = self:GetCaster()
	if IsNull(caster)  then return end

	if caster:HasModifier("modifier_zhihengxinfa") then
		CardGroupSystem:ReplaceCard(caster:GetPlayerID(), "ability_custom_renwang", "ability_custom_zhiheng", true)
	end
end

LinkLuaModifier("modifier_ability_custom_renwang_buff", "abilities/custom/ability_custom_renwang", LUA_MODIFIER_MOTION_NONE)

modifier_ability_custom_renwang_buff = modifier_ability_custom_renwang_buff or class({})

function modifier_ability_custom_renwang_buff:IsHidden() return false end
function modifier_ability_custom_renwang_buff:IsDebuff() return false end
function modifier_ability_custom_renwang_buff:IsPurgable() return false end
function modifier_ability_custom_renwang_buff:RemoveOnDeath() return true end

function modifier_ability_custom_renwang_buff:GetTexture()
    return "ability_custom_renwang"
end

function modifier_ability_custom_renwang_buff:GetEffectName()
    return "particles/econ/items/nyx_assassin/nyx_ti9_immortal/nyx_ti9_carapace.vpcf"
end

function modifier_ability_custom_renwang_buff:GetEffectAttachType()
    return PATTACH_CENTER_FOLLOW
end

function modifier_ability_custom_renwang_buff:OnCreated(params)
    self.damage_rate = 150
    self.base_damage = 50
    if IsServer() then
        if params then
            self.damage_rate = params.damage_rate
            self.base_damage = params.base_damage
        end
    end
end

function modifier_ability_custom_renwang_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_EVENT_ON_ATTACKED
    }
end

function modifier_ability_custom_renwang_buff:OnAttacked(keys)
    if not IsServer() then return end

    local parent = self:GetParent()
    if IsNull(keys.target) or IsNull(parent) or IsNull(keys.attacker) then return end

    if keys.target ~= self:GetParent() then
        return
    end

    local damage = self.base_damage

    if keys.attacker:IsHero() then
        local delta = keys.attacker:GetMaxHealth() - parent:GetMaxHealth()
        if delta > 0 then
            damage = delta * self.damage_rate * 0.01
        end
    end

    local affixAttr = self:GetCaster():GetCustomAttribute("zhiheng")
    if affixAttr and affixAttr > 0 then
        damage = damage * (1 + affixAttr * 0.01)
    end

    ApplyDamage({attacker = parent, victim = keys.attacker, damage_type = DAMAGE_TYPE_MAGICAL, damage = damage})
end

function modifier_ability_custom_renwang_buff:OnTooltip()
    return self.damage_rate
end
