ability_custom_exorcism = ability_custom_exorcism or class({})

LinkLuaModifier("modifier_ability_custom_exorcism_buff", "abilities/custom/ability_custom_exorcism", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_ghost", "abilities/custom/ability_custom_exorcism", LUA_MODIFIER_MOTION_NONE)

function ability_custom_exorcism:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
    local modifierParams = {
        max_ghost = self:GetSpecialValueFor("max_ghost"),
        damage = self:GetSpecialValueFor("damage"),
        duration = self:GetSpecialValueFor("duration"),
    }
    EmitSoundOn("Hero_DeathProphet.Exorcism.Cast", caster)
    caster:AddNewModifier(caster, nil, "modifier_ability_custom_exorcism_buff", modifierParams)
end

modifier_ability_custom_exorcism_buff = modifier_ability_custom_exorcism_buff or class({})

function modifier_ability_custom_exorcism_buff:IsHidden() return false end
function modifier_ability_custom_exorcism_buff:IsDebuff() return false end
function modifier_ability_custom_exorcism_buff:IsPurgable() return false end
function modifier_ability_custom_exorcism_buff:RemoveOnDeath() return true end

function modifier_ability_custom_exorcism_buff:GetTexture()
    return "ability_custom_exorcism"
end

function modifier_ability_custom_exorcism_buff:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_ability_custom_exorcism_buff:OnCreated(params)
    self.max_ghost = params.max_ghost or 10
    self.damage = params.damage or 50
    if IsServer() then
        self.ghost_count = 0
        self.ghosts = {}
    end
end


function modifier_ability_custom_exorcism_buff:OnAttackLanded(keys)
    if not IsServer() then return end
    local attacker = keys.attacker
    local target = keys.target
    local parent = self:GetParent()
    if IsNull(attacker) or IsNull(target) or IsNull(parent) then return end
    if parent ~= attacker then return end
    if self.ghost_count < self.max_ghost then
        local ghost = CreateUnitByName("npc_custom_death_prophet_exorcism_spirit", parent:GetAbsOrigin(), true, parent, parent, parent:GetTeamNumber())
        if NotNull(ghost) then
            table.insert(self.ghosts, ghost:entindex())
            self.ghost_count = self.ghost_count + 1
            ghost:AddNewModifier(parent, nil, "modifier_ghost", {damage = self.damage})
        end
    end
end

function modifier_ability_custom_exorcism_buff:OnDestroy()
    if IsServer() then 
        for _, entIndex in ipairs(self.ghosts) do
            local ghost = EntIndexToHScript(entIndex)
            if NotNull(ghost) then
                ghost:Destroy()
            end
        end
    end
end

modifier_ghost = class({})

function modifier_ghost:IsHidden() return true end
function modifier_ghost:IsDebuff() return false end
function modifier_ghost:IsPurgable() return false end
function modifier_ghost:RemoveOnDeath() return true end

function modifier_ghost:OnCreated(params)
    if IsServer() then
        self.damage = params.damage or 50
        self:StartIntervalThink(0.5)
    end
end

function modifier_ghost:OnIntervalThink()
    local parent = self:GetParent()
    local caster = self:GetCaster()
    if IsNull(parent) or IsNull(caster) then return end
    if NotNull(self.target) and (self.target:GetAbsOrigin() - parent:GetAbsOrigin()):Length2D() <= parent:GetHullRadius() then
        ApplyDamage({ victim = self.target, attacker = parent, damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL})
        self.target = nil
    end
    if parent:IsMoving() then return end
    local enemies = FindUnitsInRadius(parent:GetTeamNumber(), caster:GetAbsOrigin(),
    parent, 600, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, 0, true)
    if #enemies ~= 0 then
        self.target = table.random(enemies)
        parent:MoveToPosition(self.target:GetAbsOrigin())
    else
        local randomPos = caster:GetAbsOrigin() + RandomVector(300)
        parent:MoveToPosition(randomPos)
    end
end

function modifier_ghost:CheckState()
	return {
		[MODIFIER_STATE_NO_UNIT_COLLISION]					= true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY]	= true,
		[MODIFIER_STATE_NOT_ON_MINIMAP]						= true,
		[MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS]	= true,
		[MODIFIER_STATE_IGNORING_STOP_ORDERS]				= true,
        [MODIFIER_STATE_MAGIC_IMMUNE]                       = true,
        [MODIFIER_STATE_NO_HEALTH_BAR]                      = true,
        [MODIFIER_STATE_ATTACK_IMMUNE]                      = true,
        [MODIFIER_STATE_FLYING]                             = true,
        [MODIFIER_STATE_UNSELECTABLE]                       = true,
	}
end