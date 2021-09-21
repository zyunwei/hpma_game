modifier_animal = class({})

local public = modifier_animal

function public:IsDebuff() return false end

function public:IsHidden() return true end

function public:IsPurgable() return false end

function public:OnCreated()
    if IsServer() then
        -- Timers:CreateTimer({
        --     endTime = RandomFloat(0, 5),
        --     callback = function()
        --         if IsNull(self) == false and self.GetParent ~= nil then
        --             local parent = self:GetParent()
        --             if IsNull(parent) == false then
        --                 self:StartIntervalThink(5)
        --             end
        --         end
        --     end
        -- })
    end
end

function public:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_PRE_ATTACK
    }
end

function public:OnTakeDamage(params)
    if not IsServer() then return end

    local target = params.unit
    local unit = self:GetParent()

    if unit:entindex() ~= target:entindex() then
        return
    end

    local nowTime = GameRules:GetGameTime()
    if self.LastMoveTime ~= nil and (nowTime - self.LastMoveTime) < 5 then
        return
    end

    self:Escape(params.attacker)
end

function public:GetModifierPreAttack(modifierAttackEvent)
    if not IsServer() then return end

    local target = modifierAttackEvent.target
    if target == nil or target:IsNull() then
        return
    end
    self:Escape(target)
end

function public:Escape(attacker)
    if not IsServer() then return end

    local nowTime = GameRules:GetGameTime()
    local unit = self:GetParent()
    local attackerPos = attacker:GetAbsOrigin()
    local unitPos = unit:GetAbsOrigin()
    local direction = (unitPos - attackerPos)
    direction = Vector2D:New(direction.x, direction.y)
    direction:Rotate(RandomInt(-60, 60))
    local d = Vector2D:New(direction.x,direction.y):Length()
    local moveDistance = RandomInt(500, 1000)
    direction = Vector(direction.x/d * moveDistance, direction.y/d * moveDistance, 0)
    local targetPos = unitPos + direction

    if GridNav:CanFindPath(unitPos, targetPos) then 
        unit:Interrupt()
        unit:MoveToPosition(targetPos)
        self.LastMoveTime = nowTime
    end
end

-- function public:OnIntervalThink()
--     if not IsServer() then return end

--     local nowTime = GameRules:GetGameTime()
--     if self.LastMoveTime ~= nil and (nowTime - self.LastMoveTime) < 5 then
--         return
--     end

--     local unit = self:GetParent() 

--     local targetPos = unit:GetAbsOrigin() + RandomVector(500)

--     if GridNav:CanFindPath(unit:GetAbsOrigin(), targetPos) then 
--         unit:Interrupt()
--         unit:MoveToPosition(targetPos)
--         self.LastMoveTime = nowTime
--     end
-- end