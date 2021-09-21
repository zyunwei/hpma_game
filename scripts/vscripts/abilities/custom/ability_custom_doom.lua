ability_custom_doom = ability_custom_doom or class({})

function ability_custom_doom:OnAbilityPhaseStart()
    return self:CheckPhaseStart()
end

function ability_custom_doom:OnSpellStart()
    return self:CheckSpellStart()
end

function ability_custom_doom:CastAbilityTarget(target)
    local caster = self:GetCaster()
    if IsNull(caster) then return end
    if target ~= nil and IsNull(target) == false then
        local modifierParams = {
            duration = self:GetSpecialValueFor("duration"),
            damage = self:GetSpecialValueFor("damage"),
            damgeType = self:GetAbilityDamageType()
        }

        local affixAttr = self:GetCaster():GetCustomAttribute("doom")
        if affixAttr and affixAttr > 0 then
            modifierParams.duration = modifierParams.duration + affixAttr
        end

        modifierParams.duration = modifierParams.duration * (1 - target:GetStatusResistance())

        target:AddNewModifier(caster, nil, "modifier_custom_doom", modifierParams)
    end
end

LinkLuaModifier("modifier_custom_doom", "abilities/custom/ability_custom_doom", LUA_MODIFIER_MOTION_NONE)

modifier_custom_doom = class({})

local modifier_custom_doom = modifier_custom_doom

function modifier_custom_doom:IsHidden() return false end
function modifier_custom_doom:IsDebuff() return true end
function modifier_custom_doom:IsPurgable() return false end
function modifier_custom_doom:RemoveOnDeath() return true end

function modifier_custom_doom:GetTexture()
    return "ability_custom_doom"
end

function modifier_custom_doom:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP,
    }
end

function modifier_custom_doom:OnCreated(params)
    self.damage = params.damage or 10
    self.damageType = params.damageType or DAMAGE_TYPE_PURE
    if IsServer() then
        if IsNull(self:GetParent()) then return end
        EmitSoundOn("Hero_DoomBringer.Doom", self:GetParent())
        self:StartIntervalThink(1.0)
    end
end

function modifier_custom_doom:CheckState()
    local state = {
		[MODIFIER_STATE_MUTED] = true,
		[MODIFIER_STATE_SILENCED] = true,
    }
    if NotNull(self:GetCaster()) and self:GetCaster():HasModifier("modifier_moridaoxinfa") then
        state[MODIFIER_STATE_PASSIVES_DISABLED] = true
    end
    return state
end

function modifier_custom_doom:GetEffectName()
	return "particles/units/heroes/hero_doom_bringer/doom_bringer_doom.vpcf"
end

function modifier_custom_doom:GetEffectAttachType()
	return PATTACH_CUSTOMORIGIN_FOLLOW
end

function modifier_custom_doom:OnIntervalThink()
    if IsServer() then
        if IsNull(self:GetParent()) or IsNull(self:GetCaster()) then return end
        ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = self.damage, damage_type = self.damageType})
    end
end

function modifier_custom_doom:OnTooltip()
    return self.damage
end

function modifier_custom_doom:OnDestroy()
	if not IsServer() then return end
    if IsNull(self:GetParent()) then return end
	self:GetParent():StopSound("Hero_DoomBringer.Doom")
end
