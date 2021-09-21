ability_custom_weakness_breaker = ability_custom_weakness_breaker or class({})

LinkLuaModifier("modifier_ability_custom_weakness_breaker", "abilities/custom/ability_custom_weakness_breaker", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_weekness", "abilities/custom/ability_custom_weakness_breaker", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_weekness_slow", "abilities/custom/ability_custom_weakness_breaker", LUA_MODIFIER_MOTION_NONE)

function ability_custom_weakness_breaker:OnAbilityPhaseStart()
    return self:CheckPhaseStart()
end

function ability_custom_weakness_breaker:OnSpellStart()
    return self:CheckSpellStart()
end

function ability_custom_weakness_breaker:CastAbilityTarget(target)
	local caster = self:GetCaster()
	if IsNull(caster) or IsNull(target) then
		return
	end
    local modifierParams = {
        bonus_damage_pct = self:GetSpecialValueFor("bonus_damage_pct"),
        slow_movement_speed_pct = self:GetSpecialValueFor("slow_movement_speed_pct"),
        duration = self:GetSpecialValueFor("duration"),
    }

	target:AddNewModifier(caster, nil, "modifier_ability_custom_weakness_breaker", modifierParams)
end

modifier_ability_custom_weakness_breaker = class({})

function modifier_ability_custom_weakness_breaker:IsHidden() return false end
function modifier_ability_custom_weakness_breaker:IsDebuff() return true end
function modifier_ability_custom_weakness_breaker:IsPurgable() return false end
function modifier_ability_custom_weakness_breaker:RemoveOnDeath() return true end

function modifier_ability_custom_weakness_breaker:GetTexture()
    return "ability_custom_weakness_breaker"
end

function modifier_ability_custom_weakness_breaker:OnCreated(params)
	if IsServer() then
        local parent = self:GetParent()
        if IsNull(parent) then return end
        self.turn_rate_slow = 90
        self.bonus_damage_pct = params.bonus_damage_pct
        self.slow_movement_speed_pct = params.slow_movement_speed_pct
        self.slow_duration = 5
        self.stun_duration = 1.5
        self.direction = {1, 2, 3, 4}
        self.break_count = 0
        self.weekness_direction = nil
        self.weekness = self:CreateWeakness()
        self:StartIntervalThink(0.03)
	end
end

function modifier_ability_custom_weakness_breaker:DeclareFunctions()
	local decFuncs =
		{
			MODIFIER_EVENT_ON_ATTACKED,
            MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
		}
	return decFuncs
end

function modifier_ability_custom_weakness_breaker:GetModifierTurnRate_Percentage()
    if IsServer() then
        return -self.turn_rate_slow or -80
    end
end

function modifier_ability_custom_weakness_breaker:OnAttacked(keys)
    if not IsServer() then return end
    local target = keys.target
    local parent = self:GetParent()
    local attacker = keys.attacker
    local caster = self:GetCaster()
    local damage = keys.damage
    if IsNull(target) or IsNull(parent) or IsNull(attacker) or IsNull(caster) then return end
	if target == parent and attacker == caster then
        local forward = parent:GetForwardVector():Normalized() * 100
        local newDirection = Vector2D:New(forward.x, forward.y)
        newDirection:Rotate(90 * self.weekness_direction)
        local weekness_angles = VectorToAngles(Vector(newDirection.x, newDirection.y, 0)).y
        local attack_angles = VectorToAngles(attacker:GetOrigin() - parent:GetOrigin()).y
        local angle_diff = math.abs(AngleDiff(weekness_angles, attack_angles))
        if angle_diff <= 20 then
            self.weekness = self:CreateWeakness()
            self.break_count = self.break_count + 1
            local damageTable = {
                victim = target,
                attacker = attacker,
                damage = damage * self.bonus_damage_pct * 0.01,
                damage_type = DAMAGE_TYPE_PURE,
            }
            ApplyDamage(damageTable)
            local slow_duration = 0.5
            local slow_pct = self.slow_movement_speed_pct
            if self.break_count == 4 then
                slow_duration = 5
                target:AddNewModifier(attacker, nil, "modifier_stunned", {duration = 1.5 - target:GetStatusResistance()})
                self:Destroy()
            end
            target:AddNewModifier(attacker, nil, "modifier_weekness_slow", {slow_pct = slow_pct, duration = slow_duration - target:GetStatusResistance()})
        end
	end
end

function modifier_ability_custom_weakness_breaker:OnIntervalThink()
    if not IsServer() then return end
    local parent = self:GetParent()
    if IsNull(parent) then return end
    if NotNull(self.weekness) then 
        local forward = parent:GetForwardVector():Normalized() * 100
        local newDirection = Vector2D:New(forward.x, forward.y)
        newDirection:Rotate(90 * self.weekness_direction)
        local position = parent:GetAbsOrigin() + Vector(newDirection.x, newDirection.y, 0)
        self.weekness:SetAbsOrigin(position)
    end
end

function modifier_ability_custom_weakness_breaker:CreateWeakness()
    if NotNull(self.weekness) then
        self.weekness:ForceKill(false)
    end
    if #self.direction == 0 then return end
    local parent = self:GetParent()
    local forward = parent:GetForwardVector():Normalized() * 100
    local newDirection = Vector2D:New(forward.x, forward.y)
    local direction = table.random(self.direction)
    newDirection:Rotate(90 * direction)
    table.remove_value(self.direction, direction)
    self.weekness_direction = direction
    local position = parent:GetAbsOrigin() + Vector(newDirection.x, newDirection.y, 0)
    return CreateModifierThinker(parent, nil, "modifier_weekness", nil, position, parent:GetTeamNumber(), false)
end

function modifier_ability_custom_weakness_breaker:OnDestroy()
    if not IsServer() then return end
    if NotNull(self.weekness) then
        self.weekness:ForceKill(false)
    end
end

modifier_weekness = class({})

function modifier_weekness:RemoveOnDeath() return true end

function modifier_weekness:OnCreated()
    if not IsServer() then return end
    local parent = self:GetParent()
    if IsNull(parent) then return end
    local particle_index = ParticleManager:CreateParticle("particles/econ/items/sniper/sniper_fall20_immortal/sniper_fall20_immortal_crosshair_bullseye.vpcf", PATTACH_CENTER_FOLLOW, parent)
    ParticleManager:SetParticleControl(particle_index, 0, parent:GetAbsOrigin())
    self:AddParticle(particle_index, false, false, -1, false, false)
end

modifier_weekness_slow = class({})

function modifier_weekness_slow:IsHidden() return false end
function modifier_weekness_slow:IsDebuff() return true end
function modifier_weekness_slow:IsPurgable() return false end
function modifier_weekness_slow:RemoveOnDeath() return true end

function modifier_weekness_slow:OnCreated(params)
	if IsServer() then
        self.slow_pct = params.slow_pct
	end
end

function modifier_weekness_slow:GetTexture()
    return "ability_custom_weakness_breaker"
end


function modifier_weekness_slow:DeclareFunctions()
	local decFuncs =
		{
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		}
	return decFuncs
end

function modifier_weekness_slow:GetModifierMoveSpeedBonus_Percentage()
    if IsServer() then
        return -self.slow_pct or -50
    end
end