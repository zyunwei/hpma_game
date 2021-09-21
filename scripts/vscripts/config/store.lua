if STORE_CONFIG == nil then
    STORE_CONFIG = {}
    STORE_CONFIG.ItemList = {
        {
            ["type"] = "vip",
            ["name"] = "xxwar_vip_monthly",
            ["price_type"] = "diamond",
            ["price"] = "20",
        },
        {
            ["type"] = "props",
            ["name"] = "xxwar_store_respawn_coin",
            ["price_type"] = "diamond",
            ["price"] = "3",
        },
        {
            ["type"] = "props",
            ["name"] = "xxwar_store_respawn_coin",
            ["price_type"] = "bullion",
            ["price"] = "2000",
        },
        {
            ["type"] = "props",
            ["name"] = "xxwar_store_exchange_accessories_100",
            ["price_type"] = "bullion",
            ["price"] = "100000",
        },
        {
            ["type"] = "props",
            ["name"] = "xxwar_store_exchange_accessories_500",
            ["price_type"] = "bullion",
            ["price"] = "500000",
        },
        {
            ["type"] = "props",
            ["name"] = "xxwar_store_exchange_accessories_1000",
            ["price_type"] = "bullion",
            ["price"] = "1000000",
        },
    }

    STORE_CONFIG.LotteryGift = {
        { -- 100元奖品 （精华变迁）
            ["class"] = "",
            ["rate"] = 0.1,
            ["name"] = "xxwar_lottery_gift_1",
        },
        { -- 250元宝
            ["class"] = "type-2",
            ["rate"] = 38.4375,
            ["name"] = "xxwar_lottery_gift_2",
        },
        { -- 1000元奖品（点石成金）
            ["class"] = "",
            ["rate"] = 0.01,
            ["name"] = "xxwar_lottery_gift_3",
        },
        { -- 随机卡牌
            ["class"] = "type-2",
            ["rate"] = 61.4,
            ["name"] = "xxwar_lottery_gift_4",
        },
        { -- 500元奖品（敌法师宝宝）
            ["class"] = "",
            ["rate"] = 0.03,
            ["name"] = "xxwar_lottery_gift_5",
        },
        { -- 世界奖池大奖
            ["class"] = "type-2",
            ["rate"] = 0.0225,
            ["name"] = "xxwar_lottery_gift_6",
        },
    }

    CustomNetTables:SetTableValue("store_table", "store_table", STORE_CONFIG.ItemList)
    CustomNetTables:SetTableValue("store_table", "lottery_table", STORE_CONFIG.LotteryGift)
end
