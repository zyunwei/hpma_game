if NpcCtrl == nil then
	NpcCtrl = RegisterController('npcs')
	NpcCtrl.__all_npc = {}
end

local public = NpcCtrl

function public:init()
    for _, info in ipairs(NPC_CONFIG) do
        local npcUnit = CreateUnitByName(info.unitName, info.position, true, nil, nil, DOTA_TEAM_NEUTRALS)
        if npcUnit ~= nil then
            npcUnit:SetHullRadius(0)
            npcUnit:SetForwardVector(info.faceVector)
            npcUnit:SetAbility("ability_npc_unit")
            table.insert(self.__all_npc, npcUnit:GetEntityIndex())
        end
    end

	CustomNetTables:SetTableValue("Common", "all_npc_entity_index",  self.__all_npc)
end

function public:__call(hero)

end

function public:OnTouching(npc, hero)
	-- print("NpcCtrl:OnTouching")
end

function public:HasTouchingHero(npc, hero)
	return hero:HasModifier("modifier_npc_hero_touching")
end

function public:GetNpcItems(npc)
    local itemList = {}
    local npcInfo = table.find(NPC_CONFIG, "unitName", npc:GetUnitName())

    if npcInfo and npcInfo.options then
        for _, v in ipairs(npcInfo.options) do
            if v.optionType == "item" then
                table.insert(itemList, {
                    display = "item",
                    itemname = v.targetName,
                    cost = v.requireAmount
                })
            elseif v.optionType == "boss" then
                table.insert(itemList, {
                    display = "boss",
                    itemname = v.targetName,
                    cost = v.requireAmount
                })
            elseif v.optionType == "creep_refresh" then
                table.insert(itemList, {
                    display = "creep_refresh",
                    itemname = v.targetName,
                    cost = RefreshCreepSystem:GetRegionRefreshCostGold(v.regionId),
                    regionId = v.regionId,
                })
            elseif v.optionType == "creep_upgrade" then
                local cost = RefreshCreepSystem:GetRegionUpgradeCostGold(v.regionId)
                if cost then
                    table.insert(itemList, {
                        display = "creep_upgrade",
                        itemname = v.targetName,
                        cost = cost,
                        regionId = v.regionId,
                    })
                end
            end
        end
    end

    return itemList
end