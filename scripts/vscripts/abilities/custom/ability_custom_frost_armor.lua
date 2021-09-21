ability_custom_frost_armor = ability_custom_frost_armor or class({})

LinkLuaModifier("modifier_custom_frost_armor", "abilities/custom/ability_custom_frost_armor", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_custom_frost_armor_slow", "abilities/custom/ability_custom_frost_armor", LUA_MODIFIER_MOTION_HORIZONTAL)

function ability_custom_frost_armor:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if IsNull(caster)  then return end

    local modifierName = "modifier_custom_frost_armor"

	if caster:HasModifier(modifierName) then
		caster:RemoveModifierByName(modifierName)
	end

	local modifierParams = {
        armor_bonus = self:GetSpecialValueFor("armor_bonus"),
        magical_resistance = self:GetSpecialValueFor("magical_resistance"),
        slow_duration = self:GetSpecialValueFor("slow_duration"),
        slow_movement_speed = self:GetSpecialValueFor("slow_movement_speed"),
        slow_attack_speed = self:GetSpecialValueFor("slow_attack_speed"),
		duration = self:GetSpecialValueFor("duration")
	}

	caster:AddNewModifier(caster, nil, modifierName, modifierParams)

    EmitSoundOn("Hero_Lich.FrostArmor", caster)
end

function ability_custom_frost_armor:OnFold()
    local caster = self:GetCaster()
    if IsNull(caster) then return end

    if caster:HasModifier("modifier_bingxinjue") then
        CardGroupSystem:ReplaceCard(caster:GetPlayerID(), "ability_custom_frost_armor", "ability_custom_shivas_guard", true)
    end
end

modifier_custom_frost_armor = class({})
function modifier_custom_frost_armor:IsHidden() return false end
function modifier_custom_frost_armor:IsDebuff() return false end
function modifier_custom_frost_armor:IsPurgable() return true end
function modifier_custom_frost_armor:RemoveOnDeath() return true end
function modifier_custom_frost_armor:GetTexture()
    return "ability_custom_frost_armor"
end

function modifier_custom_frost_armor:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_custom_frost_armor:OnCreated(params)

    self.armor_bonus = params.armor_bonus or 10
    self.magical_resistance = params.magical_resistance or 10

	self.slow_duration = params.slow_duration or 10
    self.slow_movement_speed = params.slow_movement_speed or 10
    self.slow_attack_speed = params.slow_attack_speed or 10

    if IsServer() then
        local pid = ParticleManager:CreateParticle("particles/units/heroes/hero_lich/lich_frost_armor.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl(pid, 1, Vector(150, 150, 150))
        self:AddParticle(pid, false, false, -1, false, true)
    end
end

function modifier_custom_frost_armor:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_EVENT_ON_ATTACKED
	}

    return funcs
end

function modifier_custom_frost_armor:OnAttacked(keys)
    if not IsServer() then return end

    local parent = self:GetParent()
    if IsNull(keys.target) or IsNull(parent) or IsNull(keys.attacker) then return end

    if keys.target ~= self:GetParent() then
        return
    end

    local slowModifierName = "modifier_custom_frost_armor_slow"

    if keys.attacker:HasModifier(slowModifierName) then
    	return
    end

	local resistance = keys.attacker:GetStatusResistance()
    local modifierParams = {
		duration = self.slow_duration * (1 - resistance),
		slow_movement_speed = self.slow_movement_speed,
		slow_attack_speed = self.slow_attack_speed
	}

    keys.attacker:AddNewModifier(parent, nil, slowModifierName, modifierParams)
    EmitSoundOn("Hero_Lich.FrostArmorDamage", keys.attacker)
end

function modifier_custom_frost_armor:GetModifierPhysicalArmorBonus()
	return self.armor_bonus
end

function modifier_custom_frost_armor:GetModifierMagicalResistanceBonus()
	return self.magical_resistance
end

modifier_custom_frost_armor_slow = class({})
function modifier_custom_frost_armor_slow:IsHidden() return false end
function modifier_custom_frost_armor_slow:IsDebuff() return true end
function modifier_custom_frost_armor_slow:IsPurgable() return true end
function modifier_custom_frost_armor_slow:RemoveOnDeath() return true end
function modifier_custom_frost_armor_slow:GetTexture()
    return "ability_custom_frost_armor"
end

function modifier_custom_frost_armor_slow:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_custom_frost_armor_slow:OnCreated(params)
	self.slow_attack_speed = 0
	self.slow_movement_speed = 0
    
    if not IsServer() then return end

    self.slow_attack_speed = params.slow_attack_speed
	self.slow_movement_speed = params.slow_movement_speed
end

function modifier_custom_frost_armor_slow:GetModifierAttackSpeedBonus_Constant()
	return self.slow_attack_speed * (-1)
end

function modifier_custom_frost_armor_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.slow_movement_speed * (-1)
end

function modifier_custom_frost_armor_slow:GetEffectName()
    return "particles/units/heroes/hero_lich/lich_slowed_cold.vpcf"
end

function modifier_custom_frost_armor_slow:GetStatusEffectName()  
    return "particles/status_fx/status_effect_frost_lich.vpcf"
end