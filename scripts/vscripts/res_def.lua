if ParticleRes == nil then
    ParticleRes = {}
    ParticleRes.ItemDrop = "particles/neutral_fx/neutral_item_drop.vpcf"
    ParticleRes.NpcArrow = "particles/npx_moveto_goal.vpcf"
    ParticleRes.Collection = "particles/econ/events/ti10/compendium_points_ti10_ambient.vpcf"
    ParticleRes.SummonBoss = "particles/units/heroes/heroes_underlord/abyssal_underlord_darkrift_target.vpcf"
    ParticleRes.TP_START = "particles/econ/items/tinker/boots_of_travel/teleport_start_bots.vpcf"
    ParticleRes.TP_END = "particles/econ/items/tinker/boots_of_travel/teleport_end_bots.vpcf"
    ParticleRes.TP_FINISH = "particles/econ/items/tinker/boots_of_travel/teleport_end_bots_ground_flash.vpcf"
    ParticleRes.Respawn = "particles/items_fx/aegis_respawn_aegis_starfall.vpcf"
    ParticleRes.LEVEL_UP = "particles/units/heroes/hero_oracle/oracle_false_promise_cast_enemy.vpcf"
    ParticleRes.TELEPORT_POINT = "particles/avalon_assets/portal/portal_teleport_00.vpcf"
    ParticleRes.WALL = "particles/wall.vpcf"
end

if SoundRes == nil then
    SoundRes = {}
    SoundRes.LEVEL_UP = "Hero_Omniknight.GuardianAngel"
    SoundRes.TP_START = "Portal.Hero_Disappear"
    SoundRes.TP_START_LOOP = "Portal.Loop_Disappear"
    SoundRes.TP_END = "Portal.Hero_Appear"
    SoundRes.TP_END_LOOP = "Portal.Loop_Appear"
    SoundRes.GAME_OVER = "dsadowski_01.stinger.radiant_win"
    SoundRes.OPEN_TREASURE = "ui.treasure_01"
    SoundRes.TRAP_TREASURE = "HUD.DebuffAlert"
end

if PreloadSounds == nil then
    PreloadSounds = {
        "soundevents/game_sounds_ui_imported.vsndevts",
        "soundevents/voscripts/game_sounds_vo_announcer.vsndevts",
        "soundevents/soundevents_conquest.vsndevts",
        "soundevents/game_sounds_heroes/game_sounds_omniknight.vsndevts",
        "soundevents/game_sounds_heroes/game_sounds_axe.vsndevts",
        "soundevents/music/dsadowski_01/soundevents_stingers.vsndevts",
        "soundevents/xxwar.vsndevts",
    }
end

if PreloadModels == nil then
    PreloadModels = {
        "models/props_generic/chest_treasure_01.vmdl",
        "models/props_generic/chest_treasure_02_open.vmdl",
    }
end

if PreloadParticles == nil then
    PreloadParticles = {
        "particles/status_fx/status_effect_frost_armor.vpcf",
        "particles/status_fx/status_effect_frost.vpcf",
        "particles/econ/events/ti9/ti9_monkey_debuff_puddle.vpcf",
        "particles/econ/items/tuskarr/tusk_ti9_immortal/tusk_ti9_golden_walruspunch_start_magic.vpcf",
        "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_omni.vpcf",
        "particles/units/heroes/hero_ursa/ursa_earthshock_rocks.vpcf",
        "particles/items_fx/black_king_bar_avatar.vpcf",
        "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave_crit_b.vpcf",
        "particles/units/heroes/hero_juggernaut/jugg_crit_blur.vpcf",
        "particles/units/heroes/hero_juggernaut/juggernaut_crit_tgt.vpcf",
        "particles/generic_gameplay/screen_damage_indicator.vpcf"
    }

    for _, v in pairs(ParticleRes) do
        table.insert(PreloadParticles, v)
    end
end

local abilityTable = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
for _, v in pairs(abilityTable) do
    if v and v.precache then
        for cacheType, cachePath in pairs(v.precache) do
            if cacheType == "soundfile" and table.contains(PreloadSounds, cachePath) == false then
                table.insert(PreloadSounds, cachePath)
            end

            if cacheType == "particle" and table.contains(PreloadParticles, cachePath) == false then
                table.insert(PreloadParticles, cachePath)
            end
        end
    end
