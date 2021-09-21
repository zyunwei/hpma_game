if Drop_Ability == nil then
    Drop_Ability = {}

    local creepsClassify = {
        [1] = {
            prob = 0.07,
            unit_names = {"npc_dota_neutral_centaur_outrunner","npc_dota_neutral_fel_beast","npc_dota_neutral_giant_wolf","npc_dota_neutral_harpy_scout","npc_dota_neutral_dark_troll","npc_dota_neutral_forest_troll_berserker","npc_dota_neutral_forest_troll_high_priest","npc_dota_neutral_kobold_tunneler","npc_dota_neutral_kobold","npc_dota_neutral_kobold_taskmaster","npc_dota_neutral_satyr_trickster","npc_dota_neutral_gnoll_assassin","npc_dota_neutral_wildkin"},
        },
        [2] = {
            prob = 0.09,
            unit_names = {"npc_dota_neutral_alpha_wolf","npc_dota_neutral_ghost","npc_dota_neutral_mud_golem","npc_dota_neutral_ogre_mauler","npc_dota_neutral_ogre_magi","npc_dota_neutral_harpy_storm","npc_dota_neutral_satyr_soulstealer","npc_dota_neutral_polar_furbolg_champion"},
        },
        [3] = {
            prob = 0.11,
            unit_names = {"npc_dota_neutral_centaur_khan","npc_dota_neutral_dark_troll_warlord","npc_dota_neutral_polar_furbolg_ursa_warrior","npc_dota_neutral_satyr_hellcaller","npc_dota_neutral_enraged_wildkin"},
        },
        [4] = {
            prob = 0.13,
            unit_names = {"npc_dota_neutral_black_dragon","npc_dota_neutral_granite_golem","npc_dota_neutral_prowler_shaman","npc_dota_neutral_elder_jungle_stalker","npc_dota_neutral_big_thunder_lizard","npc_dota_neutral_black_drake","npc_dota_neutral_prowler_acolyte","npc_dota_neutral_small_thunder_lizard","npc_dota_neutral_jungle_stalker","npc_dota_neutral_rock_golem"},
        }
    }

    for _, v in pairs(creepsClassify) do
        for _, unit_name in pairs(v.unit_names) do
            Drop_Ability[unit_name] = v.prob
        end
    end
end