ability_custom_battle_trance = ability_custom_battle_trance or class({})

LinkLuaModifier("modifier_ability_battle_trance_trigger","abilities/custom/ability_custom_battle_trance",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_battle_trance_buff","abilities/custom/ability_custom_battle_trance",LUA_MODIFIER_MOTION_NONE)

modifier_ability_battle_trance_trigger = class({})
function modifier_ability_battle_trance_trigger:IsHidden() return false end
function modifier_ability_battle_trance_trigger:IsDebuff() return false end
function modifier_ability_battle_trance_trigger:IsPurgable() return false end
function modifier_ability_battle_trance_trigger:RemoveOnDeath() return true end
function modifier_ability_battle_trance_trigger:GetTexture()
    return "ability_custom_battle_trance"
end

function ability_custom_battle_trance:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if IsNull(caster)  then return end

    local triggerModifierName = "modifier_ability_battle_trance_trigger"

    if caster:HasModifier(triggerModifierName) then
        caster:RemoveModifierByName(triggerModifierName)
    end

    local modifierParams = {
        max_stack_level = self:GetSpecialValueFor("max_stack_level"),
        battle_trance_attack_speed = self:GetSpecialValueFor("battle_trance_attack_speed"),
        battle_trance_move_speed_percentage = self:GetSpecialValueFor("battle_trance_move_speed_percentage"),
        battle_trance_lifesteal = self:GetSpecialValueFor("battle_trance_lifesteal"),
        buff_duration = self:GetSpecialValueFor("buff_duration"),
        stack_attack_speed = self:GetSpecialValueFor("stack_attack_speed"),
    }

    caster:AddNewModifier(caster, nil, triggerModifierName, modifierParams)
end

function modifier_ability_battle_trance_trigger:OnCreated(params)
    if not IsServer() then return end

    self.max_stack_level = params.max_stack_level
    self.battle_trance_attack_speed = params.battle_trance_attack_speed
    self.battle_trance_move_speed_percentage = params.battle_trance_move_speed_percentage
    self.battle_trance_lifesteal = params.battle_trance_lifesteal
    self.buff_duration = params.buff_duration
    self.stack_attack_speed = params.stack_attack_speed
end

function modifier_ability_battle_trance_trigger:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }

    return funcs
end

function modifier_ability_battle_trance_trigger:OnAttackLanded(keys)
    if not IsServer() then return end
    if IsNull(keys.target) then return end

    if keys.attacker ~= self:GetParent() or keys.target:IsBuilding() or keys.target:IsOther() then
        return
    end

    local parent = self:GetParent()
    if IsNull(parent) then return end

    local targetIndex = keys.target:entindex()
    if self.LastAttackTarget == targetIndex then
        if self:GetStackCount() < self.max_stack_level - 1 then
            self:IncrementStackCount()
        else
            local xinfa = parent:FindModifierByName("modifier_ganjiangjianxinfa")
            if NotNull(xinfa) then
                self.buff_duration = self.buff_duration + xinfa:GetBonusDuration()
            end
            parent:EmitSound("Hero_TrollWarlord.BattleTrance.Cast")
            parent:AddNewModifier(parent, nil, "modifier_ability_battle_trance_buff", {
                    battle_trance_attack_speed = self.battle_trance_attack_speed,
                    battle_trance_move_speed_percentage = self.battle_trance_move_speed_percentage,
                    battle_trance_lifesteal = self.battle_trance_lifesteal,
                    duration = self.buff_duration
            })

            parent:RemoveModifierByName("modifier_ability_battle_trance_trigger")
            return
        end
    else
        self:SetStackCount(1)
    end

    self.LastAttackTarget = targetIndex
end

function modifier_ability_battle_trance_trigger:GetModifierAttackSpeedBonus_Constant()
    if not IsServer() then return end
    return self.stack_attack_speed * self:GetStackCount()
end

modifier_ability_battle_trance_buff = class({})
function modifier_ability_battle_trance_buff:IsHidden() return false end
function modifier_ability_battle_trance_buff:IsDebuff() return false end
function modifier_ability_battle_trance_buff:IsPurgable() return false end
function modifier_ability_battle_trance_buff:RemoveOnDeath() return true end
function modifier_ability_battle_trance_buff:GetTexture()
    return "ability_custom_battle_trance"
end

function modifier_ability_battle_trance_buff:GetEffectName()
    return "particles/units/heroes/hero_troll_warlord/troll_warlord_battletrance_buff.vpcf"
end

function modifier_ability_battle_trance_buff:GetEffectAttachType()
    return PATTACH_CENTER_FOLLOW
end

function modifier_ability_battle_trance_buff:GetTexture()
    return "sniper_headshot"
end

function modifier_ability_battle_trance_buff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_ability_battle_trance_buff:OnCreated(params)
    if not IsServer() then return end

    local caster = self:GetCaster()
    if IsNull(caster) then return end
    self.battle_trance_attack_speed = params.battle_trance_attack_speed or 120
    self.battle_trance_move_speed_percentage = params.battle_trance_move_speed_percentage or 30
    self.battle_trance_lifesteal = params.battle_trance_lifesteal or 30

    local affixAttr = self:GetCaster():GetCustomAttribute("battle_trance")
    if affixAttr and affixAttr > 0 then
        self.battle_trance_attack_speed = self.battle_trance_attack_speed + affixAttr
    end
end

function modifier_ability_battle_trance_buff:GetModifierLifesteal()
    return self.battle_trance_lifesteal
end

function modifier_ability_battle_trance_buff:GetModifierAttackSpeedBonus_Constant()
    return self.battle_trance_attack_speed
end

function modifier_ability_battle_trance_buff:GetModifierMoveSpeedBonus_Percentage()
    return self.battle_trance_move_speed_percentage
end
