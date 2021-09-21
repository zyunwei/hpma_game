ability_custom_engraving = ability_custom_engraving or class({})

function ability_custom_engraving:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        if IsNull(caster) then return end
        local modifierParams = {
            duration = self:GetSpecialValueFor("duration"),
        }
        caster:AddNewModifier(caster, nil, "modifier_ability_custom_engraving", modifierParams)
    end
end

LinkLuaModifier("modifier_ability_custom_engraving", "abilities/custom/ability_custom_engraving", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_spirit_handler", "abilities/custom/ability_custom_engraving", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_spirit_hit", "abilities/custom/ability_custom_engraving", LUA_MODIFIER_MOTION_NONE)

modifier_ability_custom_engraving = class({})

function modifier_ability_custom_engraving:IsHidden() return false end
function modifier_ability_custom_engraving:IsDebuff() return false end
function modifier_ability_custom_engraving:IsPurgable() return false end
function modifier_ability_custom_engraving:RemoveOnDeath() return true end

function modifier_ability_custom_engraving:GetTexture()
    return "ability_custom_engraving"
end

function modifier_ability_custom_engraving:OnCreated(params)
    if IsServer() then
        self.spirit_num = 0
        self.max_engraving_num = 5
        self.spirits = {}
        self:StartIntervalThink(1)
        EmitSoundOn("Hero_Wisp.Spirits.Loop", self:GetCaster())
    end
end

function modifier_ability_custom_engraving:OnIntervalThink()
    if self.spirit_num == 0 then
        self:IncrementStackCount()
        if self:GetStackCount() == self.max_engraving_num then
            self:SetStackCount(0)
            self:SummonSpirits()
        end
    end
end

function modifier_ability_custom_engraving:SummonSpirits()
    local caster = self:GetCaster()
    if IsNull(caster) then return end
    local caster_position = caster:GetAbsOrigin()
    local forward = caster:GetForwardVector():Normalized() * 100
    local delta = 360 / self.max_engraving_num
    for i = 1, self.max_engraving_num do
        local newDirection = Vector2D:New(forward.x,forward.y)
        newDirection:Rotate(delta * i)
        local position = caster_position + Vector(newDirection.x, newDirection.y, 0)
        local newSpirit = CreateUnitByName("npc_dota_wisp_spirit", position, false, caster, caster, caster:GetTeam())
        table.insert(self.spirits, newSpirit)
        newSpirit.direction = newDirection
        newSpirit:AddNewModifier(caster, nil, "modifier_spirit_handler", {})
        if i == 1 then
            newSpirit.is_active = true
        end
        self.spirit_num = self.spirit_num + 1
    end
end

function modifier_ability_custom_engraving:OnDestroy()
    if IsServer() then
        for _, v in pairs(self.spirits) do
            if NotNull(v) then 
                v:ForceKill(false)
            end
        end
        self:GetCaster():StopSound("Hero_Wisp.Spirits.Loop")
    end
end

modifier_spirit_handler = class({})

function modifier_spirit_handler:RemoveOnDeath() return true end
function modifier_spirit_handler:CheckState()
	local state = {
		-- [MODIFIER_STATE_NO_TEAM_MOVE_TO] 	= true,
		[MODIFIER_STATE_NO_TEAM_SELECT] 	= true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] 		= true,
		[MODIFIER_STATE_MAGIC_IMMUNE] 		= true,
		[MODIFIER_STATE_INVULNERABLE] 		= true,
		[MODIFIER_STATE_UNSELECTABLE] 		= true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] 	= true,
		[MODIFIER_STATE_NO_HEALTH_BAR] 		= true,
        [MODIFIER_STATE_FLYING]             = true,
	}

	return state
end

function modifier_spirit_handler:GetEffectName()
    return "particles/units/heroes/hero_wisp/wisp_guardian_.vpcf"
end

function modifier_spirit_handler:OnCreated(params)
	if IsServer() then
        local parent = self:GetParent()
        if NotNull(parent) then 
            parent:SetBaseMoveSpeed(1000)
            parent:SetHullRadius(0)
        end
        self.turn_rate = 2
        self.delay = 1
        self.start_time = GameManager:GetGameTime()
        self.target = nil
        self.find_target = false
        self.damage = 350
        self:StartIntervalThink(0.03)
	end
end

function modifier_spirit_handler:OnIntervalThink()
	if IsServer() then
        local parent = self:GetParent()
        local caster = self:GetCaster()
        if IsNull(parent) or IsNull(caster) then return end
        if not self.find_target then
            local caster_position = caster:GetAbsOrigin()
            parent.direction:Rotate(self.turn_rate)
            local position = caster_position + Vector(parent.direction.x, parent.direction.y, 0)
            parent:SetAbsOrigin(position)
        elseif NotNull(self.target) then
            if not self.target:IsAlive() then
                parent:ForceKill(false)
                parent:AddNoDraw()
                return
            end
            -- if (self.target:GetAbsOrigin() - parent:GetAbsOrigin()):Length2D() > 250 then
            --     print("npc")
            --     parent:MoveToNPC(self.target)
            -- else
            --     print("pos")
            --     parent:MoveToPosition(self.target:GetAbsOrigin())
            -- end
            if (self.target:GetAbsOrigin() - parent:GetAbsOrigin()):Length2D() <= 150 then
                local damage = self.damage
                if self.target:HasModifier("modifier_spirit_hit") then
                    damage = damage / 2
                end
                self.target:AddNewModifier(caster, nil, "modifier_spirit_hit", {duration = 1})
                local damageTable = {
                    victim = self.target,
                    attacker = caster,
                    damage = damage,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                }
                EmitSoundOn("Hero_Wisp.Spirits.Target", parent)
                ApplyDamage(damageTable)
                parent:ForceKill(false)
                parent:AddNoDraw()
                return
            end
        end
        local past_time = GameManager:GetGameTime() - self.start_time
        if not self.find_target and past_time > self.delay and parent.is_active then
            local target = parent:GetNearestEnemyHero(1000, false)
            if IsNull(target) then
                target = parent:GetNearestEnemy(1000, false, 100)
            end
            if NotNull(target) then
                parent:MoveToNPC(target)
                self.target = target
                self.find_target = true

                CreateTimer(function()
                    if NotNull(caster) then
                        local parent_modifier = caster:FindModifierByName("modifier_ability_custom_engraving")
                        if NotNull(parent_modifier) then 
                            local spirits = parent_modifier.spirits
                            for _, spirit in ipairs(spirits) do
                                if not spirit.is_active then 
                                    spirit.is_active = true
                                    break
                                end
                            end
                        end
                    end
                end, 0.5)
            end
        end
	end
end

function modifier_spirit_handler:OnDestroy()
    if IsServer() then 
        local parent = self:GetParent()
        local caster = self:GetCaster()
        if NotNull(parent) then
            local ptx = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_guardian_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
            ParticleManager:SetParticleControl(ptx, 0, parent:GetAbsOrigin())

            local modifier = caster:FindModifierByName("modifier_ability_custom_engraving")
            if NotNull(modifier) then
                modifier.spirit_num = modifier.spirit_num - 1
                table.remove_value(modifier.spirits, parent)
            end
            
            CreateTimer(function()
                if NotNull(parent) then
                    parent:Destroy()
                end
            end, 0.5)
        end
    end
end

modifier_spirit_hit = class({})

function modifier_spirit_hit:IsHidden() return true end
function modifier_spirit_hit:IsDebuff() return true end
function modifier_spirit_hit:IsPurgable() return false end
function modifier_spirit_hit:RemoveOnDeath() return true end
