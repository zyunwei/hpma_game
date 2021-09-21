
--[[
控制器主要作用是控制类的生成和类的事件管理，比如控制背包给予每个玩家的英雄
]]


if __controller == nil then
	__controller = {}
	__registerOrder = {}
	
	function RegisterController(name)
		if __controller[name] == nil then
			__controller[name] = {}
			table.insert(__registerOrder, name)
		end
		return __controller[name]
	end

	function GetController(name)
		return __controller[name]
	end

	function ControllersInit()
		for _, name in ipairs(__registerOrder) do
			local v = __controller[name]
			if v and v.init then
				v:init()
			end
		end
	end
end

autoload({
	'teleports',
	'blockade_system',
	'npc',
	'treasures',
	'supply',
	'bag',
	'currencies',
	'equip',
	'custom_attributes',
	'message',
	'compose_system',
	'custom_item_spell_system',
	'modal_dialog',
	'item_replace',
	'spawn_creeps',
	'refresh_creep_system',
	'ability_reward',
	'card_group_system',
	'call_hero_pool',
	'dropper',
	'test',
	'radar',
	'pet_talent',
	'trap',
	'pet_exp',
	"collection"
},'controllers')