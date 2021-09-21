ability_custom_track = ability_custom_track or class({})

LinkLuaModifier("modifier_ability_custom_track_buff", "abilities/custom/ability_custom_track", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_custom_track_stack_buff", "abilities/custom/ability_custom_track", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_custom_track_debuff", "abilities/custom/ability_custom_track", LUA_MODIFIER_MOTION_NONE)

function ability_custom_track:OnSpellStart()
    if GameRules.XW.DynamicVision == false then return end
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
    local modifierParams = {
        bonus_vision = self:GetSpecialValueFor("bonus_vision"),
        bonus_damage_pct = self:GetSpecialValueFor("bonus_damage_pct"),
        bonus_damage_pct_per_stack = self:GetSpecialValueFor("bonus_damage_pct_per_stack"),
        duration = self:GetSpecialValueFor("duration"),
    }

    local affixAttr = self:GetCaster():GetCustomAttribute("lianhuan")
    if affixAttr and affixAttr > 0 then
        modifierParams.bonus_damage_pct = modifierParams.bonus_damage_pct + affixAttr
    end

    caster:AddNewModifier(caster, nil, "modifier_ability_custom_track_buff", modifierParams)
end

modifier_ability_custom_track_buff = class({})

function modifier_ability_custom_track_buff:IsHidden() return false end
function modifier_ability_custom_track_buff:IsDebuff() return false end
function modifier_ability_custom_track_buff:IsPurgable() return false end
function modifier_ability_custom_track_buff:RemoveOnDeath() return true end

function modifier_ability_custom_track_buff:GetTexture()
    return "ability_custom_track"
end

function modifier_ability_custom_track_buff:OnCreated(params)
    if not IsServer() then return end
    self.bonus_vision = params.bonus_vision or 500
    self.bonus_damage_pct = params.bonus_damage_pct or 20
    self.bonus_damage_pct_per_stack = params.bonus_damage_pct_per_stack or 5
    self:FindTarget()
end

function modifier_ability_custom_track_buff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_EVENT_ON_HERO_KILLED,
    }
    return funcs
end

function modifier_ability_custom_track_buff:GetModifierTotalDamageOutgoing_Percentage(keys)
    local attacker = keys.attacker
    local target = keys.target
    local parent = self:GetParent()
    if IsNull(attacker) or IsNull(target) or IsNull(parent) then return end

    if attacker ~= parent then return end
    if self:TargetIsTracked(target) then
        local modifier = parent:FindModifierByName("modifier_ability_custom_track_stack_buff")
        local damagePct = self.bonus_damage_pct
        if NotNull(modifier) then
            damagePct = damagePct + modifier:GetStackCount() * self.bonus_damage_pct_per_stack
        end
        return damagePct
    end
end

function modifier_ability_custom_track_buff:OnHeroKilled(keys)
    local attacker = keys.attacker
    local target = keys.target
    local parent = self:GetParent()
    if IsNull(attacker) or IsNull(target) or IsNull(parent) then return end

    if attacker ~= parent then return end
    if self:TargetIsTracked(target) then
        local modifier = parent:FindModifierByName("modifier_ability_custom_track_stack_buff")
        if NotNull(modifier) then
            modifier:IncrementStackCount()
        else
            parent:AddNewModifier(parent, nil, "modifier_ability_custom_track_stack_buff", {})
        end
    end
end

function modifier_ability_custom_track_buff:TargetIsTracked(target)
    local parent = self:GetParent()
    if IsNull(target) or IsNull(parent) then return false end
    local modifierName = "modifier_ability_custom_track_debuff"
    local modifier = target:FindModifierByName(modifierName)
    if NotNull(modifier) and modifier:GetCaster() == parent then return true end
    local owner = target:GetOwner()
    if NotNull(owner) and owner:IsBaseNPC() and owner.IsRealHero ~= nil and owner:IsRealHero() then
        modifier = owner:FindModifierByName(modifierName)
        if NotNull(modifier) and modifier:GetCaster() == parent then return true end
    end
    return false
end

function modifier_ability_custom_track_buff:FindTarget()
    local parent = self:GetParent()
    if IsNull(parent) then return end
    local targets = {}
    for _, playerInfo in pairs(GameRules.XW.PlayerList) do
        local hero = playerInfo.Hero
        if NotNull(hero) and hero:IsAlive() and hero ~= parent and
         not hero:HasModifier("modifier_ability_custom_track_debuff") and
         hero:GetTeamNumber() ~= parent:GetTeamNumber() then
            table.insert(targets, hero)
        end
    end
    if targets and #targets ~= 0 then
        local target = table.random(targets)
        target:AddNewModifier(parent, nil, "modifier_ability_custom_track_debuff", {duration = self:GetRemainingTime(), bonus_vision = self.bonus_vision})
    end
end

modifier_ability_custom_track_stack_buff = class({})

function modifier_ability_custom_track_stack_buff:IsHidden() return false end
function modifier_ability_custom_track_stack_buff:IsDebuff() return false end
function modifier_ability_custom_track_stack_buff:IsPurgable() return false end
function modifier_ability_custom_track_stack_buff:RemoveOnDeath() return false end

function modifier_ability_custom_track_stack_buff:GetTexture()
    return "ability_custom_track"
end

function modifier_ability_custom_track_stack_buff:OnCreated()
    if not IsServer() then return end
    self:SetStackCount(1)
end

modifier_ability_custom_track_debuff = class({})

function modifier_ability_custom_track_debuff:IsHidden() return false end
function modifier_ability_custom_track_debuff:IsDebuff() return true end
function modifier_ability_custom_track_debuff:IsPurgable() return false end
function modifier_ability_custom_track_debuff:RemoveOnDeath() return true end

function modifier_ability_custom_track_debuff:GetTexture()
    return "ability_custom_track"
end

function modifier_ability_custom_track_debuff:GetEffectName()
    return "particles/econ/items/sniper/sniper_fall20_immortal/sniper_fall20_immortal_crosshair_bullseye.vpcf"
end

function modifier_ability_custom_track_debuff:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_ability_custom_track_debuff:OnCreated(params)
    if not IsServer() then return end
    self.bonus_vision = params.bonus_vision or 500
    self:StartIntervalThink(FrameTime() * 3)
end

function modifier_ability_custom_track_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_DEATH,
    }
    return funcs
end

function modifier_ability_custom_track_debuff:OnIntervalThink()
	if not IsServer() then return end
    local caster = self:GetCaster()
    local parent = self:GetParent()
    if IsNull(caster) or IsNull(parent) then return end
	AddFOWViewer(caster:GetTeam(), parent:GetAbsOrigin(), self.bonus_vision, FrameTime() * 3, true)

end

function modifier_ability_custom_track_debuff:OnDeath(keys)
    local attacker = keys.attacker
    local target = keys.unit
    local parent = self:GetParent()
    local caster = self:GetCaster()
    if IsNull(attacker) or IsNull(target) or IsNull(parent) or IsNull(caster) then return end
    if target ~= parent then return end
    local modifier = caster:FindModifierByName("modifier_ability_custom_track_buff")
    if NotNull(modifier) then
        modifier:FindTarget()
    end
end