
-- Drop_Items = {
--     weak_creep_1 = {
--         DropCount = 1,
--         ItemList = {
--             {"item_test_cusumable", 0.1},
--             {"null", 0.5},
--             {"item_material_fur", 1},
--         }
--     },
--     weak_creep_2 = {
--         DropCount = 1,
--         ItemList = {
--             {"null", 0.5},
--             {"item_material_fibre", 0.1},
--             {"item_material_fur", 0.7},
--         }
--     },
-- }

if Drop_Items == nil then
    Drop_Items = {}

    local creepsClassify = {
        [1] = {
            equip_probs = {
                {level=1, prob = 0.075},
                {level=2, prob = 0.0375},
                {level=3, prob = 0.0075},
            },
            consumable_probs = {
                {level=1, prob = 0.05},
                {level=2, prob = 0.025},
            },
            unit_names = {"npc_dota_neutral_centaur_outrunner","npc_dota_neutral_fel_beast","npc_dota_neutral_giant_wolf","npc_dota_neutral_harpy_scout","npc_dota_neutral_dark_troll","npc_dota_neutral_forest_troll_berserker","npc_dota_neutral_forest_troll_high_priest","npc_dota_neutral_kobold_tunneler","npc_dota_neutral_kobold","npc_dota_neutral_kobold_taskmaster","npc_dota_neutral_satyr_trickster","npc_dota_neutral_gnoll_assassin","npc_dota_neutral_wildkin"},
        },
        [2] = {
            equip_probs = {
                {level=1, prob = 0.0375},
                {level=2, prob = 0.1},
                {level=3, prob = 0.075},
                {level=4, prob = 0.0075},

            },
            consumable_probs = {
                {level=1, prob = 0.05},
                {level=2, prob = 0.025},
                {level=3, prob = 0.005},
            },
            unit_names = {"npc_dota_neutral_alpha_wolf","npc_dota_neutral_ghost","npc_dota_neutral_mud_golem","npc_dota_neutral_ogre_mauler","npc_dota_neutral_ogre_magi","npc_dota_neutral_harpy_storm","npc_dota_neutral_satyr_soulstealer","npc_dota_neutral_polar_furbolg_champion"},
        },
        [3] = {
            equip_probs = {
                {level=1, prob = 0.05},
                {level=2, prob = 0.02},
                {level=3, prob = 0.1},
                {level=4, prob = 0.01},
            },
            consumable_probs = {
                {level=1, prob = 0.025},
                {level=2, prob = 0.05},
                {level=3, prob = 0.025},
            },
            unit_names = {"npc_dota_neutral_centaur_khan","npc_dota_neutral_dark_troll_warlord","npc_dota_neutral_polar_furbolg_ursa_warrior","npc_dota_neutral_satyr_hellcaller","npc_dota_neutral_enraged_wildkin"},
        },
        [4] = {
            equip_probs = {
                --{level=1, prob = 0.1},
                {level=2, prob = 0.075},
                {level=3, prob = 0.05},
                {level=4, prob = 0.0375},
            },
            consumable_probs = {
                {level=1, prob = 0.005},
                {level=2, prob = 0.05},
                {level=3, prob = 0.05},
            },
            unit_names = {"npc_dota_neutral_black_dragon","npc_dota_neutral_granite_golem","npc_dota_neutral_prowler_shaman","npc_dota_neutral_elder_jungle_stalker","npc_dota_neutral_big_thunder_lizard","npc_dota_neutral_black_drake","npc_dota_neutral_prowler_acolyte","npc_dota_neutral_small_thunder_lizard","npc_dota_neutral_jungle_stalker","npc_dota_neutral_rock_golem"},
        },
        -- 小动物
        [5] = {
            equip_probs = {
                {level=1, prob = 0.075},
                {level=2, prob = 0.0375},
            },
            consumable_probs = {
                {level=1, prob = 0.15},
            },
            unit_names = {"npc_custom_frog","npc_custom_chicken","npc_custom_donkey","npc_custom_bird","npc_custom_sheep","npc_custom_pig"},
        }
    }
    -- local spawn_creeps = LoadKeyValues("scripts/kv/spawn_creeps.kv")
    -- local spawnItems = {
    --     {"item_material_primary_soulstone", 0.5},
    --     {"item_material_soulstone" ,0.3},
    --     {"item_material_senior_soulstone", 0.2},
    --     {"item_material_animal_horn", 0.6},
    -- }
    -- for _, data in pairs(spawn_creeps) do
    --     spawnItems = table.shuffle(spawnItems)
    --     for i = 1, 40 do
    --         local info = data["Creep" .. tostring(i)]
    --         if info ~= nil then
    --             Drop_Items[info.unit_name] = {
    --                 DropCount = 1,
    --                 ItemList = {
    --                     {"null", 1},
    --                     {spawnItems[1][1], spawnItems[1][2]},
    --                     {spawnItems[2][1], spawnItems[2][2]},
    --                 }
    --             }
    --         end
    --     end
    -- end

    local targetKinds = {
        ITEM_KIND_WEAPON,
        ITEM_KIND_GLOVES,
        ITEM_KIND_SHOES,
        ITEM_KIND_CLOTHES,
        ITEM_KIND_HAT,
        ITEM_KIND_TRINKET
    }
    local dropEquipItems = {
        [1] = {}, [2] = {}, [3] = {}, [4] = {},[5] = {},
    }
    local dropConsumableItems = {
        [1] = {}, [2] = {}, [3] = {}, [4] = {},[5] = {},
    }
    for _, kind in pairs(targetKinds) do
        for i = 1, 5 do
            local items = ItemComposeClassifyTable[i][kind]
            for _, itemName in pairs(items) do
                table.insert(dropEquipItems[i], {ItemName = itemName, Weight = 1})    
            end
        end
    end
    for i = 1, 5 do
        local items = ItemComposeClassifyTable[i][ITEM_KIND_CONSUMABLE]
        for _, itemName in pairs(items) do
            table.insert(dropConsumableItems[i], {ItemName = itemName, Weight = 1})    
        end
    end

    local function AddDropItemsToTable(probs, unit_names, dropItems)
        for _, v in pairs(probs) do
            for _, name in pairs(unit_names) do
                local itemList = {}
                for _, item in pairs(dropItems[v.level]) do
                    table.insert(itemList, {item.ItemName, item.Weight})
                end
                if Drop_Items[name] == nil then
                    Drop_Items[name] = {}
                end
                table.insert(Drop_Items[name], {
                    DropCount = 1,
                    ItemList = itemList,
                    DropProb = v.prob
                })
            end
        end
    end

    for _, info in pairs(creepsClassify) do
        AddDropItemsToTable(info.equip_probs, info.unit_names, dropEquipItems)
        AddDropItemsToTable(info.consumable_probs, info.unit_names, dropConsumableItems)
        -- for _, v in pairs(info.equip_probs) do
        --     for _, name in pairs(info.unit_names) do
        --         local itemList = {}
        --         for _, item in pairs(dropEquipItems[v.level]) do
        --             table.insert(itemList, {item.ItemName, item.Weight})
        --         end
        --         if Drop_Items[name] == nil then
        --             Drop_Items[name] = {}
        --         end
        --         table.insert(Drop_Items[name], {
        --             DropCount = 1,
        --             ItemList = itemList,
        --             DropProb = v.prob
        --         })
        --     end
        -- end

        -- for _, v in pairs(info.consumable_probs) do
        --     for _, name in pairs(info.unit_names) do
        --         local itemList = {}
        --         for _, item in pairs(dropConsumableItems[v.level]) do
        --             table.insert(itemList, {item.ItemName, item.Weight})
        --         end
        --         if Drop_Items[name] == nil then
        --             Drop_Items[name] = {}
        --         end
        --         table.insert(Drop_Items[name], {
        --             DropCount = 1,
        --             ItemList = itemList,
        --             DropProb = v.prob
        --         })
        --     end
        -- end
    end
end