ability_custom_trap_pig = ability_custom_trap_pig or class({})

LinkLuaModifier("modifier_pre_flight", "abilities/custom/ability_custom_trap_pig", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_missile", "abilities/custom/ability_custom_trap_pig", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_trap_pig_buff", "abilities/custom/ability_custom_trap_pig", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_trap_pig_debuff", "abilities/custom/ability_custom_trap_pig", LUA_MODIFIER_MOTION_NONE)

function ability_custom_trap_pig:OnSpellStart()
    if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end

    local targetPosition = caster:GetAbsOrigin()
    local safeRegions = BlockadeSystem:GetSafeRegions()
    if safeRegions and #safeRegions ~= 0 then
        local regionId = table.random(safeRegions)
        local region = BlockadeSystem:GetRegionById(regionId)
        if region then
            targetPosition = region:RandomPointInRegion()
        end
    end
    local trap_pig = CreateUnitByName("npc_custom_pig", targetPosition, true, caster, caster, caster:GetTeamNumber())
    trap_pig.OnEntityKilled = function(victim, attacker)
        local missile = CreateUnitByName("npc_dota_gyrocopter_homing_missile", victim:GetAbsOrigin(), true, victim, victim, victim:GetTeamNumber())
        local pre_flight_time = 2.5
        missile:AddNewModifier(victim, nil, "modifier_pre_flight", {duration = pre_flight_time, target = attacker:entindex()})
        missile:AddNewModifier(victim, nil, "modifier_missile", {target = attacker:entindex()})
    end
end

modifier_pre_flight = class({})

function modifier_pre_flight:IsHidden()		return true end
function modifier_pre_flight:IsPurgable()	return false end

function modifier_pre_flight:OnCreated(keys)
    if not IsServer() then return end
    self.interval = 0.05
    local caster = self:GetCaster()
    local parent = self:GetParent()
    if IsNull(caster) or IsNull(parent) then return end
    self.target = keys.target or -1
    parent:EmitSound("Hero_Gyrocopter.HomingMissile.Enemy")
end

function modifier_pre_flight:OnDestroy()
	if not IsServer() then return end
    local parent = self:GetParent()
	local caster = self:GetCaster()
	if IsNull(parent) or IsNull(caster) and not parent:IsAlive() then return end
	
	parent:StopSound("Hero_Gyrocopter.HomingMissile.Enemy")

    if parent:HasModifier("modifier_missile") then
        local target = EntIndexToHScript(self.target)
        if NotNull(target) or target:IsAlive() then
            parent:MoveToNPC(target)
        else
            local explosion_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_gyrocopter/gyro_guided_missile_death.vpcf", PATTACH_WORLDORIGIN, parent)
			ParticleManager:SetParticleControl(explosion_particle, 0, parent:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(explosion_particle)

			parent:EmitSound("Hero_Gyrocopter.HomingMissile.Destroy")
			parent:ForceKill(false)
			parent:AddNoDraw()
			return
        end

        parent:FindModifierByName("modifier_missile"):StartIntervalThink(self.interval)

		local missile_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_gyrocopter/gyro_guided_missile.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
		ParticleManager:SetParticleControlEnt(missile_particle, 0, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_fuse", parent:GetAbsOrigin(), true)
		parent:FindModifierByName("modifier_missile"):AddParticle(missile_particle, false, false, -1, false, false)
	else
		parent:ForceKill(false)
		parent:AddNoDraw()
    end
end

function modifier_pre_flight:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function modifier_pre_flight:OnDeath(keys)
    if not IsServer() then return end
    local target = EntIndexToHScript(self.target)
    local caster = self:GetCaster()
    local unit = keys.unit
    if IsNull(target) or IsNull(caster) or IsNull(unit) then return end
    if target == keys.unit then
        self:Destroy()
    end
end

modifier_missile = class({})
function modifier_missile:IsHidden()    return true end
function modifier_missile:IsPurgable()	return false end

function modifier_missile:OnCreated(keys)
    if not IsServer() then return end
    local caster = self:GetCaster()
    if IsNull(caster) then return end

    self.speed_counter = 0
    self.target = EntIndexToHScript(keys.target)
    self.pre_flight_time = 2.5
    self.propulsion_duration_pct = 25
    self.damage = 350
    self.hero_damage = 20
    self.stun_duration = 4
    self.speed = 500
    self.enemy_vision_time = 4
	if NotNull(self.target) then
		self.target_particle = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_gyrocopter/gyro_guided_missile_target.vpcf", PATTACH_OVERHEAD_FOLLOW, self.target, caster:GetTeamNumber())
		self:AddParticle(self.target_particle, false, false, -1, false, false)
	end
end

function modifier_missile:OnIntervalThink()
    local parent = self:GetParent()
    if IsNull(parent) then return end
	self.speed_counter	= self.speed_counter + 1
	self:SetStackCount(self.speed_counter)
    if NotNull(self.target) then 
        if not self.target:IsAlive() then 
            local explosion_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", PATTACH_WORLDORIGIN, parent)
            ParticleManager:SetParticleControl(explosion_particle, 0, parent:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(explosion_particle)

            parent:EmitSound("Hero_Gyrocopter.HomingMissile.Destroy")
            parent:ForceKill(false)
            parent:AddNoDraw()
            return
        end
        if (self.target:GetAbsOrigin() - parent:GetAbsOrigin()):Length2D() > 250 then
			parent:MoveToNPC(self.target)
		else
			parent:MoveToPosition(self.target:GetAbsOrigin())
		end
    end

    if NotNull(self.target) and (self.target:GetAbsOrigin() - parent:GetAbsOrigin()):Length2D() <= parent:GetHullRadius() then
		self.target:EmitSound("Hero_Gyrocopter.HomingMissile.Target")
		self.target:EmitSound("Hero_Gyrocopter.HomingMissile.Destroy")
		if not self.target:IsMagicImmune() then

			self.target:AddNewModifier(parent, nil,"modifier_stunned", {duration = self.stun_duration * (1 - self.target:GetStatusResistance())})

            local debuff = self.target:FindModifierByName("modifier_trap_pig_debuff")
            if NotNull(debuff) then
                debuff:IncrementStackCount()
            else
                self.target:AddNewModifier(self.target, nil, "modifier_trap_pig_debuff", {})
            end
			
			ApplyDamage({
				victim 			= self.target,
				damage 			= self.damage + (math.max(self:GetElapsedTime() - self.pre_flight_time, 0) * self.propulsion_duration_pct * 0.01),
				damage_type		= DAMAGE_TYPE_MAGICAL,
				attacker 		= parent,
			})
            local owner = parent:GetOwner()
            if NotNull(owner) then 
                owner = owner:GetOwner()
                if NotNull(owner) then 
                    local buff = owner:FindModifierByName("modifier_trap_pig_buff")
                    if NotNull(buff) then 
                        buff:IncrementStackCount()
                    else
                        owner:AddNewModifier(owner, nil, "modifier_trap_pig_buff", {})
                    end
                end
            end
        end

        AddFOWViewer(parent:GetTeamNumber(), self.target:GetAbsOrigin(), 400, self.enemy_vision_time, false)
		
        local explosion_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", PATTACH_WORLDORIGIN, parent)
        ParticleManager:SetParticleControl(explosion_particle, 0, parent:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(explosion_particle)
        
        self:StartIntervalThink(-1)
        parent:ForceKill(false)
        parent:AddNoDraw()
    end
end

function modifier_missile:OnDestroy()
	if not IsServer() then return end
	
	self:GetParent():StopSound("Hero_Gyrocopter.HomingMissile.Enemy")
end

function modifier_missile:CheckState()
	return {
		[MODIFIER_STATE_NO_UNIT_COLLISION]					= true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY]	= true,
		[MODIFIER_STATE_NOT_ON_MINIMAP]						= true,
		[MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS]	= true,
		[MODIFIER_STATE_IGNORING_STOP_ORDERS]				= true,
        [MODIFIER_STATE_MAGIC_IMMUNE]                       = true
	}
end

function modifier_missile:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
		
		MODIFIER_EVENT_ON_ATTACKED,
	}
end

function modifier_missile:GetModifierMoveSpeed_Absolute()
	if self:GetParent():HasModifier("modifier_pre_flight") then
		return 0
	else
		return self.speed + self:GetStackCount()
	end
end

function modifier_missile:GetModifierMoveSpeed_Limit()
	if self:GetParent():HasModifier("modifier_pre_flight") then
		return -0.01
	else
		return self.speed + self:GetStackCount()
	end
end

function modifier_missile:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_missile:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_missile:GetAbsoluteNoDamagePure()
    return 1
end

function modifier_missile:OnAttacked(keys)
    local target = keys.target
    local parent = self:GetParent()
    local attacker = keys.attacker
    if IsNull(target) or IsNull(parent) or IsNull(attacker) then return end
	if target == parent then
		if attacker:IsHero() or attacker:IsIllusion() then
			parent:SetHealth(parent:GetHealth() - self.hero_damage)
		elseif attacker:IsBuilding() then
			parent:SetHealth(parent:GetHealth() - (self.hero_damage / 2))
		end
		
		if parent:GetHealth() <= 0 then
			parent:EmitSound("Hero_Gyrocopter.HomingMissile.Destroy")
			parent:Kill(nil, attacker)
			parent:AddNoDraw()
		end
	end
end

modifier_trap_pig_buff = class({})

function modifier_trap_pig_buff:IsHidden() return false end
function modifier_trap_pig_buff:IsDebuff() return false end
function modifier_trap_pig_buff:IsPurgable() return false end
function modifier_trap_pig_buff:RemoveOnDeath() return false end

function modifier_trap_pig_buff:GetTexture()
	return "ability_custom_trap_pig"
end

function modifier_trap_pig_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end

function modifier_trap_pig_buff:GetModifierBonusStats_Strength()
	return self:GetStackCount() * 2
end

function modifier_trap_pig_buff:GetModifierBonusStats_Agility()
	return self:GetStackCount() * 2
end

function modifier_trap_pig_buff:GetModifierBonusStats_Intellect()
	return self:GetStackCount() * 2
end

function modifier_trap_pig_buff:OnCreated()
    self:SetStackCount(1)
end

modifier_trap_pig_debuff = class({})

function modifier_trap_pig_debuff:IsHidden() return false end
function modifier_trap_pig_debuff:IsDebuff() return true end
function modifier_trap_pig_debuff:IsPurgable() return false end
function modifier_trap_pig_debuff:RemoveOnDeath() return false end

function modifier_trap_pig_debuff:GetTexture()
	return "ability_custom_trap_pig"
end

function modifier_trap_pig_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end

function modifier_trap_pig_debuff:GetModifierBonusStats_Strength()
	return -self:GetStackCount() * 2
end

function modifier_trap_pig_debuff:GetModifierBonusStats_Agility()
	return -self:GetStackCount() * 2
end

function modifier_trap_pig_debuff:GetModifierBonusStats_Intellect()
	return -self:GetStackCount() * 2
end

function modifier_trap_pig_debuff:OnCreated()
    self:SetStackCount(1)
end