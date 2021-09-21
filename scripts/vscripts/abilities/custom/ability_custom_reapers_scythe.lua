ability_custom_reapers_scythe = ability_custom_reapers_scythe or class({})

LinkLuaModifier("modifier_ability_custom_reapers_scythe", "abilities/custom/ability_custom_reapers_scythe", LUA_MODIFIER_MOTION_NONE)

function ability_custom_reapers_scythe:OnSpellStart()
	local caster = self:GetCaster()
	if IsNull(caster) then
		return
	end
	local search_radius = self:GetCastRange(vec3_invalid, nil)
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
										caster:GetAbsOrigin(),
										nil,
										search_radius,
										DOTA_UNIT_TARGET_TEAM_ENEMY,
										DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
										DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,
										FIND_CLOSEST,
										false)

	caster:EmitSound("Hero_Necrolyte.ReapersScythe.Cast")

	local stun_duration = 1.5 -- 和特效相关，固定数值
	for _, enemy in pairs(enemies) do
		if NotNull(enemy) then
			enemy:AddNewModifier(caster, self, "modifier_ability_custom_reapers_scythe", {duration = stun_duration})
			enemy:EmitSound("Hero_Necrolyte.ReapersScythe.Target")
		end
	end
end

modifier_ability_custom_reapers_scythe = class({})

function modifier_ability_custom_reapers_scythe:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetParent()
		self.ability = self:GetAbility()

		if IsNull(caster) or IsNull(target) or IsNull(self.ability) then
			return
		end

		self.damage = self.ability:GetSpecialValueFor("damage_per_health")

		local stun_fx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_stunned.vpcf", PATTACH_OVERHEAD_FOLLOW, target)
		self:AddParticle(stun_fx, false, false, -1, false, false)
		local orig_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_necrolyte/necrolyte_scythe_orig.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		self:AddParticle(orig_fx, false, false, -1, false, false)

		local scythe_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_necrolyte/necrolyte_scythe_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(scythe_fx, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(scythe_fx, 1, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(scythe_fx)
	end
end

function modifier_ability_custom_reapers_scythe:GetEffectName()
	return "particles/units/heroes/hero_necrolyte/necrolyte_scythe.vpcf"
end

function modifier_ability_custom_reapers_scythe:StatusEffectPriority()
	return MODIFIER_PRIORITY_ULTRA
end

function modifier_ability_custom_reapers_scythe:GetPriority()
	return MODIFIER_PRIORITY_ULTRA
end

function modifier_ability_custom_reapers_scythe:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_ability_custom_reapers_scythe:CheckState()
	local state =
		{
			[MODIFIER_STATE_STUNNED] = true
		}
	return state
end

function modifier_ability_custom_reapers_scythe:IsPurgable() return false end
function modifier_ability_custom_reapers_scythe:IsPurgeException() return false end

function modifier_ability_custom_reapers_scythe:DeclareFunctions()
	local decFuncs =
		{
			MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		}
	return decFuncs
end

function modifier_ability_custom_reapers_scythe:GetOverrideAnimation()
	return ACT_DOTA_DISABLED
end

function modifier_ability_custom_reapers_scythe:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetParent()

		if IsNull(caster) or IsNull(target) or IsNull(self.ability) then
			return
		end
		
		target:AddNewModifier(caster, self.ability, "modifier_stunned", {duration=FrameTime()})
		
		if target:IsAlive() then
			self.damage = self.damage * (target:GetMaxHealth() - target:GetHealth())

			local actually_dmg = ApplyDamage({attacker = caster, victim = target, ability = self.ability, damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL})
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_DAMAGE, target, actually_dmg, nil)
		end
	end
end
