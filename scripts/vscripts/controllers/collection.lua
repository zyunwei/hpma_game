if CollectionCtrl == nil then
	CollectionCtrl = RegisterController('collection')
    setmetatable(CollectionCtrl, CollectionCtrl)
end

local public = CollectionCtrl


function public:init()
    self.__spawn_points = COLLECTION_SPAWN_POINT
    self:SpawnCollections()
end

function public:SpawnCollections()
    for collectionName, _ in pairs(COLLECTION_UNIT_NAME) do
        self:SpawnCollectionByName(collectionName)
    end
end

function public:SpawnCollectionByName(collectionName)
    local spawnCount = COLLECTION_SPAWN_COUNT[collectionName]
    for i = 1, spawnCount do
        local spawnPoint = table.random(self.__spawn_points)
        if spawnPoint then
            table.remove_value(self.__spawn_points, spawnPoint)
            local collection = CreateUnitByName(collectionName, spawnPoint, true, nil, nil, DOTA_TEAM_NEUTRALS)
            if NotNull(collection) then
                collection:SetAbility("ability_collection_unit")
            end
        end
    end
end
