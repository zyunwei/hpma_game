ability_custom_beimingshengong = ability_custom_beimingshengong or class({})

LinkLuaModifier("modifier_ability_custom_beimingshengong", "abilities/custom/ability_custom_beimingshengong", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_custom_beimingshengong_permanent_buff", "abilities/custom/ability_custom_beimingshengong", LUA_MODIFIER_MOTION_NONE)

modifier_ability_custom_beimingshengong						= class({})
modifier_ability_custom_beimingshengong_permanent_buff		= class({})

function modifier_ability_custom_beimingshengong:IsHidden() return false end
function modifier_ability_custom_beimingshengong:IsDebuff() return false end
function modifier_ability_custom_beimingshengong:IsPurgable() return false end
function modifier_ability_custom_beimingshengong:RemoveOnDeath() return true end

function modifier_ability_custom_beimingshengong_permanent_buff:IsHidden() return false end
function modifier_ability_custom_beimingshengong_permanent_buff:IsDebuff() return false end
function modifier_ability_custom_beimingshengong_permanent_buff:IsPurgable() return false end
function modifier_ability_custom_beimingshengong_permanent_buff:RemoveOnDeath() return false end
function modifier_ability_custom_beimingshengong_permanent_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_TOOLTIP,
	}
end

function modifier_ability_custom_beimingshengong_permanent_buff:GetModifierBonusStats_Strength()
	return self:GetStackCount()
end

function modifier_ability_custom_beimingshengong_permanent_buff:GetModifierBonusStats_Agility()
	return self:GetStackCount()
end

function modifier_ability_custom_beimingshengong_permanent_buff:GetModifierBonusStats_Intellect()
	return self:GetStackCount()
end

function modifier_ability_custom_beimingshengong_permanent_buff:OnTooltip()
	return self:GetStackCount()
end

function modifier_ability_custom_beimingshengong_permanent_buff:GetTexture()
	return "ability_custom_beimingshengong"
end

function ability_custom_beimingshengong:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster)  then return end

	local mainModifierName = "modifier_ability_custom_beimingshengong"

	if caster:HasModifier(mainModifierName) then
		caster:RemoveModifierByName(mainModifierName)
	end

	caster:AddNewModifier(caster, nil, mainModifierName, {
		buff_duration = self:GetSpecialValueFor("duration"),
		debuff_duration = self:GetSpecialValueFor("debuff_duration"),
	})
end

function modifier_ability_custom_beimingshengong:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_ability_custom_beimingshengong:GetTexture()
	return "ability_custom_beimingshengong"
end

function modifier_ability_custom_beimingshengong:OnCreated(params)
	if not IsServer() then return end
	self.duration = params.buff_duration
	self.debuff_duration = params.debuff_duration
end

function modifier_ability_custom_beimingshengong:OnAttackLanded(keys)
	if not IsServer() then return end

	local parent = self:GetParent()
	local attacker = keys.attacker
	local target = keys.target
	if IsNull(parent) or IsNull(attacker) or IsNull(target) then return end

	if attacker ~= parent then return end
	if target.IsRealHero == nil or target:IsRealHero() == false then return end
	if attacker:GetTeam() == target:GetTeam() then return end

	if self:GetDuration() == -1 then
		self:SetDuration(self.duration, true)
	end

	self.shift_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_essence_shift.vpcf", PATTACH_POINT_FOLLOW, target)
	ParticleManager:ReleaseParticleIndex(self.shift_particle)

	local permanent_buff_name = "modifier_ability_custom_beimingshengong_permanent_buff"
	local permanent_debuff_name = "modifier_ability_custom_huagongdafa_permanent_debuff"

	local permanent_buff = parent:FindModifierByName(permanent_buff_name)
	local permanent_debuff = target:FindModifierByName(permanent_debuff_name)

	if permanent_buff == nil then
		permanent_buff = parent:AddNewModifier(parent, nil, permanent_buff_name, {duration = self.debuff_duration})
	end

	if permanent_debuff == nil then
		permanent_debuff = target:AddNewModifier(parent, nil, permanent_debuff_name, {duration = self.debuff_duration})
	end

	if permanent_buff ~= nil then
		permanent_buff:IncrementStackCount()
		permanent_buff:ForceRefresh()
	end

	if permanent_debuff ~= nil then
		permanent_debuff:IncrementStackCount()
		permanent_debuff:ForceRefresh()
	end
end