end

if PrecacheHeroList == nil or MainAbilitiesPool == nil then
    PrecacheHeroList = {
        "npc_dota_hero_lina", "npc_dota_hero_templar_assassin", "npc_dota_hero_sand_king", "npc_dota_hero_beastmaster", "npc_dota_hero_warlock"}
    MainAbilitiesPool = {}

    local all_ability_table = LoadKeyValues("scripts/kv/main_abilities.kv")
    local main_abilities = {}
    for _, v in pairs(all_ability_table) do
        table.insert(main_abilities, v)
    end

    local dotaHeroNames = {
        "ancient_apparition", "antimage", "axe", "bane", "beastmaster", "bloodseeker", "chen", "crystal_maiden",
        "dazzle", "dragon_knight", "doom_bringer", "earthshaker", "enchantress",
        "enigma", "faceless_void", "furion", "juggernaut", "kunkka", "leshrac", "lich", "life_stealer", "lina",
        "lion", "mirana", "morphling", "necrolyte", "nevermore", "night_stalker", "omniknight", "puck", "pudge",
        "pugna", "rattletrap", "razor", "riki", "shadow_shaman", "slardar", "sniper", "spectre",
        "storm_spirit", "sven", "tidehunter", "tinker", "tiny", "venomancer", "viper", "weaver",
        "windrunner", "witch_doctor", "zuus", "broodmother", "skeleton_king", "queenofpain", "huskar", "jakiro",
        "batrider", "warlock", "alchemist", "death_prophet", "ursa", "bounty_hunter", "spirit_breaker",
        "obsidian_destroyer", "shadow_demon", "lycan", "brewmaster", "treant", "ogre_magi",
        "lone_druid", "phantom_assassin", "gyrocopter", "rubick", "luna", "disruptor",
        "templar_assassin", "naga_siren", "nyx_assassin", "keeper_of_the_light", "phoenix",
        "magnataur", "centaur", "shredder", "medusa", "troll_warlord", "tusk", "bristleback", "skywrath_mage",
        "abaddon", "earth_spirit", "ember_spirit", "legion_commander", "terrorblade",
        "techies", "oracle", "winter_wyvern", "abyssal_underlord", "grimstroke", "mars", "undying",
        "invoker", "clinkz", "elder_titan", "pangolier", "slark", "dark_willow", "dark_seer", "monkey_king",
        "void_spirit", "snapfire", "silencer", "visage", "vengefulspirit", "drow_ranger", "chaos_knight", "wisp", 
        "meepo", "hoodwink", "dawnbreaker", "arc_warden", "phantom_lancer", "sandking"
    }

    local heroAbilityTable = {}

    local validHeroNames = {}
    for _, v in pairs(main_abilities) do
        for _, heroName in pairs(dotaHeroNames) do
            if string.find(v, heroName) == 1 then
                heroAbilityTable[heroName] = heroAbilityTable[heroName] or {}
                if table.contains(heroAbilityTable[heroName], v) == false then
                    table.insert(heroAbilityTable[heroName], v)
                end
                if table.contains(validHeroNames, heroName) == false then
                    table.insert(validHeroNames, heroName)
                end
            end
        end
    end

    validHeroNames = table.shuffle(validHeroNames)

    local draftHeroes = {}
    local abilityCount = 0
    for _, v in pairs(validHeroNames) do
        table.insert(draftHeroes, v)
        abilityCount = abilityCount + #heroAbilityTable[v]
        if abilityCount >= 100 then
            break
        end
    end

    for _, heroName in pairs(draftHeroes) do
        for _, abilityName in pairs(heroAbilityTable[heroName]) do
            table.insert(MainAbilitiesPool, abilityName)
            if #MainAbilitiesPool >= 100 then
                break
            end
        end
    end

    -- table.print(draftHeroes)
    -- table.print(MainAbilitiesPool)

    for _, heroName in pairs(draftHeroes) do
        local npcName = "npc_dota_hero_" .. heroName
        if table.contains(PrecacheHeroList, npcName) == false then
            table.insert(PrecacheHeroList, npcName)
        end
    end

    -- table.print(draftHeroes)
end
