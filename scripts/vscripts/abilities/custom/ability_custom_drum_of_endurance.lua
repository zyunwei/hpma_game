ability_custom_drum_of_endurance = ability_custom_drum_of_endurance or class({})

function ability_custom_drum_of_endurance:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
    local radius = self:GetSpecialValueFor("radius")
    local modifierParams = {
        move_speed_pct = self:GetSpecialValueFor("move_speed_pct"),
        bonus_attack_speed = self:GetSpecialValueFor("bonus_attack_speed"),
        duration = self:GetSpecialValueFor("duration"),
    }

    local stackModifier = caster:FindModifierByName("modifier_ability_custom_drum_of_endurance_stack")
    if NotNull(stackModifier) then
        modifierParams.move_speed_pct = modifierParams.move_speed_pct + stackModifier:GetStackCount()
        modifierParams.bonus_attack_speed = modifierParams.bonus_attack_speed + stackModifier:GetStackCount() * 5
        stackModifier:IncrementStackCount()
    else
        caster:AddNewModifier(caster, nil, "modifier_ability_custom_drum_of_endurance_stack", {})
    end
    local target_type = DOTA_UNIT_TARGET_HERO
    local target_team =  DOTA_UNIT_TARGET_TEAM_FRIENDLY
    local target_flags = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE

    local allies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, target_team, target_type, target_flags, FIND_CLOSEST, false)
    for _, ally in pairs(allies) do
        if NotNull(ally) then 
            ally:AddNewModifier(caster, nil, "modifier_ability_custom_drum_of_endurance_buff", modifierParams)
        end
    end
    local particle = ParticleManager:CreateParticle("particles/items_fx/drum_of_endurance_buff.vpcf", PATTACH_WORLDORIGIN, caster)
    ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
    EmitSoundOn("DOTA_Item.DoE.Activate", caster)
end

LinkLuaModifier("modifier_ability_custom_drum_of_endurance_buff", "abilities/custom/ability_custom_drum_of_endurance", LUA_MODIFIER_MOTION_NONE)

modifier_ability_custom_drum_of_endurance_buff = modifier_ability_custom_drum_of_endurance_buff or class({})

function modifier_ability_custom_drum_of_endurance_buff:IsHidden() return false end
function modifier_ability_custom_drum_of_endurance_buff:IsDebuff() return false end
function modifier_ability_custom_drum_of_endurance_buff:IsPurgable() return false end
function modifier_ability_custom_drum_of_endurance_buff:RemoveOnDeath() return true end

function modifier_ability_custom_drum_of_endurance_buff:GetTexture()
    return "ability_custom_drum_of_endurance"
end

function modifier_ability_custom_drum_of_endurance_buff:GetEffectName()
    return "particles/units/heroes/hero_lone_druid/lone_druid_rabid_buff_speed_ring.vpcf"
end

function modifier_ability_custom_drum_of_endurance_buff:OnCreated(params)
    self.move_speed_pct = params.move_speed_pct or 15
    self.bonus_attack_speed = params.bonus_attack_speed or 15
end


function modifier_ability_custom_drum_of_endurance_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
end

function modifier_ability_custom_drum_of_endurance_buff:GetModifierMoveSpeedBonus_Percentage()
    return self.move_speed_pct
end

function modifier_ability_custom_drum_of_endurance_buff:GetModifierAttackSpeedBonus_Constant()
    return self.bonus_attack_speed
end

LinkLuaModifier("modifier_ability_custom_drum_of_endurance_stack", "abilities/custom/ability_custom_drum_of_endurance", LUA_MODIFIER_MOTION_NONE)

modifier_ability_custom_drum_of_endurance_stack = modifier_ability_custom_drum_of_endurance_stack or class({})

function modifier_ability_custom_drum_of_endurance_stack:IsHidden() return false end
function modifier_ability_custom_drum_of_endurance_stack:IsDebuff() return false end
function modifier_ability_custom_drum_of_endurance_stack:IsPurgable() return false end
function modifier_ability_custom_drum_of_endurance_stack:RemoveOnDeath() return false end

function modifier_ability_custom_drum_of_endurance_stack:GetTexture()
    return "ability_custom_drum_of_endurance"
end

function modifier_ability_custom_drum_of_endurance_stack:OnCreated()
   self:SetStackCount(1)
end