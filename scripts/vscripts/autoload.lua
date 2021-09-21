KV_SPELL_IMMUNITY_ABILITIES = LoadKeyValues("scripts/kv/spell_immunity_abilities.kv")
KV_PET_ITEMS = LoadKeyValues("scripts/kv/pet_items.kv")

autoload({
	"config.config",
	"libs.avalon.avalon",
	"extends.extends",
    "class.class",
    "controllers.controllers",
	"events.events",
	"libs.methods",
	"libs.particles_queue",
})

-- 通用
LinkLuaModifier("modifier_invulnerable", "modifiers/modifier_invulnerable", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_custom_attributes", "modifiers/modifier_custom_attributes", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_custom_stun", "modifiers/modifier_custom_stun", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_xxwar_evade", "modifiers/modifier_xxwar_evade", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_in_blockade", "modifiers/modifier_in_blockade", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_health_regen", "modifiers/modifier_health_regen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_health_regen_percentage", "modifiers/modifier_health_regen_percentage", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_health_regen_remain", "modifiers/modifier_health_regen_remain", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mana_regen", "modifiers/modifier_mana_regen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mana_regen_percentage", "modifiers/modifier_mana_regen_percentage", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mana_regen_remain", "modifiers/modifier_mana_regen_remain", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_heal_amplify_percentage", "modifiers/modifier_heal_amplify_percentage", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_animal", "modifiers/modifier_animal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_health_regen_amplify", "modifiers/modifier_health_regen_amplify", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_status_resistance", "modifiers/modifier_status_resistance", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_boss_debuff", "modifiers/modifier_boss_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_out_of_game", "modifiers/modifier_out_of_game", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_provides_vision", "modifiers/modifier_provides_vision", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_respawn_protection", "modifiers/modifier_respawn_protection", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_saved_item", "modifiers/modifier_saved_item", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_creep", "modifiers/modifier_creep", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_corruption", "modifiers/modifier_corruption", LUA_MODIFIER_MOTION_NONE)

-- 心法
LinkLuaModifier("modifier_bulaochangchun", "modifiers/xinfa/modifier_bulaochangchun", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bulaochangchun_permanent_buff", "modifiers/xinfa/modifier_bulaochangchun", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bingxinjue", "modifiers/xinfa/modifier_bingxinjue", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_zixiashengong", "modifiers/xinfa/modifier_zixiashengong", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_hujiadaoxinfa", "modifiers/xinfa/modifier_hujiadaoxinfa", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_moridaoxinfa", "modifiers/xinfa/modifier_moridaoxinfa", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ganjiangjianxinfa", "modifiers/xinfa/modifier_ganjiangjianxinfa", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_moyejianxinfa", "modifiers/xinfa/modifier_moyejianxinfa", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_taijibaguaxinfa", "modifiers/xinfa/modifier_taijibaguaxinfa", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_zhihengxinfa", "modifiers/xinfa/modifier_zhihengxinfa", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_hudunxinfa", "modifiers/xinfa/modifier_hudunxinfa", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wuyingjiaoxinfa", "modifiers/xinfa/modifier_wuyingjiaoxinfa", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lingboweibuxinfa", "modifiers/xinfa/modifier_lingboweibuxinfa", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tongyuxinfa", "modifiers/xinfa/modifier_tongyuxinfa", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mowangxinfa", "modifiers/xinfa/modifier_mowangxinfa", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_xianjixinfa", "modifiers/xinfa/modifier_xianjixinfa", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tonglingxinfa", "modifiers/xinfa/modifier_tonglingxinfa", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mohuaxinfa", "modifiers/xinfa/modifier_mohuaxinfa", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jinengzengqiangxinfa", "modifiers/xinfa/modifier_jinengzengqiangxinfa", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_yiquanchaorenxinfa", "modifiers/xinfa/modifier_yiquanchaorenxinfa", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_yangjingxuruixinfa", "modifiers/xinfa/modifier_yangjingxuruixinfa", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_anyingzhiwuxinfa", "modifiers/xinfa/modifier_anyingzhiwuxinfa", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mofatouquxinfa", "modifiers/xinfa/modifier_mofatouquxinfa", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_nuyikuangjixinfa", "modifiers/xinfa/modifier_nuyikuangjixinfa", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_counterxinfa", "modifiers/xinfa/modifier_counterxinfa", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fangyujuzhenxinfa", "modifiers/xinfa/modifier_fangyujuzhenxinfa", LUA_MODIFIER_MOTION_NONE)

--宠物
LinkLuaModifier("modifier_pet_passive", "modifiers/pet/modifier_pet_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_crazy_pet", "modifiers/pet/modifier_crazy_pet", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pet_armor_up", "modifiers/pet/modifier_pet_armor_up", LUA_MODIFIER_MOTION_NONE)
