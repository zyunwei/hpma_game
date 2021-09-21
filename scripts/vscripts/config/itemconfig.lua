ITEM_QUALITY_D = 1
ITEM_QUALITY_C = 2
ITEM_QUALITY_B = 3
ITEM_QUALITY_A = 4
ITEM_QUALITY_S = 5
ITEM_QUALITY_Z = 6
ITEM_QUALITY_EX = 7

ITEM_KIND_MATERIAL = 0
ITEM_KIND_WEAPON = 1
ITEM_KIND_SHOES = 2
ITEM_KIND_CLOTHES = 3
ITEM_KIND_HAT = 4
ITEM_KIND_TRINKET = 5
ITEM_KIND_GLOVES = 6
ITEM_KIND_CONSUMABLE = 7
ITEM_KIND_VIRTUAL_EQUIP = 8

ITEM_KIND_GROUP_MATERIAL = 0
ITEM_KIND_GROUP_VIRTUAL_EQUIP = 1
ITEM_KIND_GROUP_WEAPON = 2
ITEM_KIND_GROUP_SHOES = 3
ITEM_KIND_GROUP_CLOTHES = 4
ITEM_KIND_GROUP_HAT = 5
ITEM_KIND_GROUP_TRINKET = 6
ITEM_KIND_GROUP_GLOVES = 7

ItemKindGroup = {
	[ITEM_KIND_CONSUMABLE] = ITEM_KIND_GROUP_MATERIAL,
	[ITEM_KIND_VIRTUAL_EQUIP] = ITEM_KIND_GROUP_VIRTUAL_EQUIP,
	[ITEM_KIND_MATERIAL] = ITEM_KIND_GROUP_MATERIAL,
	[ITEM_KIND_WEAPON] = ITEM_KIND_GROUP_WEAPON,
	[ITEM_KIND_GLOVES] = ITEM_KIND_GROUP_GLOVES,
	[ITEM_KIND_SHOES] = ITEM_KIND_GROUP_SHOES,
	[ITEM_KIND_CLOTHES] = ITEM_KIND_GROUP_CLOTHES,
	[ITEM_KIND_HAT] = ITEM_KIND_GROUP_HAT,
	[ITEM_KIND_TRINKET]	= ITEM_KIND_GROUP_TRINKET,
}

ItemKindEquips = {
	[ITEM_KIND_WEAPON] = true,
	[ITEM_KIND_GLOVES] = true,
	[ITEM_KIND_SHOES] = true,
	[ITEM_KIND_CLOTHES] = true,
	[ITEM_KIND_HAT] = true,
	[ITEM_KIND_TRINKET] = true,
}

ItemRandomAffix = {
	[ITEM_KIND_WEAPON] = { "cleave", "corruption", "stun", "crit_mult", "doom", "hujiadaofa", "finger_death", "battle_trance" },
	[ITEM_KIND_GLOVES] = { "exp_gain", "gold_gain", "collection", "magic_find", "pet_duration", "shuriken", "refraction", "tanxian" },
	[ITEM_KIND_SHOES] = { "teleport", "hp_regen_amplify", "outgoing_damage", "jump_length", "jump_cooldown", "pet_cooldown", "wind_agi", "kick_damage" },
	[ITEM_KIND_CLOTHES] = { "damage_block", "evasion", "attack_return", "incoming_damage", "bagua", "shivas", "zhiheng", "pet_armor" },
	[ITEM_KIND_HAT] = { "pierce_chance", "bonus_vision", "exp_gain", "crit_chance", "mowang", "kuihua", "wuguang", "lianhuan" },
	[ITEM_KIND_TRINKET] = { "crit_chance", "crit_mult", "gold_gain", "mana_regen_pct", "crazy_pet", "flame", "explosion", "hex_duration" },
}

