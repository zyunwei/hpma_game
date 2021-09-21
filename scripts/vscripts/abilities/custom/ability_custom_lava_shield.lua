ability_custom_lava_shield = ability_custom_lava_shield or class({})

LinkLuaModifier("modifier_ability_custom_lava_shield_buff", "abilities/custom/ability_custom_lava_shield", LUA_MODIFIER_MOTION_NONE)

function ability_custom_lava_shield:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
    local modifierParams = {
        duration = self:GetSpecialValueFor("duration"),
        block_damage = self:GetSpecialValueFor("block_damage"),
        bounce_damage = self:GetSpecialValueFor("bounce_damage"),
    }

    EmitSoundOn("Hero_Abaddon.AphoticShield.Cast", caster)
    caster:AddNewModifier(caster, nil, "modifier_ability_custom_lava_shield_buff", modifierParams)
end

modifier_ability_custom_lava_shield_buff = class({})

function modifier_ability_custom_lava_shield_buff:IsHidden() return false end
function modifier_ability_custom_lava_shield_buff:IsDebuff() return false end
function modifier_ability_custom_lava_shield_buff:IsPurgable() return false end
function modifier_ability_custom_lava_shield_buff:RemoveOnDeath() return true end

function modifier_ability_custom_lava_shield_buff:GetTexture()
	return "ability_custom_lava_shield"
end

function modifier_ability_custom_lava_shield_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
        MODIFIER_EVENT_ON_ATTACKED,
	}
end

function modifier_ability_custom_lava_shield_buff:OnCreated(params)
    if not IsServer() then return end
    local parent = self:GetParent()
    if IsNull(parent) then return end
    self.block_damage = params.block_damage or 240
    self.bounce_damage = params.bounce_damage or 60
    local particle = ParticleManager:CreateParticle("particles/econ/courier/courier_roshan_lava/courier_roshan_lava.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
    ParticleManager:SetParticleControl(particle, 0, parent:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 15, Vector(255, 255, 255))
    self:AddParticle(particle, false, false, -1, false, false)
end

function modifier_ability_custom_lava_shield_buff:GetModifierTotal_ConstantBlock(keys)
	local parent = self:GetParent()
	local attacker = keys.attacker
	local target = keys.target
    local damage = keys.damage
	if IsNull(parent) or IsNull(attacker) or IsNull(target) then return end

    if target ~= parent then return end

    local remainBlockDamage = self.block_damage

    if damage <= self.block_damage then
        self.block_damage = self.block_damage - damage
        return damage
    else
        self:Destroy()
        return remainBlockDamage
    end
end

function modifier_ability_custom_lava_shield_buff:OnAttacked(keys)
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = keys.target
    local attacker = keys.attacker
    if IsNull(parent) or IsNull(target) or IsNull(attacker) then return end
    if parent ~= target then return end
    local damageTable = {
        victim = attacker,
        attacker = parent,
        damage = self.bounce_damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
    }
    ApplyDamage(damageTable)

    local particle = ParticleManager:CreateParticle("particles/econ/items/clinkz/clinkz_ti9_immortal/clinkz_ti9_summon_end_lava.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
    ParticleManager:SetParticleControl(particle, 0, attacker:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)
end
