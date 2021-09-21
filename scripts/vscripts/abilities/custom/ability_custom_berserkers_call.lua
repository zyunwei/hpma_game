ability_custom_berserkers_call = ability_custom_berserkers_call or class({})

LinkLuaModifier("modifier_ability_custom_berserkers_call", "abilities/custom/ability_custom_berserkers_call", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_custom_berserkers_call_debuff", "abilities/custom/ability_custom_berserkers_call", LUA_MODIFIER_MOTION_NONE)

function ability_custom_berserkers_call:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
	local ability = self
	local radius = ability:GetSpecialValueFor("radius")

	local responses_1_or_more_enemies = "axe_axe_ability_berserk_0" .. math.random(1, 9)
	local responses_zero_enemy = "axe_axe_anger_0" .. math.random(1, 3)

	local particle = ParticleManager:CreateParticle("particles/econ/items/axe/axe_helm_shoutmask/axe_beserkers_call_owner_shoutmask.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 2, Vector(radius, radius, radius))
	ParticleManager:ReleaseParticleIndex(particle)

	local enemies_in_radius = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

	for _, target in pairs(enemies_in_radius) do
		if NotNull(target) then
			if IsAlive(target) then
				if target:IsCreep() then
					target:SetForceAttackTarget(caster)
					target:MoveToTargetToAttack(caster)
				else
					target:Stop()
					target:Interrupt()

					local newOrder = {
						UnitIndex = target:entindex(),
						OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
						TargetIndex = caster:entindex()
					}

					ExecuteOrderFromTable(newOrder)
				end
				target:AddNewModifier(caster, self, "modifier_ability_custom_berserkers_call_debuff", {duration = ability:GetSpecialValueFor("duration") * (1 - target:GetStatusResistance())})
			end
		end
	end

	if next (enemies_in_radius) == nil then
		caster:EmitSound(responses_zero_enemy)
	else
		caster:EmitSound(responses_1_or_more_enemies)
	end

	caster:AddNewModifier(caster, self, "modifier_ability_custom_berserkers_call", {duration = ability:GetSpecialValueFor("duration")})

	caster:ModifyCustomAttribute("armor", "ability_custom_berserkers_call", 0.1)
end

modifier_ability_custom_berserkers_call = class({})

function modifier_ability_custom_berserkers_call:IsHidden() return false end
function modifier_ability_custom_berserkers_call:IsDebuff() return false end
function modifier_ability_custom_berserkers_call:IsPurgable() return false end
function modifier_ability_custom_berserkers_call:RemoveOnDeath() return true end
function modifier_ability_custom_berserkers_call:GetTexture()
    return "ability_custom_berserkers_call"
end

function modifier_ability_custom_berserkers_call:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end

function modifier_ability_custom_berserkers_call:GetModifierPhysicalArmorBonus()
	local ability = self:GetAbility()
	if IsNull(ability) then return 0 end
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_ability_custom_berserkers_call:OnCreated()
	if not IsServer() then return end
	local caster = self:GetCaster()
	if IsNull(caster) then return end

	local caster_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_beserkers_call_owner.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(caster_particle, 2, Vector(0, 0, 0))
	ParticleManager:ReleaseParticleIndex(caster_particle)
end

function modifier_ability_custom_berserkers_call:GetStatusEffectName()
	return "particles/status_fx/status_effect_gods_strength.vpcf"
end

modifier_ability_custom_berserkers_call_debuff = class({})

function modifier_ability_custom_berserkers_call_debuff:IsHidden() return false end
function modifier_ability_custom_berserkers_call_debuff:IsDebuff() return true end
function modifier_ability_custom_berserkers_call_debuff:IsPurgable() return false end
function modifier_ability_custom_berserkers_call_debuff:RemoveOnDeath() return true end
function modifier_ability_custom_berserkers_call_debuff:GetTexture()
    return "ability_custom_berserkers_call"
end

function modifier_ability_custom_berserkers_call_debuff:OnCreated()
	if IsNull(self:GetAbility()) then self:Destroy() return end
end

function modifier_ability_custom_berserkers_call_debuff:CheckState()
	return {[MODIFIER_STATE_COMMAND_RESTRICTED] = true}
end

function modifier_ability_custom_berserkers_call_debuff:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH
	}
end

function modifier_ability_custom_berserkers_call_debuff:OnDeath(event)
	if IsServer() then
		local caster = self:GetCaster()
		if IsNull(caster) then return end
		if event.unit == caster then
			self:Destroy()
		end
	end
end

function modifier_ability_custom_berserkers_call_debuff:OnDestroy()
	if IsServer() then
		local parent = self:GetParent()
		if IsNull(parent) then return end
		if IsAlive(parent) and parent:IsCreep() then
			parent:SetForceAttackTarget(nil)
		end
	end
end

function modifier_ability_custom_berserkers_call_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_beserkers_call.vpcf"
end

function modifier_ability_custom_berserkers_call_debuff:StatusEffectPriority()
	return 10
end
