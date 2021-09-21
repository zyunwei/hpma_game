ability_custom_shuriken = ability_custom_shuriken or class({})

function ability_custom_shuriken:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if IsNull(caster)  then return end

    local mainModifierName = "modifier_ability_custom_shuriken"

    if caster:HasModifier(mainModifierName) then
        caster:RemoveModifierByName(mainModifierName)
    end

    local modifier = caster:AddNewModifier(caster, self, mainModifierName, {})
    if NotNull(modifier) then
		modifier:SetStackCount(self:GetSpecialValueFor("init_count"))
    end
end

LinkLuaModifier("modifier_ability_custom_shuriken", "abilities/custom/ability_custom_shuriken", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_custom_shuriken_stacks", "abilities/custom/ability_custom_shuriken", LUA_MODIFIER_MOTION_NONE)

modifier_ability_custom_shuriken_stacks = class({})
function modifier_ability_custom_shuriken_stacks:IsHidden() return false end
function modifier_ability_custom_shuriken_stacks:IsDebuff() return false end
function modifier_ability_custom_shuriken_stacks:IsPurgable() return false end
function modifier_ability_custom_shuriken_stacks:RemoveOnDeath() return false end
function modifier_ability_custom_shuriken_stacks:GetTexture()
    return "ability_custom_shuriken"
end

function modifier_ability_custom_shuriken_stacks:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOOLTIP
	}
end

function modifier_ability_custom_shuriken_stacks:OnTooltip()
    return 25
end

modifier_ability_custom_shuriken = class({})
function modifier_ability_custom_shuriken:IsHidden() return false end
function modifier_ability_custom_shuriken:IsDebuff() return false end
function modifier_ability_custom_shuriken:IsPurgable() return false end
function modifier_ability_custom_shuriken:RemoveOnDeath() return true end
function modifier_ability_custom_shuriken:GetTexture()
    return "ability_custom_shuriken"
end

function modifier_ability_custom_shuriken:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_ability_custom_shuriken:OnAttackLanded(params)
	if not IsServer() then return end

	local parent = self:GetParent()
	local attacker = params.attacker
	local target = params.target
	if IsNull(parent) or IsNull(attacker) or IsNull(target) then return end

	if attacker ~= parent then return end
	if attacker:GetTeam() == target:GetTeam() then return end

	local ability = self:GetAbility()
	if IsNull(ability) then return end
	
	local particle_projectile = "particles/units/heroes/hero_bounty_hunter/bounty_hunter_suriken_toss.vpcf"
	local sound_cast = "Hero_BountyHunter.Shuriken"

	EmitSoundOn(sound_cast, parent)

	local base_damage = ability:GetSpecialValueFor("base_damage")
    local affixAttr = parent:GetCustomAttribute("shuriken")
    if affixAttr and affixAttr > 0 then
        base_damage = base_damage + affixAttr
    end

	local projectile_info = {
		Target = target,
		Source = parent,
		Ability = ability,
        EffectName = particle_projectile,
        iMoveSpeed = 1000,
        bDodgeable = false,
        vSpawnOrigin = parent:GetAbsOrigin(),
        bHasFrontalCone = false,
        bVisibleToEnemies = true,
		bReplaceExisting = false,
        bProvidesVision = false,
        ExtraData = {
			stun_duration = ability:GetSpecialValueFor("stun_duration"),
			base_damage = base_damage,
			stack_damage = ability:GetSpecialValueFor("stack_damage"),
        },
    }

    ProjectileManager:CreateTrackingProjectile(projectile_info)

    self:DecrementStackCount()
    if self:GetStackCount() <= 0 then
		parent:RemoveModifierByName("modifier_ability_custom_shuriken")

		local stackModifierName = "modifier_ability_custom_shuriken_stacks"
		local stackModifier = parent:FindModifierByName(stackModifierName)
		if stackModifier ~= nil then
			stackModifier:IncrementStackCount()
		else
			stackModifier = parent:AddNewModifier(parent, nil, stackModifierName, {})
			if stackModifier ~= nil then
				stackModifier:SetStackCount(1)
			end
		end
	end
end

function ability_custom_shuriken:OnProjectileHit_ExtraData(target, location, extra_data)
	if not IsServer() then return end
	if IsNull(target) then
		return nil
	end

	target:AddNewModifier(caster, self, "modifier_stunned", {duration = extra_data.stun_duration * (1 - target:GetStatusResistance())})

	local caster = self:GetCaster()
	if IsNull(caster) then
		return nil
	end

	local damage = extra_data.base_damage
	local stackModifierName = "modifier_ability_custom_shuriken_stacks"
	local stackModifier = caster:FindModifierByName(stackModifierName)
	if stackModifier ~= nil then
		damage = damage + stackModifier:GetStackCount() * extra_data.stack_damage
	end

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self
	}

	ApplyDamage(damageTable)
end
