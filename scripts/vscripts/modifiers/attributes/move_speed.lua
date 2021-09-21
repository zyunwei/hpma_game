modifier_custom_attribute_move_speed = class({})

local public = modifier_custom_attribute_move_speed

--------------------------------------------------------------------------------

function public:IsDebuff()
	return false
end

--------------------------------------------------------------------------------

function public:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function public:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function public:RemoveOnDeath()
	return false
end

--------------------------------------------------------------------------------

function public:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}
end

--------------------------------------------------------------------------------

function public:GetModifierMoveSpeedBonus_Constant()
	return self:GetStackCount()
end

function public:OnStackCountChanged()
	if IsServer then
		if self.CurrentStackCount ~= self:GetStackCount() then
			local hero = self:GetCaster()
			if hero ~= nil and hero:IsNull() == false and hero.CalculateStatBonus then
				hero:CalculateStatBonus(false)
			end
		end

		self.CurrentStackCount = self:GetStackCount()
	end
end