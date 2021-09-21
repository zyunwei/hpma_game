ability_custom_aphotic_shield = ability_custom_aphotic_shield or class({})

LinkLuaModifier("modifier_ability_custom_aphotic_shield_buff", "abilities/custom/ability_custom_aphotic_shield", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_custom_aphotic_shield", "abilities/custom/ability_custom_aphotic_shield", LUA_MODIFIER_MOTION_NONE)

function ability_custom_aphotic_shield:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
    local modifierParams = {
        buff_duration = self:GetSpecialValueFor("duration"),
        block_damage = self:GetSpecialValueFor("block_damage"),
    }

    local affixAttr = self:GetCaster():GetCustomAttribute("wuguang")
    if affixAttr and affixAttr > 0 then
        modifierParams.block_damage = modifierParams.block_damage + affixAttr
    end

    EmitSoundOn("Hero_Abaddon.AphoticShield.Cast", caster)
    caster:AddNewModifier(caster, nil, "modifier_ability_custom_aphotic_shield", modifierParams)
end

modifier_ability_custom_aphotic_shield = class({})


function modifier_ability_custom_aphotic_shield:IsHidden() return false end
function modifier_ability_custom_aphotic_shield:IsDebuff() return false end
function modifier_ability_custom_aphotic_shield:IsPurgable() return false end
function modifier_ability_custom_aphotic_shield:RemoveOnDeath() return true end

function modifier_ability_custom_aphotic_shield:GetTexture()
	return "ability_custom_aphotic_shield"
end

function modifier_ability_custom_aphotic_shield:OnCreated(params)
    if IsServer() then
        self.block_damage = params.block_damage or 350
        self.buff_duration = params.buff_duration or 15
        self:StartIntervalThink(0.5)
    end
end

function modifier_ability_custom_aphotic_shield:OnIntervalThink()
    local parent = self:GetParent()
    if NotNull(parent) then
        if parent:IsStunned() then
            local modifierParams = {
                duration = self.buff_duration,
                block_damage = self.block_damage,
            }
            parent:AddNewModifier(parent, nil, "modifier_ability_custom_aphotic_shield_buff", modifierParams)
            parent:Purge(false, true, false, true, true)
            self:Destroy()
        end
    end
end

modifier_ability_custom_aphotic_shield_buff = class({})

function modifier_ability_custom_aphotic_shield_buff:IsHidden() return false end
function modifier_ability_custom_aphotic_shield_buff:IsDebuff() return false end
function modifier_ability_custom_aphotic_shield_buff:IsPurgable() return false end
function modifier_ability_custom_aphotic_shield_buff:RemoveOnDeath() return true end

function modifier_ability_custom_aphotic_shield_buff:GetTexture()
	return "ability_custom_aphotic_shield"
end

function modifier_ability_custom_aphotic_shield_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
	}
end

function modifier_ability_custom_aphotic_shield_buff:OnCreated(params)
    if not IsServer() then return end
    local parent = self:GetParent()
    if IsNull(parent) then return end
    local parent_origin = parent:GetAbsOrigin()
    local shield_size = parent:GetModelRadius() * 0.7
    self.block_damage = params.block_damage or 350
    self.shield_damage = 0
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_aphotic_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
    local common_vector = Vector(shield_size,0,shield_size)
    ParticleManager:SetParticleControl(particle, 1, common_vector)
    ParticleManager:SetParticleControl(particle, 2, common_vector)
    ParticleManager:SetParticleControl(particle, 4, common_vector)
    ParticleManager:SetParticleControl(particle, 5, Vector(shield_size,0,0))

    ParticleManager:SetParticleControlEnt(particle, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent_origin, true)
    self:AddParticle(particle, false, false, -1, false, false)
end

function modifier_ability_custom_aphotic_shield_buff:GetModifierTotal_ConstantBlock(keys)
	local parent = self:GetParent()
	local attacker = keys.attacker
	local target = keys.target
    local damage = keys.damage
	if IsNull(parent) or IsNull(attacker) or IsNull(target) then return end

    if target ~= parent then return end

    local remainBlockDamage = self.block_damage

    if damage <= self.block_damage then
        self.block_damage = self.block_damage - damage
        self.shield_damage = self.shield_damage + damage
        return damage
    else
        self.shield_damage = self.shield_damage + remainBlockDamage
        self:Destroy()
        return remainBlockDamage
    end
end

function modifier_ability_custom_aphotic_shield_buff:OnDestroy()
    if not IsServer() then return end
    local parent = self:GetParent()
    local radius = 500
    local explode_target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
    local explode_target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
    local parent_origin	= parent:GetAbsOrigin()

    parent:EmitSound("Hero_Abaddon.AphoticShield.Destroy")

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_aphotic_shield_explosion.vpcf", PATTACH_ABSORIGIN, parent)
    ParticleManager:SetParticleControl(particle, 0, parent_origin)
    ParticleManager:ReleaseParticleIndex(particle)

    local units = FindUnitsInRadius(parent:GetTeamNumber(), parent_origin, nil, radius, explode_target_team, explode_target_type, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    for _, unit in pairs(units) do
        if NotNull(unit) then
            ApplyDamage({ victim = unit, attacker = parent, damage = self.shield_damage, damage_type = DAMAGE_TYPE_MAGICAL })
            particle = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_aphotic_shield_hit.vpcf", PATTACH_POINT, unit)
            ParticleManager:SetParticleControlEnt(particle, 0, unit, PATTACH_POINT, "attach_hitloc", unit:GetAbsOrigin(), true)
            local hit_size = unit:GetModelRadius() * 0.3
            ParticleManager:SetParticleControl(particle, 1, Vector(hit_size, hit_size, hit_size))
            ParticleManager:ReleaseParticleIndex(particle)
        end
    end

end