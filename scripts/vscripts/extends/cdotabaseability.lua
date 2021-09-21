
--@Class CDOTABaseAbility

local AbilityBehavior = {             
    DOTA_ABILITY_BEHAVIOR_ATTACK,            
    DOTA_ABILITY_BEHAVIOR_AURA,     
    DOTA_ABILITY_BEHAVIOR_AUTOCAST,    
    DOTA_ABILITY_BEHAVIOR_CHANNELLED,   
    DOTA_ABILITY_BEHAVIOR_DIRECTIONAL,    
    DOTA_ABILITY_BEHAVIOR_DONT_ALERT_TARGET,    
    DOTA_ABILITY_BEHAVIOR_DONT_CANCEL_MOVEMENT, 
    DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK,   
    DOTA_ABILITY_BEHAVIOR_DONT_RESUME_MOVEMENT,             
    DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING,    
    DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL,      
    DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE,   
    DOTA_ABILITY_BEHAVIOR_IGNORE_TURN ,        
    DOTA_ABILITY_BEHAVIOR_IMMEDIATE,         
    DOTA_ABILITY_BEHAVIOR_ITEM,              
    DOTA_ABILITY_BEHAVIOR_NOASSIST,            
    DOTA_ABILITY_BEHAVIOR_NONE,             
    DOTA_ABILITY_BEHAVIOR_NORMAL_WHEN_STOLEN, 
    DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE,       
    DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES,      
    DOTA_ABILITY_BEHAVIOR_RUNE_TARGET,         
    DOTA_ABILITY_BEHAVIOR_UNRESTRICTED ,  
}

--判断单体技能
function CDOTABaseAbility:IsUnitTarget()
    if IsNull(self) then return false end

    local b = tonumber(tostring(self:GetBehavior()))

    if self:IsHidden() then b = b - 1 end
    for k,v in pairs(AbilityBehavior) do
        repeat
            if v == 0 then break end
            b = b % v
        until true
    end

    if (b - DOTA_ABILITY_BEHAVIOR_AOE) == DOTA_ABILITY_BEHAVIOR_UNIT_TARGET then
        b = b - DOTA_ABILITY_BEHAVIOR_AOE
    end

    if b == DOTA_ABILITY_BEHAVIOR_UNIT_TARGET then
        return true
    end
    return false
end

--判断点目标技能
function CDOTABaseAbility:IsPoint()
    if IsNull(self) then return false end

    local b = tonumber(tostring(self:GetBehavior()))

     return bit.band(b,DOTA_ABILITY_BEHAVIOR_POINT) == DOTA_ABILITY_BEHAVIOR_POINT
end

--判断无目标技能
function CDOTABaseAbility:IsNoTarget()
    if IsNull(self) then return false end

    local b = tonumber(tostring(self:GetBehavior()))

    return bit.band(b,DOTA_ABILITY_BEHAVIOR_NO_TARGET) == DOTA_ABILITY_BEHAVIOR_NO_TARGET
end

function CDOTABaseAbility:StartCooldownByReduction(cooldown)
    if IsNull(self) then return end

    local caster = self:GetCaster()
    local reduction = caster:GetCooldownReduction()
    if self.OnStartCooldown then
        self:OnStartCooldown()
    end
    self:StartCooldown(cooldown*reduction)
    return cooldown*reduction
end

function CDOTABaseAbility:MinorAbilityUsed(setInactive)
    if IsNull(self) then return end

    local caster = self:GetCaster()
    if setInactive == nil then
        setInactive = true
    end
    if setInactive then
        self:SetActivated(false)
    end
end

function CDOTABaseAbility:CheckCostCrystal()
    if IsNull(self) then return false end
    local caster = self:GetCaster()
    if IsNull(caster) then return false end
    local crystalCost = self:GetCrystalCost()
    local crystal = caster:GetCustomAttribute("crystal")
    return crystal ~= nil and crystal >= crystalCost
end

function CDOTABaseAbility:CostCrystal()
    if IsNull(self) then return false end
    local caster = self:GetCaster()
    if IsNull(caster) then return false end
    local crystalCost = self:GetCrystalCost()
    local crystal = caster:GetCustomAttribute("crystal")
    if crystal ~= nil and crystal >= crystalCost then
    	caster:ModifyCustomAttribute("crystal", "crystal", -crystalCost)
        return true
    end
    return false
end

function CDOTABaseAbility:GetCrystalCost()
    local caster = self:GetCaster()
    local crystalCost = self:GetSpecialValueFor("crystal_cost")
    if IsNull(caster) or crystalCost == nil or crystalCost == 0 then
        return 0
    end
    if IsNull(caster) then
        return 0
    end
    if self:GetName() == "ability_custom_battle_trance" and caster:HasModifier("modifier_ganjiangjianxinfa") then
        local crystalCostReduce = caster:FindModifierByName("modifier_ganjiangjianxinfa"):GetCrystalCostReduce()
        crystalCost = crystalCost - crystalCostReduce
    end

    return crystalCost
end

function CDOTABaseAbility:CheckPhaseStart()
    local ability = self
    local canCast = ability:IsFullyCastable() and ability:IsCooldownReady() and ability:IsInAbilityPhase() == false
    if canCast == false or ability:CheckCostCrystal() == false then
        return false
    end

    return true
end

function CDOTABaseAbility:CheckSpellStart()
    local caster = self:GetCaster()
    if IsNull(caster) then return end
    local basemodifier = caster:FindModifierByName("modifier_hero_base")
    if NotNull(basemodifier) then
        basemodifier:CheckAndCastAbility(caster, self)
    end
end
