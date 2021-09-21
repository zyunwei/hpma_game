
--[[

GameModeEntity相关的配置，使用默认配置注释掉相关的函数即可

]]

local GameMode = GameRules:GetGameModeEntity()

-- 是否禁用天气特效
GameMode:SetWeatherEffectsDisabled(true)

-- 总是显示玩家名字
GameMode:SetAlwaysShowPlayerNames(true)

-- 总是显示玩家的仓库，无论选择任何单位
GameMode:SetAlwaysShowPlayerInventory(false)

-- 是否禁用播音员
GameMode:SetAnnouncerDisabled(true)

-- 隐藏左侧击杀显示
GameMode:SetHudCombatEventsDisabled(true)

-- 是否开启买活
GameMode:SetBuybackEnabled(false)

-- 是否开启买活CD
GameMode:SetCustomBuybackCooldownEnabled(false)

-- 是否开启买活需要消耗金币
GameMode:SetCustomBuybackCostEnabled(true)

-- 设置默认镜头高度，不建议在这里设置，在Javascript中使用GameUI.SetCameraDistance()设置
-- GameMode:SetCameraDistanceOverride(1135)

-- 强制玩家选择英雄
-- GameMode:SetCustomGameForceHero('npc_dota_hero_juggernaut')

-- 自定义英雄等级
GameMode:SetUseCustomHeroLevels(true)
-- GameMode:SetCustomHeroMaxLevel(30)

local xptable = {}
local lastXp = 0
for i = 1, 30 do
	table.insert(xptable, lastXp + (i - 1) * 30)
	lastXp = xptable[i]
end

-- {
--     0, 		100, 	200, 	300, 	480,
--     640, 	840, 	1040, 	1320, 	1600,
--     1860, 	2160, 	2400, 	2800, 	3160,
--     3520, 	3900, 	4200, 	4700, 	5000,
--     5600, 	6000, 	6600, 	7400, 	8000,
--     9000, 	10000, 	12000, 	13800, 	16000
-- }
GameMode:SetCustomXPRequiredToReachNextLevel(xptable)

-- 设置固定的复活时间
GameMode:SetFixedRespawnTime(30)

-- 是否禁用战争迷雾
GameMode:SetFogOfWarDisabled(true)

-- 是否开启黑色迷雾，开启后地图一开始是全黑的，需要探索后才会显示
GameMode:SetUnseenFogOfWarEnabled(false)

-- 设置泉水回复魔法值的速率
-- GameMode:SetFountainConstantManaRegen(1)

-- 设置泉水回复生命值的速率
-- GameMode:SetFountainPercentageHealthRegen(1)

-- 设置泉水回复魔法值百分比
-- GameMode:SetFountainPercentageManaRegen(1)

-- 是否禁用金币掉落的音效
GameMode:SetGoldSoundDisabled(true)

-- 是否英雄死亡损失金币
GameMode:SetLoseGoldOnDeath(false)

-- 设置最大攻击速度
-- GameMode:SetMaximumAttackSpeed(1000)

-- 设置最小攻击速度
-- GameMode:SetMinimumAttackSpeed(100)

-- 是否禁用物品推荐
GameMode:SetRecommendedItemsDisabled(true)

-- 当幻象死亡后是否删除
GameMode:SetRemoveIllusionsOnDeath(true)

-- 是否开启双倍神符
GameMode:SetRuneEnabled(DOTA_RUNE_DOUBLEDAMAGE,false)

-- 是否开启加速神符
GameMode:SetRuneEnabled(DOTA_RUNE_HASTE,false)

-- 是否开启幻象神符
GameMode:SetRuneEnabled(DOTA_RUNE_ILLUSION,false)

-- 是否开启隐身神符
GameMode:SetRuneEnabled(DOTA_RUNE_INVISIBILITY,false)

-- 是否开启恢复神符
GameMode:SetRuneEnabled(DOTA_RUNE_REGENERATION,false)

-- 是否开启赏金神符
GameMode:SetRuneEnabled(DOTA_RUNE_BOUNTY,false)

-- 是否禁用神秘商店
GameMode:SetStashPurchasingDisabled(true)

-- 隐藏置顶物品在快速购买
GameMode:SetStickyItemDisabled(true)

-- 修改DOTA2默认的三围属性加成
GameMode:SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_STRENGTH_DAMAGE, 1 )
GameMode:SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_STRENGTH_HP, 20 )
GameMode:SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_STRENGTH_HP_REGEN, 0.09 )

GameMode:SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_AGILITY_DAMAGE, 1 )
GameMode:SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_AGILITY_ARMOR, 0.16 )
GameMode:SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_AGILITY_ATTACK_SPEED, 1 )

GameMode:SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_INTELLIGENCE_DAMAGE, 1 )
GameMode:SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_INTELLIGENCE_MANA, 11 )
GameMode:SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_INTELLIGENCE_MANA_REGEN, 0.05 )
