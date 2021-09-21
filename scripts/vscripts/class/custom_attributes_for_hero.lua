
--@class CDOTA_BaseNPC_Hero

local public = CDOTA_BaseNPC_Hero

-- 设置子属性
function public:SetCustomAttribute(name, childKey, value)
	local children = self:GetCustomAttributeChildren(name)
	children[childKey] = value
end

function public:GetConsumableUseCount(consumableName)
	self.__ConsumableUseCount = self.__ConsumableUseCount or {}
	local count = self.__ConsumableUseCount[consumableName]
	if count == nil then 
		self.__ConsumableUseCount[consumableName] = 0
	end
	return self.__ConsumableUseCount[consumableName]
end

function public:AddConsumableUseCount(consumableName)
	local count = self:GetConsumableUseCount(consumableName)
	self.__ConsumableUseCount[consumableName] = count + 1
	-- local weaken = 100 - (math.pow(0.95, count + 1) * 100)
	-- self:ShowCustomMessage({
	-- 	type="message-box", 
	-- 	role="xxwar_system_notification",
	-- 	list={{text={"DOTA_Tooltip_Ability_"..consumableName, "xxwar_weaken_attribute", string.format("%.2f", weaken), "%"}, args={}}},
	-- })
end

-- 修改子属性
function public:ModifyCustomAttribute(name, childKey, value)
	local oldValue = self:GetCustomAttributeChild(name, childKey)
	local children = self:GetCustomAttributeChildren(name)
	if string.find(childKey, "item_consumable") == 1 then
		local count = self:GetConsumableUseCount(childKey)
		value = value * math.pow(0.90, count)
		self:ShowCustomMessage({
			type="message-box", 
			role="xxwar_system_notification",
			list={{text={"xxwar_get", "DOTA_Tooltip_Ability_"..childKey, ",", name, "+", string.format("%.2f", value)}, args={}}},
		})
	end
	local newValue = oldValue + value
	if name == "incoming_damage" then
		newValue = self:ModifyIncomingDamage(oldValue, value)
	end
	self:SetCustomAttribute(name, childKey, newValue)
end

function public:ModifyIncomingDamage(oldValue, value)
	local newValue =  ((1 + oldValue / 100) * (1 + value / 100) - 1) * 100
	return newValue
end

-- 获取子属性
function public:GetCustomAttributeChild(name, childKey, defaultValue)
	local children = self:GetCustomAttributeChildren(name)
	return children[childKey] or defaultValue or 0
end

-- 获取子属性合集
function public:GetCustomAttributeChildren(name)
	self.__CustomAttributesChildren = self.__CustomAttributesChildren or {}
	
	local children = self.__CustomAttributesChildren[name]

	if children == nil then
		children = {}
		self.__CustomAttributesChildren[name] = children
	end

	return children
end

-- 获取属性
function public:GetCustomAttribute(name, defaultValue)
	local value = 0
	defaultValue = defaultValue or 0

	for i = 0, 5 do
		local item = self:GetItemInSlot(i)
		if item then
			value = value + item:GetCustomAttribute(name,defaultValue)
		end
	end

	local children = self:GetCustomAttributeChildren(name)
	for k,v in pairs(children) do
		value = value + v
	end

	return value
end

-- 获取所有属性
function public:GetAllCustomAttribute()
	local t = self.__CustomAttributes

	for k,v in pairs(CustomAttributesConfig) do
		t[v] = self:GetCustomAttribute(v)
	end

	return t
end

function public:RandomAbilityCooldownReduction(reduction)
	local playerId = self:GetPlayerID()
	local cards = CardGroupSystem:GetPlayerUsingCards(playerId)
	if cards and #cards ~= 0 then
		local ability = table.random(cards)
		self.__AbilityCooldownReduction = self.__AbilityCooldownReduction or {}
		local cooldownReduction = self.__AbilityCooldownReduction[ability]
		if cooldownReduction == nil then 
			self.__AbilityCooldownReduction[ability] = 0
		end
		self.__AbilityCooldownReduction[ability] = self.__AbilityCooldownReduction[ability] + reduction
		self:ShowCustomMessage({
			type="message-box", 
			role="xxwar_system_notification",
			list={{text={"DOTA_Tooltip_Ability_"..ability, "xxwar_cooldown_reduction", string.format("%d", self.__AbilityCooldownReduction[ability]), "秒"}, args={}}},
		})
	end
end

function public:GetAllCooldownReduction()
	return self.__AbilityCooldownReduction or {}
end

function public:GetAbilityCooldownReduction(abilityName)
	return self:GetAllCooldownReduction()[abilityName] or 0
end

function public:StatisticalAttributes()
	local t = self.__All_Attributes
	for k,v in pairs(CustomAttributesConfig) do
		if v == "str" then
			t[v] = self:GetStrength()
		elseif v == "agi" then
			t[v] = self:GetAgility()
		elseif v == "int" then
			t[v] = self:GetIntellect()
		elseif v == "hp" then
			t[v] = self:GetMaxHealth()
		elseif v == "mana" then
			t[v] = self:GetMaxMana()
		elseif v == "armor" then
			t[v] = self:GetPhysicalArmorValue(false)
		elseif v == "magic_armor" then
			t[v] = self:GetMagicalArmorValue() * 100
		elseif v == "health_regen" then
			t[v] = self:GetHealthRegen()
		elseif v == "mana_regen" then
			t[v] = self:GetManaRegen()
		elseif v == "attack_speed" then
			t[v] = self:GetDisplayAttackSpeed()
		elseif v == "move_speed" then
			t[v] = self:GetMoveSpeedModifier(self:GetBaseMoveSpeed(), true)
		elseif v == "status_resistance" then
			t[v] = self:GetStatusResistance() * 100
		elseif v == "evasion" then
			t[v] = self:GetEvasion() * 100
		elseif v == "attack_damage" then
			t[v] = (self:GetDamageMax() + self:GetDamageMin()) * 0.5
		elseif v == "spell_amp" then
			t[v] = self:GetSpellAmplification(false) * 100
		elseif v == "attack_range" then
			t[v] = self:Script_GetAttackRange()
		else
			t[v] = self:GetCustomAttribute(v)
		end
	end
	return t
end
