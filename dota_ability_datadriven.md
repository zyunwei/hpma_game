### 参考
https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Abilities_Data_Driven

### Demo

```
"fx_test_ability"
{
    // General
    //-------------------------------------------------------------------------------------------------------------
    "BaseClass"             "ability_datadriven"
    "AbilityBehavior"       "DOTA_ABILITY_BEHAVIOR_PASSIVE"
    "AbilityTextureName"    "axe_battle_hunger"

    // Modifiers
    //-------------------------------------------------------------------------------------------------------------
    "Modifiers"
    {
        "fx_test_modifier"
        {
            "Passive" "1"
            "OnCreated"
            {
                "AttachEffect"
                {
                    "Target" "CASTER"
                    "EffectName" "particles/econ/generic/generic_buff_1/generic_buff_1.vpcf"
                    "EffectAttachType" "follow_overhead"
                    "EffectLifeDurationScale" "1"
                    "EffectColorA" "255 255 0"
                }
            }
        }
    }
}
```

### AbilityBehavior

```
DOTA_ABILITY_BEHAVIOR_HIDDEN               = 1 << 0, //Can be owned by a unit but can't be cast and won't show up on the HUD.
DOTA_ABILITY_BEHAVIOR_PASSIVE              = 1 << 1, //Cannot be cast like above but this one shows up on the ability HUD.
DOTA_ABILITY_BEHAVIOR_NO_TARGET            = 1 << 2, //Doesn't need a target to be cast, ability fires off as soon as the button is pressed.
DOTA_ABILITY_BEHAVIOR_UNIT_TARGET          = 1 << 3, //Needs a target to be cast on.
DOTA_ABILITY_BEHAVIOR_POINT                = 1 << 4, //Can be cast anywhere the mouse cursor is (if a unit is clicked it will just be cast where the unit was standing).
DOTA_ABILITY_BEHAVIOR_AOE                  = 1 << 5, //Draws a radius where the ability will have effect. Kinda like POINT but with a an area of effect display.
DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE        = 1 << 6, //Probably can be cast or have a casting scheme but cannot be learned (these are usually abilities that are temporary like techie's bomb detonate).
DOTA_ABILITY_BEHAVIOR_CHANNELLED           = 1 << 7, //Channeled ability. If the user moves or is silenced the ability is interrupted.
DOTA_ABILITY_BEHAVIOR_ITEM                 = 1 << 8, //Ability is tied up to an item.
DOTA_ABILITY_BEHAVIOR_TOGGLE               = 1 << 9, //Can be insta-toggled.
DOTA_ABILITY_BEHAVIOR_DIRECTIONAL          = 1 << 10, //Has a direction from the hero, such as miranas arrow or pudge's hook.
DOTA_ABILITY_BEHAVIOR_IMMEDIATE            = 1 << 11, //Can be used instantly without going into the action queue.
DOTA_ABILITY_BEHAVIOR_AUTOCAST             = 1 << 12, //Can be cast automatically.
DOTA_ABILITY_BEHAVIOR_NOASSIST             = 1 << 13, //Ability has no reticle assist.
DOTA_ABILITY_BEHAVIOR_AURA                 = 1 << 14, //Ability is an aura.  Not really used other than to tag the ability as such.
DOTA_ABILITY_BEHAVIOR_ATTACK               = 1 << 15, //Is an attack and cannot hit attack-immune targets.
DOTA_ABILITY_BEHAVIOR_DONT_RESUME_MOVEMENT = 1 << 16, //Should not resume movement when it completes. Only applicable to no-target, non-immediate abilities.
DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES        = 1 << 17, //Cannot be used when rooted
DOTA_ABILITY_BEHAVIOR_UNRESTRICTED         = 1 << 18, //Ability is allowed when commands are restricted
DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE  = 1 << 19, //Can be executed while stunned, casting, or force-attacking. Only applicable to toggled abilities.
DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL       = 1 << 20, //Can be executed without interrupting channels.
DOTA_ABILITY_BEHAVIOR_DONT_CANCEL_MOVEMENT = 1 << 21, //Doesn't cause certain modifiers to end, used for courier and speed burst.
DOTA_ABILITY_BEHAVIOR_DONT_ALERT_TARGET    = 1 << 22, //Does not alert enemies when target-cast on them.
DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK   = 1 << 23, //Ability should not resume command-attacking the previous target when it completes. Only applicable to no-target, non-immediate abilities and unit-target abilities.
DOTA_ABILITY_BEHAVIOR_NORMAL_WHEN_STOLEN   = 1 << 24, //Ability still uses its normal cast point when stolen.
DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING     = 1 << 25, //Ability ignores backswing pseudoqueue.
DOTA_ABILITY_BEHAVIOR_RUNE_TARGET          = 1 << 26, //Targets runes.
```



#### Ability  Events and Action

