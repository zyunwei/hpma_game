ability_custom_bkb = ability_custom_bkb or class({})

function ability_custom_bkb:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        if IsNull(caster) then return end
        local modifierParams = {
            buff_duration = self:GetSpecialValueFor("duration"),
            trigger_health_pct = self:GetSpecialValueFor("trigger_health_pct"),
        }
        caster:AddNewModifier(caster, nil, "modifier_ability_custom_bkb", modifierParams)
    end
end

LinkLuaModifier("modifier_ability_custom_bkb", "abilities/custom/ability_custom_bkb", LUA_MODIFIER_MOTION_NONE)

modifier_ability_custom_bkb = class({})

function modifier_ability_custom_bkb:IsHidden() return false end
function modifier_ability_custom_bkb:IsDebuff() return false end
function modifier_ability_custom_bkb:IsPurgable() return false end
function modifier_ability_custom_bkb:RemoveOnDeath() return true end

function modifier_ability_custom_bkb:GetTexture()
    return "ability_custom_bkb"
end

function modifier_ability_custom_bkb:OnCreated(params)
    self.trigger_health_pct = params.trigger_health_pct or 50
    self.buff_duration = params.buff_duration or 1.5
    if IsServer() then
        self:StartIntervalThink(0.5)
    end
end

function modifier_ability_custom_bkb:OnIntervalThink()
    local parent = self:GetParent()
    if IsNull(parent) then return end
    if parent:GetHealthPercent() <= self.trigger_health_pct then
        local enemies = FindUnitsInRadius(
			parent:GetTeamNumber(),
			parent:GetAbsOrigin(),
			parent,
			800,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS,
			0,
			true
		)
        parent:Purge(false, true, false, true, true)
        parent:AddNewModifier(parent, nil, "modifier_custom_bkb", {duration = self.buff_duration + #enemies * 0.5})
        self:Destroy()
    end
end

LinkLuaModifier("modifier_custom_bkb", "abilities/custom/ability_custom_bkb", LUA_MODIFIER_MOTION_NONE)

modifier_custom_bkb = class({})

function modifier_custom_bkb:IsHidden() return false end
function modifier_custom_bkb:IsDebuff() return false end
function modifier_custom_bkb:IsPurgable() return false end
function modifier_custom_bkb:RemoveOnDeath() return true end

function modifier_custom_bkb:GetTexture()
    return "ability_custom_bkb"
end

function modifier_custom_bkb:CheckState()
    return {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true
    }
end

function modifier_custom_bkb:GetEffectName()
    return "particles/items_fx/black_king_bar_avatar.vpcf"
end

function modifier_custom_bkb:OnCreated()
    if IsServer() then
        local parent = self:GetParent()
        parent:EmitSound("DOTA_Item.BlackKingBar.Activate")
    end
end