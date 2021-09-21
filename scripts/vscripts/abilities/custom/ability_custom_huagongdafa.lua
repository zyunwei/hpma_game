ability_custom_huagongdafa = ability_custom_huagongdafa or class({})

LinkLuaModifier("modifier_ability_custom_huagongdafa", "abilities/custom/ability_custom_huagongdafa", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_custom_huagongdafa_permanent_debuff", "abilities/custom/ability_custom_huagongdafa", LUA_MODIFIER_MOTION_NONE)

modifier_ability_custom_huagongdafa						= class({})
modifier_ability_custom_huagongdafa_permanent_debuff	= class({})

function modifier_ability_custom_huagongdafa:IsHidden() return false end
function modifier_ability_custom_huagongdafa:IsDebuff() return false end
function modifier_ability_custom_huagongdafa:IsPurgable() return false end
function modifier_ability_custom_huagongdafa:RemoveOnDeath() return true end

function modifier_ability_custom_huagongdafa_permanent_debuff:IsHidden() return false end
function modifier_ability_custom_huagongdafa_permanent_debuff:IsDebuff() return true end
function modifier_ability_custom_huagongdafa_permanent_debuff:IsPurgable() return false end
function modifier_ability_custom_huagongdafa_permanent_debuff:RemoveOnDeath() return false end
function modifier_ability_custom_huagongdafa_permanent_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_TOOLTIP,
	}
end

function modifier_ability_custom_huagongdafa_permanent_debuff:GetModifierBonusStats_Strength()
	return -self:GetStackCount()
end

function modifier_ability_custom_huagongdafa_permanent_debuff:GetModifierBonusStats_Agility()
	return -self:GetStackCount()
end

function modifier_ability_custom_huagongdafa_permanent_debuff:GetModifierBonusStats_Intellect()
	return -self:GetStackCount()
end

function modifier_ability_custom_huagongdafa_permanent_debuff:OnTooltip()
	return -self:GetStackCount()
end

function modifier_ability_custom_huagongdafa_permanent_debuff:GetTexture()
	return "ability_custom_huagongdafa"
end

function ability_custom_huagongdafa:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster)  then return end

	local mainModifierName = "modifier_ability_custom_huagongdafa"

	if caster:HasModifier(mainModifierName) then
		caster:RemoveModifierByName(mainModifierName)
	end

	caster:AddNewModifier(caster, nil, mainModifierName, {
		buff_duration = self:GetSpecialValueFor("duration"),
		debuff_duration = self:GetSpecialValueFor("debuff_duration"),
	})
end

function ability_custom_huagongdafa:OnFold()
	local caster = self:GetCaster()
	if IsNull(caster)  then return end

	if caster:HasModifier("modifier_bulaochangchun") then
		CardGroupSystem:ReplaceCard(caster:GetPlayerID(), "ability_custom_huagongdafa", "ability_custom_beimingshengong", true)
	end
end

function modifier_ability_custom_huagongdafa:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_ability_custom_huagongdafa:GetTexture()
	return "ability_custom_huagongdafa"
end

function modifier_ability_custom_huagongdafa:OnCreated(params)
	if not IsServer() then return end
	self.duration = params.buff_duration
	self.debuff_duration = params.debuff_duration
end

function modifier_ability_custom_huagongdafa:OnAttackLanded(keys)
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

	local permanent_debuff_name = "modifier_ability_custom_huagongdafa_permanent_debuff"
	local permanent_debuff = target:FindModifierByName(permanent_debuff_name)

	if permanent_debuff == nil then
		permanent_debuff = target:AddNewModifier(parent, nil, permanent_debuff_name, {duration = self.debuff_duration})
	end

	if permanent_debuff ~= nil then
		permanent_debuff:IncrementStackCount()
		permanent_debuff:ForceRefresh()
	end
end