ItemAffixAbilityMapping = {
	["doom"] = { "ability_custom_doom" },
	["hujiadaofa"] = { "ability_custom_hujiadaofa" },
	["finger_death"] = { "ability_custom_finger_of_death" },
	["battle_trance"] = { "ability_custom_battle_trance" },
	["bagua"] = { "ability_custom_taijibagua", "ability_custom_liangyisixiang" },
	["shivas"] = { "ability_custom_shivas_guard", "ability_custom_frost_armor" },
	["zhiheng"] = { "ability_custom_zhiheng", "ability_custom_renwang"},
	["pet_armor"] = { "ability_custom_pet_armor_up", "ability_custom_pet_bulwark" },
	["mowang"] = { "ability_custom_hujiafushi", "ability_custom_mowangjiangling" },
	["kuihua"] = { "ability_custom_bixiejianpu", "ability_custom_kuihuabaodian" },
	["wuguang"] = { "ability_custom_aphotic_shield" },
	["lianhuan"] = { "ability_custom_track" },
	["pet_duration"] = { "ability_custom_call_summon_*" },
	["shuriken"] = { "ability_custom_shuriken" },
	["refraction"] = { "ability_custom_refraction" },
	["tanxian"] = { "ability_custom_exploration_talent" },
	["pet_cooldown"] = { "ability_custom_jiasulunhui", "ability_custom_tongyu" },
	["wind_agi"] = { "ability_custom_windrun", "ability_custom_lingboweibu" },
	["kick_damage"] = { "ability_custom_yuanshengzhili", "ability_custom_wuyingjiao" },
	["crazy_pet"] = { "ability_custom_crazy_pet", "ability_custom_metamorphosis_pet" },
	["flame"] = { "ability_custom_burn_around" },
	["explosion"] = { "ability_custom_crystal_explosion" },
	["hex_duration"] = { "ability_custom_voodoo" },
}

ItemAffixValues = {
	["crit_chance"] = { 12, 14, 16, 18, 20 }, -- 暴击概率
	["crit_mult"] = { 40, 45, 50, 55, 60 }, -- 暴击伤害
	["cleave"] = { 20, 25, 30, 35, 40 }, -- 分裂百分比%
	["corruption"] = { 4, 5, 6, 7, 8 }, -- 减甲
	["stun"] = { 8, 9, 10, 11, 12 }, -- 眩晕概率
	["doom"] = { 4, 5, 6, 7, 8 }, -- 末日持续时间
	["hujiadaofa"] = { 40, 50, 60, 70, 80 }, -- 胡家刀法伤害%
	["finger_death"] = { 8, 9, 10, 11, 12 }, -- 死亡一指伤害%
	["battle_trance"] = { 60, 65, 70, 75, 80 }, -- 专注射击攻速
	["damage_block"] = { 60, 65, 70, 75, 80 }, -- 物理伤害格挡
	["evasion"] = { 10, 12, 14, 16, 18 }, -- 闪避百分比%
	["attack_return"] = { 22, 24, 26, 28, 30 }, -- 攻击反弹（不减原伤害）百分比%
	["incoming_damage"] = { -8, -9, -10, -11, -12 }, -- 伤害减免百分比%
	["bagua"] = { -0.1, -0.2, -0.3, -0.4, -0.5 }, -- 太极八卦和两仪四象减伤%
	["shivas"] = { 40, 50, 60, 70, 80 }, -- 傲寒六绝伤害%
	["zhiheng"] = { 10, 20, 30, 40, 50 }, -- 遇强则强和制衡伤害%
	["pet_armor"] = { 0.1, 0.2, 0.3, 0.4, 0.5 }, -- 宝宝护甲和宝宝甲盾额外护甲
	["pierce_chance"] = { 60, 65, 70, 75, 80 }, -- 无视闪避概率%
	["bonus_vision"] = { 200, 250, 300, 350, 400 }, -- 视野加成%
	["exp_gain"] = { 22, 24, 26, 28, 30 }, -- 经验加成%
	["gold_gain"] = { 22, 24, 26, 28, 30 }, -- 金币加成%
	["mowang"] = { 12, 14, 16, 18, 20 }, -- 护甲腐蚀和魔王降临持续时间
	["kuihua"] = { 8, 9, 10, 11, 12 }, -- 辟邪剑谱和葵花宝典暴击率%
	["wuguang"] = { 200, 250, 300, 350, 400 }, -- 无光之盾吸收伤害
	["lianhuan"] = { 8, 9, 10, 11, 12 }, -- 连环猎杀基础增伤%
	["collection"] = { 32, 34, 36, 38, 40 }, -- 收集速度%
	["magic_find"] = { 22, 24, 26, 28, 30 }, -- 掉落概率提升%
	["pet_duration"] = { 8, 9, 10, 11, 12 }, -- 宝宝持续时间
	["pet_cooldown"] = { 12, 14, 16, 18, 20}, -- 加速轮回和统御宝宝冷却
	["shuriken"] = { 60, 65, 70, 75, 80 }, -- 手里剑基础伤害
	["refraction"] = { 0, 1, 2, 3, 4 }, -- 折光次数
	["tanxian"] = { 22, 24, 26, 28, 30 }, -- 探险达人掉宝率%
	["teleport"] = { 30, 35, 40, 45, 50 }, -- 传送速度%
	["hp_regen_amplify"] = { 30, 35, 40, 45, 50 }, -- 生命恢复增强
	["outgoing_damage"] = { 8, 9, 10, 11, 12 }, -- 伤害加成%
	["jump_cooldown"] = { 20, 25, 30, 35, 40}, -- 跳跃冷却降低%
	["jump_length"] = { 120, 140, 160, 180, 200 }, -- 跳跃距离加成
	["wind_agi"] = { 22, 24, 26, 28, 30 }, -- 风步和凌波微步敏捷
	["kick_damage"] = { 80, 90, 100, 110, 120 }, -- 原生之力和无影脚伤害%
	["mana_regen_pct"] = { 1, 2, 3, 4, 5 }, -- 最大魔法值回复%
	["crazy_pet"] = { 80, 85, 90, 95, 100 }, -- 狂暴宝宝和魔化宝宝攻速
	["flame"] = { 30, 35, 40, 45, 50 }, -- 火焰风衣伤害%
	["explosion"] = { 8, 9, 10, 11, 12 }, -- 仙术轰炸基础倍数
	["hex_duration"] = { 0.8, 0.9, 1.0, 1.1, 1.2 }, -- 妖术持续时间
}

