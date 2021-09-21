modifier_custom_attributes = class({})

local public = modifier_custom_attributes

local attrs = {
	'health',
	'health_regen',
	'strength',
	'agility',
	'intellect',
	'mana',
	'armor',
	'mana_regen',
	'attack_speed',
	'move_speed',
	'damage_outgoing',
	'incoming_damage',
	'health_regen_percentage',
	'magic_armor',
	'attack_damage',
	'spell_amp',
	'mana_regen_percentage',
	'status_resistance',
}
for i,v in ipairs(attrs) do
	LinkLuaModifier("modifier_custom_attribute_"..v, "modifiers/attributes/"..v,LUA_MODIFIER_MOTION_NONE)
end

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

function public:OnCreated(keys)
	self:StartIntervalThink(0.5)
end

--------------------------------------------------------------------------------

function public:OnIntervalThink()
	if IsServer() then
		local parent = self:GetParent()
		if parent:IsIllusion() and not parent:IsAlive() then return self:Destroy() end

		if parent.IsPet then
			self:Destroy()
			return
		end

		for k,v in pairs(parent:GetAllCustomAttribute()) do
			if k == 'hp' then
				self:SetCustomAttribute( 'health', v )
			elseif k == 'health_regen' then
				self:SetCustomAttribute( 'health_regen', v )
			elseif k == 'str' then
				self:SetCustomAttribute( 'strength', v )
			elseif k == 'agi' then
				self:SetCustomAttribute( 'agility', v )
			elseif k == 'int' then
				self:SetCustomAttribute( 'intellect', v )
			elseif k == 'mana' then
				self:SetCustomAttribute( 'mana', v )
			elseif k == 'armor' then
				self:SetCustomAttribute( 'armor', v )
			elseif k == 'mana_regen' then
				self:SetCustomAttribute( 'mana_regen', v )
			elseif k == 'attack_speed' then
				self:SetCustomAttribute( 'attack_speed', v )
			elseif k == 'move_speed' then
				self:SetCustomAttribute( 'move_speed', v )
			elseif k == 'damage_outgoing' then
				self:SetCustomAttribute( 'damage_outgoing', v )
			elseif k == 'incoming_damage' then
				self:SetCustomAttribute( 'incoming_damage', v )
			elseif k == 'health_regen_pct' then
				self:SetCustomAttribute( 'health_regen_percentage', v )
			elseif k == 'magic_armor' then
				self:SetCustomAttribute( 'magic_armor', v )
			elseif k == 'attack_damage' then
				self:SetCustomAttribute( 'attack_damage', v)
			elseif k == 'spell_amp' then
				self:SetCustomAttribute( 'spell_amp', v)
			elseif k == 'mana_regen_pct' then
				self:SetCustomAttribute('mana_regen_percentage', v)
			elseif k == 'status_resistance' then 
				self:SetCustomAttribute('status_resistance', v)
			end
		end
	end
end

function public:SetCustomAttribute( name, count )
	local parent = self:GetParent()
	local modifierName = 'modifier_custom_attribute_'..name
	local modifier = parent:FindModifierByName(modifierName)
	if modifier then
		modifier:SetStackCount(count)
	else
		local modifier = parent:AddNewModifier( parent, nil, modifierName, nil )
		if modifier then
			modifier:SetStackCount(count)
		end
	end
end

function public:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_COOLDOWN_REDUCTION_CONSTANT,
	}
end

function public:GetModifierCooldownReduction_Constant(keys)
	if not IsServer() then return end
	local parent = self:GetParent()
    local ability = keys.ability
	if NotNull(ability) then 
		return parent:GetAbilityCooldownReduction(ability:GetName())
	end
end

function public:GetModifierIgnoreMovespeedLimit()
	return 1
end
