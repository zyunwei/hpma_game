
--[[
货币相关的配置
]]

-- 货币类型
CURRENCY_TYPE_GOLD = 1		--金币
CURRENCY_TYPE_ASSIGN_ATTRIBUTE_POINTS = 2	--可分配属性点

-- 货币配置
CurrenciesConfig = {
	[CURRENCY_TYPE_GOLD] = {name="gold", min=0, max=-1, default=0, msg="#xxwar_not_enough_gold"},
	[CURRENCY_TYPE_ASSIGN_ATTRIBUTE_POINTS] = {name="assign_attribute_points", min=0, max=-1, default=0, msg="#xxwar_msg_not_enough_assign_attribute_points"},
}