CustomAttributesConfig = {
	"str",
	"agi",
	"int",
	"hp",
	"mana",
	"crystal",
	"crystal_regen",
	"max_crystal",
	"armor",
	"magic_armor",
	"health_regen",
	"health_regen_pct",
	"mana_regen",
	"damage_outgoing",
	"attack_speed",
	"attack_damage",
	"attack_range",
	"move_speed",
	"spell_amp",
	"status_resistance",
	"magic_find",
	"gold_gain",
	"exp_gain",
	"mana_regen_pct",
}

for _, v in pairs(ItemRandomAffix) do
	for _, affix in pairs(v) do
		if table.contains(affix) == false then
			table.insert(CustomAttributesConfig, affix)
		end
	end
end

ItemConfig = {}
local loadConfigs = {
    [1] = {
        path = "scripts/npc/items/item_material.kv",
        kind = ITEM_KIND_MATERIAL
    },
    [2] = {
        path = "scripts/npc/items/item_consumable.kv",
        kind = ITEM_KIND_CONSUMABLE
    },
	[3] = {
		path = "scripts/npc/items/item_equip_clothes.kv",
		kind = ITEM_KIND_CLOTHES
	},
	[4] = {
		path = "scripts/npc/items/item_equip_weapon.kv",
		kind = ITEM_KIND_WEAPON
	},
	[5] = {
		path = "scripts/npc/items/item_equip_hat.kv",
		kind = ITEM_KIND_HAT
	},
	[6] = {
		path = "scripts/npc/items/item_equip_shoes.kv",
		kind = ITEM_KIND_SHOES
	},
	[7] = {
		path = "scripts/npc/items/item_equip_trinket.kv",
		kind = ITEM_KIND_TRINKET
	},
	[8] = {
		path = "scripts/npc/items/item_equip_gloves.kv",
		kind = ITEM_KIND_GLOVES
	},
	[10] = {
		path = "scripts/npc/items/item_virtual_equip.kv",
		kind = ITEM_KIND_VIRTUAL_EQUIP,
	}
}

for _, loadInfo in pairs(loadConfigs) do
    local kvs = LoadKeyValues(loadInfo.path)
    for item_name, item_values in pairs(kvs) do
        local quality = 1
        if item_values["Quality"] ~= nil then
            quality = tonumber(item_values["Quality"])
        end
		local kind = loadInfo.kind
		if item_values["ItemKind"] ~= nil then
			kind = tonumber(item_values["ItemKind"])
		end

		local price = 100
		if quality == ITEM_QUALITY_D then
			price = 200
		elseif quality == ITEM_QUALITY_C then
			price = 600
		elseif quality == ITEM_QUALITY_B then
			price = 1800
		elseif quality == ITEM_QUALITY_A then
			price = 5400
		elseif quality == ITEM_QUALITY_S then
			price = 16200
		elseif quality == ITEM_QUALITY_Z then
			price = 48600
		elseif quality == ITEM_QUALITY_EX then
			price = 145800
		end

		if string.find(item_name, "item_virtual_") == 1 then
			price = 0
		end

		composable = 1
		if item_values["Composable"] ~= nil then
			composable = tonumber(item_values["Composable"])
		end

		if quality == ITEM_QUALITY_D then
			composable = 0
		end

		autoUse = 0
		if item_values["AutoUse"] ~= nil then
			autoUse = tonumber(item_values["AutoUse"])
		end

        ItemConfig[item_name] = { ["kind"] = kind, ["quality"] = quality, ["price"] = price, ["composable"] = composable, ["autoUse"] = autoUse }
		if loadInfo.special_values then
			for _, spName in pairs(loadInfo.special_values) do
				ItemConfig[item_name][spName] = item_values[spName]
			end
		end
    end
end
