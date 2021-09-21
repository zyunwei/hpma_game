TELEPORT_POSITION = {
    Vector(-4560, 6450, 265),
    Vector(0, 7200, 480),
    Vector(3550, 7500, 550),
    Vector(-5450, 620, 480),
    Vector(0, 0, 570),
    Vector(5900, -1300, 380),
    Vector(-4500, -5568, 96),
    Vector(-1030, -5188, 200),
    Vector(4400, -7650, 200),
}

for i, position in ipairs(TELEPORT_POSITION) do
    local pos = {
        x = (position.x + GameRules.XW.MapBorderSize) / (2 * GameRules.XW.MapBorderSize),
        y = (GameRules.XW.MapBorderSize - position.y) / (2 * GameRules.XW.MapBorderSize)
    }
    CustomNetTables:SetTableValue("Teleports", tostring(i), {pos = pos})
end
