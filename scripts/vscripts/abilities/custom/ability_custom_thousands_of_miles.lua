ability_custom_thousands_of_miles = ability_custom_thousands_of_miles or class({})

LinkLuaModifier("modifier_ability_custom_thousands_of_miles_buff", "abilities/custom/ability_custom_thousands_of_miles", LUA_MODIFIER_MOTION_NONE)

function ability_custom_thousands_of_miles:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
    local modifierParams = {
        move_speed_pct = self:GetSpecialValueFor("move_speed_pct"),
        bonus_move_speed = self:GetSpecialValueFor("bonus_move_speed"),
        duration = self:GetSpecialValueFor("duration"),
    }
    caster:AddNewModifier(caster, nil, "modifier_ability_custom_thousands_of_miles_buff", modifierParams)

end

modifier_ability_custom_thousands_of_miles_buff = modifier_ability_custom_thousands_of_miles_buff or class({})

function modifier_ability_custom_thousands_of_miles_buff:IsHidden() return false end
function modifier_ability_custom_thousands_of_miles_buff:IsDebuff() return false end
function modifier_ability_custom_thousands_of_miles_buff:IsPurgable() return false end
function modifier_ability_custom_thousands_of_miles_buff:RemoveOnDeath() return true end

function modifier_ability_custom_thousands_of_miles_buff:GetTexture()
    return "ability_custom_thousands_of_miles"
end

function modifier_ability_custom_thousands_of_miles_buff:OnCreated(params)
    if not IsServer() then return end
    local parent = self:GetParent()
    if IsNull(parent) then return end
    self.move_speed_pct = params.move_speed_pct or 20
    self.bonus_move_speed = params.bonus_move_speed or 1
    self.move_distance = 0
    self.start_position = parent:GetAbsOrigin()
    self:StartIntervalThink(0.1)

    if GameRules.XW:IsDeveloper(parent:GetPlayerID()) == false then
        EmitSoundOn("XXWAR.QING_TIAN", parent)
    end
end

function modifier_ability_custom_thousands_of_miles_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end

function modifier_ability_custom_thousands_of_miles_buff:GetModifierMoveSpeedBonus_Percentage()
    return self.move_speed_pct
end

function modifier_ability_custom_thousands_of_miles_buff:OnIntervalThink()
    local parent = self:GetParent()
    if IsNull(parent) then return end
    local nowPosition = parent:GetAbsOrigin()
    self.move_distance = self.move_distance + (nowPosition - self.start_position):Length()
    self.start_position = nowPosition
    if self.move_distance >= 2000 then
        self:IncrementStackCount()
        self.move_distance = 0
        parent:ModifyCustomAttribute("move_speed", "ability_custom_thousands_of_miles", self.bonus_move_speed)
    end
end
