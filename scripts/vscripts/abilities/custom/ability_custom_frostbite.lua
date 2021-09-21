ability_custom_frostbite = ability_custom_frostbite or class({})

LinkLuaModifier("modifier_ability_custom_frostbite", "abilities/custom/ability_custom_frostbite", LUA_MODIFIER_MOTION_HORIZONTAL)

function ability_custom_frostbite:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end

	local radius = self:GetSpecialValueFor("radius")
	local target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
	local target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
	local target_flags = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE

	local duration = self:GetSpecialValueFor("duration")
	local stun_duration = self:GetSpecialValueFor("stun_duration")

	local enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, target_team, target_type, target_flags, FIND_CLOSEST, false)
    for _, enemy in pairs(enemies) do
		if NotNull(enemy) then
			local projectile_info = {
				EffectName = "particles/units/heroes/hero_crystalmaiden/maiden_frostbite.vpcf",
				Ability = self,
				vSpawnOrigin = caster:GetAbsOrigin(),
				Target = enemy,
				Source = caster,
				bHasFrontalCone = false,
				iMoveSpeed = 2000,
				bReplaceExisting = false,
				bProvidesVision = false
			}
			ProjectileManager:CreateTrackingProjectile(projectile_info)

			local resistance = enemy:GetStatusResistance()
			enemy:AddNewModifier(caster, self, "modifier_stunned", {duration = stun_duration * (1 - resistance)})
			enemy:AddNewModifier(caster, self, "modifier_ability_custom_frostbite", {duration = duration * (1 - resistance)})
		end
    end
end

modifier_ability_custom_frostbite = class({})

function modifier_ability_custom_frostbite:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_INVISIBLE] = false
	}
end

function modifier_ability_custom_frostbite:IsHidden() return false end
function modifier_ability_custom_frostbite:IsDebuff() return true end
function modifier_ability_custom_frostbite:IsPurgable() return true end
function modifier_ability_custom_frostbite:RemoveOnDeath() return true end
function modifier_ability_custom_frostbite:GetTexture()
    return "ability_custom_frostbite"
end

function modifier_ability_custom_frostbite:OnCreated()
	if not IsServer() then return end

	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.parent = self:GetParent()

	if IsNull(self.ability) or IsNull(self.parent) or IsNull(self.caster) then return end

	self.damage_interval = self.ability:GetSpecialValueFor("damage_interval")
	self.damage = self.ability:GetSpecialValueFor("damage")

	self:OnIntervalThink()
	self.parent:EmitSound("Hero_Crystal.Frostbite")
	self:StartIntervalThink(self.damage_interval)
end

function modifier_ability_custom_frostbite:OnIntervalThink()
	if not IsServer() then return end

	ApplyDamage({
		attacker = self.caster,
		victim = self.parent,
		ability = self.ability,
		damage = self.damage,
		damage_type = DAMAGE_TYPE_MAGICAL
	})
end

function modifier_ability_custom_frostbite:GetEffectName()
	return "particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf"
end

function modifier_ability_custom_frostbite:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