```
"OnSpellStart"      // Event
{
    "FireSound"     // Action
    {
        "EffectName"    "SoundEventName"
        "Target"        "CASTER"
    }
}
```



### 实现及相关配置示例

```
"item_name"
{
    "BaseClass"                         "item_datadriven"
    "AbilityTextureName"                "custom_game/0356"
    "AbilityBehavior"                   "DOTA_ABILITY_BEHAVIOR_PASSIVE"      //被动
    
    "AbilitySpecial"
    {
        "1"
        {
            "var_type"                  "FIELD_FLOAT"
            "bonus_health"              "100"
        }
    }

    "Modifiers"
    {
        "modifier_item_name"
        {
            "Attributes"                "MODIFIER_ATTRIBUTE_MULTIPLE"
            "Duration"                  "20"                        // 持续时间
            "Passive"                   "1"                         //被动
            "IsHidden"                  "1"                         // 隐藏
            "EffectAttachType"          "follow_origin"             // 特效类型（follow_origin, follow_overhead, start_at_customorigin, world_origin）
            "EffectName"                "particles/econ/events/ti9/ti9_monkey_debuff_puddle.vpcf"   //特效路径
            "IsBuff"                    "1"
            "IsDebuff"                  "0"
            "IsPurgable"                "0"
            "OverrideAnimation"         "ACT_DOTA_ATTACK"           // 应该是施法动作之类的
            "TextureName"               "custom_game/0356"          // 图标
            "ThinkInterval"             "1"                         // 循环间隔
            "Properties"
            {
                    //血量
                    "MODIFIER_PROPERTY_HEALTH_BONUS"                    "%bonus_health" 
                    //未知
                    "MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL"      "1"
                    //未知
                    "MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL"     "1"
                    //未知
                    "MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE"         "1"
                    //攻击范围
                    "MODIFIER_PROPERTY_ATTACK_RANGE_BONUS"              "100"
                    //攻击速度
                    "MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT"      "100"
                    //未知
                    "MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT_POWER_TREADS"     "1"
                    //未知
                    "MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT_SECONDARY"
                    //无伤（掉1滴血）
                    "MODIFIER_PROPERTY_AVOID_DAMAGE"                    "1"
                    // 未知，可能是魔法免疫（被放技能触发）
                    "MODIFIER_PROPERTY_AVOID_SPELL"                     "1"
                    // 增加基础攻击伤害
                    "MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE"          "100"
                    // 可能是攻击间隔限制，加大以后，一段时间内不能攻击
                    "MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT"       "1"
                    //基础攻击伤害加成
                    "MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE"   "50"
                    //基础魔法恢复
                    "MODIFIER_PROPERTY_BASE_MANA_REGEN"                 "10"
                    // 日间视野加成
                    "MODIFIER_PROPERTY_BONUS_DAY_VISION"                "100"
                    // 夜间视野加成
                    "MODIFIER_PROPERTY_BONUS_NIGHT_VISION"              "100"
                    // 视野百分比加成
                    "MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE"         "100"
                    // 未知
                    "MODIFIER_PROPERTY_CHANGE_ABILITY_VALUE"            "1"
                    // 固定减少冷却时间
                    "MODIFIER_PROPERTY_COOLDOWN_REDUCTION_CONSTANT"     "2"
                    // 未知
                    "MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE"       "1"
                    // 未知
                    "MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE_ILLUSION"  "1"
                    // 禁止自动攻击
                    "MODIFIER_PROPERTY_DISABLE_AUTOATTACK"              "1"
                    // 禁止回血(包括自动回复，吸血等)
                    "MODIFIER_PROPERTY_DISABLE_HEALING"                 "1"
                    // 禁止转身
                    "MODIFIER_PROPERTY_DISABLE_TURNING"                 "1"
                    // 闪避值
                    "MODIFIER_PROPERTY_EVASION_CONSTANT"                "50"
                    // 额外血量(修改血量上限，可以使用负值)
                    "MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS"              "100"
                    // 额外魔法值(修改魔法值上限，可以使用负值)
                    "MODIFIER_PROPERTY_EXTRA_MANA_BONUS"                "100"
                    // 额外力量值
                    "MODIFIER_PROPERTY_EXTRA_STRENGTH_BONUS"            "10"
                    // 未知
                    "MODIFIER_PROPERTY_FORCE_DRAW_MINIMAP"              "1"
                    // 修改血量（修改血量上限和实际血量，可以使用负值）
                    "MODIFIER_PROPERTY_HEALTH_BONUS"                    "100"
                    // 自动回血
                    "MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT"           "3"
                    // 回血增强比例
                    "MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE"         "0.5"
                    // 未知
                    "MODIFIER_PROPERTY_IGNORE_CAST_ANGLE"               "1"
                    // 所受伤害增强比例 (可用负值，削弱所受伤害)
                    "MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE"      "200"
                    // 所受物理伤害比例(可用负值，削弱所受伤害)
                    "MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE"     "-20"
                    // 不确定，字面上是所受技能伤害，实际测试被野怪打，受到普攻伤害也会增强
                    "MODIFIER_PROPERTY_INCOMING_SPELL_DAMAGE_CONSTANT"          "50"
                    // 不确定，值设为1，人物模型会变成透明状态，但视野应该还是有的
                    "MODIFIER_PROPERTY_INVISIBILITY_LEVEL"                      "1"
                    // 未知
                    "MODIFIER_PROPERTY_LIFETIME_FRACTION"                       "1"
                    // 魔法抗性
                    "MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS"                "10"
                    // 魔法值(增加魔法值上限，可使用负值)
                    "MODIFIER_PROPERTY_MANA_BONUS"                              "100"
                    // 魔法值回复 (可使用负值)
                    "MODIFIER_PROPERTY_MANA_REGEN_CONSTANT"                     "5"
                    // 魔法回复百分比增强
                    "MODIFIER_PROPERTY_MANA_REGEN_PERCENTAGE"                   "1"
                    // 不确定，用了没效果
                    "MODIFIER_PROPERTY_MANA_REGEN_PERCENTAGE"                   "1"
                    // 魔法回复增强比例（可用负值）
                    "MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE"             "0.5"
                    // 最低血量（锁血）
                    "MODIFIER_PROPERTY_MIN_HEALTH"                              "100"
                    // 攻击Miss率
                    "MODIFIER_PROPERTY_MISS_PERCENTAGE"                         "50"
                    // 修改人物模型
                    "MODIFIER_PROPERTY_MODEL_CHANGE"            "models/heroes/meepo/meepo.vmdl"
                    // 不确定，字面上修改模型缩放大小，实际好像没用
                    "MODIFIER_PROPERTY_MODEL_SCALE"                             "1.5"
                    //下面两个都是修改移动速度，基本是修改为固定值，而不是增加，第一个优先级大于第二个
                    "MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE"                      "500"
                    "MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE"                 "100"
                    //增加移动速度
                    "MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT"                "100"
                    // 增加移速比例
                    "MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE"              "20"
                    // 移速限制（不影响面板显示，实际移动速度被限制）
                    "MODIFIER_PROPERTY_MOVESPEED_LIMIT"                         "300"
                    // 不确定，好像没用
                    "MODIFIER_PROPERTY_MOVESPEED_MAX"                           "200"
                    // 护甲(可用负值)
                    "MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS"                    "5"
                    // 未知
                    "MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK"                 "1"
                    // 应该是增加攻击伤害，看起来会被护甲减免伤害
                    "MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE"                  "100"
                    // 不确定，可能是暴击伤害,数值小于一定值不触发，触发后必定暴击，伤害为给定数值
                    "MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE"                "200"
                    // 应该是增加攻击伤害，和MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE不知道有什么区别
                    "MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL"        "100"
                    // 不确定，应该是普通附加了魔法伤害
                    "MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL"         "100"
                    // 可能是增加真实伤害，没测
                    "MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PURE"            "100"
                    // 不确定，增加普攻伤害，而且增加的部分不会被护甲削减
                    "MODIFIER_PROPERTY_PROCATTACK_FEEDBACK"                     "100"
                    // 敏捷
                    "MODIFIER_PROPERTY_STATS_AGILITY_BONUS"                     "10"
                    // 智力
                    "MODIFIER_PROPERTY_STATS_INTELLECT_BONUS"                   "10"
                    // 力量
                    "MODIFIER_PROPERTY_STATS_STRENGTH_BONUS"                    "10"
                    // 技能增强
                    "MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE"                "20"
                    // 生命回复增强
                    "MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE"             "30"
                    // 测过，看起来没什么效果
                    "MODIFIER_PROPERTY_IGNORE_PHYSICAL_ARMOR"                   "1"
                    // 增加额外百分比的血量
                    "MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE"                 "10"
                    // 施法距离（可用负值）
                    "MODIFIER_PROPERTY_CAST_RANGE_BONUS"                        "300"
                    // 也可以增加施法距离，和上面的不知道有什么区别
                    "MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING"               "300"
                    // 攻击弹道速度(可用负值)
                    "MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS"                  "200"
                    // 冷却缩减(百分比, 可用负值)
                    "MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE"                     "50"
                    // 减少施法速度（百分比，可用负值）
                    "MODIFIER_PROPERTY_CASTTIME_PERCENTAGE"                     "50"
                    // 技能消耗魔法值(百分比, 可用负值)
                    "MODIFIER_PROPERTY_MANACOST_PERCENTAGE"                     "50"
                    // 技能免疫 (效果类似林肯法球，没测)
                    "MODIFIER_PROPERTY_ABSORB_SPELL"                            "1"
                    // 技能反弹（效果类似青莲宝珠，没测）
                    "MODIFIER_PROPERTY_REFLECT_SPELL"                           "1"
            }
        }
     }
}
```
