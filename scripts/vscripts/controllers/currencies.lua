
if CurrenciesCtrl == nil then
	CurrenciesCtrl = RegisterController('currencies')
	CurrenciesCtrl.__player_currencies = {}
	CurrenciesCtrl.__player_total_gold = {}
	setmetatable(CurrenciesCtrl,CurrenciesCtrl)
end

local public = CurrenciesCtrl

-- 初始化
function public:__call(hero)

	local t = {}

	for k,v in pairs(CurrenciesConfig) do
		t[k] = v.default or 0
	end

	self.__player_currencies[hero:GetEntityIndex()] = t
	self.__player_total_gold[hero:GetEntityIndex()] = 0
	self:Update(hero)
end

-- 更新
function public:Update(hero)
	local currencies = public.__player_currencies[hero:GetEntityIndex()]
	CustomNetTables:SetTableValue("Common", "currencies_"..hero:GetEntityIndex(),  currencies)
end

-- 获取货币数量
function CDOTA_BaseNPC_Hero:GetCurrency(_type)
	local currencies = public.__player_currencies[self:GetEntityIndex()]
	if not currencies then return 0 end
	return currencies[_type] or 0
end

-- 修改货币数量
function CDOTA_BaseNPC_Hero:ModifyCurrency(_type, _amount)
	local amount = self:GetCurrency(_type) + _amount
	self:SetCurrency(_type, amount)
end

-- 设置货币数量
function CDOTA_BaseNPC_Hero:SetCurrency(_type, amount)
	local conf = CurrenciesConfig[_type]
	if not conf then return end

	if conf.min ~= -1 and amount < conf.min then
		amount = conf.min
	end

	if conf.max ~= -1 and amount > conf.max then
		amount = conf.max
	end

	local currencies = public.__player_currencies[self:GetEntityIndex()]
	if currencies == nil then return end
	currencies[_type] = amount

	if conf.OnUpdate then conf.OnUpdate(self, amount) end

	public:Update(self)
end

-- 花费货币
function CDOTA_BaseNPC_Hero:SpendCurrency(_type, amount)
	if amount < 0 then return false end
	if amount == 0 then return true end

	local _amount = self:GetCurrency(_type)
	if _amount >= amount then
		self:ModifyCurrency(_type, -amount)
		return true
	else
		local conf = CurrenciesConfig[_type]
		if conf then
			self:ShowCustomMessage({type="bottom",msg=conf.msg,class="error"})
		end
	end

	return false
end

-- 花费属性点
function CDOTA_BaseNPC_Hero:SpendAssignAttributePoints(amount)
	return self:SpendCurrency(CURRENCY_TYPE_ASSIGN_ATTRIBUTE_POINTS, amount)
end

-- 花费金币
function CDOTA_BaseNPC_Hero:SpendGold(amount)
	if amount == nil or amount <= 0 then return end
	return self:SpendCurrency(CURRENCY_TYPE_GOLD, amount)
end

-- 给予金币
function CDOTA_BaseNPC_Hero:GiveGold(amount)
	if amount == nil or amount <= 0 then return end
	self:ModifyCurrency(CURRENCY_TYPE_GOLD, amount)
	local gold = CurrenciesCtrl.__player_total_gold[self:GetEntityIndex()]
	if gold then
		CurrenciesCtrl.__player_total_gold[self:GetEntityIndex()] = gold + amount
	end
end

-- 获取金币
function CDOTA_BaseNPC_Hero:GetGold()
	return self:GetCurrency(CURRENCY_TYPE_GOLD)
end

-- 获取属性点
function CDOTA_BaseNPC_Hero:GetAssignAttributePoints()
	return self:GetCurrency(CURRENCY_TYPE_ASSIGN_ATTRIBUTE_POINTS)
end

-- 给予属性点
function CDOTA_BaseNPC_Hero:GiveAssignAttributePoints(amount)
	if amount <= 0 then return end
	self:ModifyCurrency(CURRENCY_TYPE_ASSIGN_ATTRIBUTE_POINTS, amount)
end

-- 获取总金币
function CDOTA_BaseNPC_Hero:GetTotalGold()
	return CurrenciesCtrl.__player_total_gold[self:GetEntityIndex()] or 0
end

--获取所有玩家金币
function public:GetSortedAllPlayerGold()
	local res = {}
	for entIndex, gold in pairs(self.__player_total_gold) do
		local hero = EntIndexToHScript(entIndex)
		if NotNull(hero) and hero:IsAlive() then
			table.insert(res, {
				heroIndex = entIndex,
				gold = gold
			})
		end
	end
	table.sort(res, function(a, b)
		return a.gold < b.gold
	end)
	return res
end