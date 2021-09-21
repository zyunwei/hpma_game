ability_custom_hujiadaofa = ability_custom_hujiadaofa or class({})

LinkLuaModifier("modifier_huajiadaofa_debuff", "abilities/custom/ability_custom_hujiadaofa", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_huajiadaofa_pull", "abilities/custom/ability_custom_hujiadaofa", LUA_MODIFIER_MOTION_HORIZONTAL)

function ability_custom_hujiadaofa:OnAbilityPhaseStart()
    return self:CheckPhaseStart()
end

function ability_custom_hujiadaofa:OnSpellStart()
    return self:CheckSpellStart()
end

function ability_custom_hujiadaofa:CastAbilityTarget(target)
    if target ~= nil and IsNull(target) == false then
        if IsNull(self:GetCaster()) then return end
        self.distance = self:GetSpecialValueFor("wave_distance")
        self.radius = self:GetSpecialValueFor("wave_radius")
        self.pull_duration = self:GetSpecialValueFor("pull_duration")
        self.pull_distance = self:GetSpecialValueFor("pull_distance")
        self.slow_duration  = self:GetSpecialValueFor("slow_duration")
        self.damage  = self:GetSpecialValueFor("damage")
        self.move_speed_slow  = self:GetSpecialValueFor("move_speed_slow")

        local affixAttr = self:GetCaster():GetCustomAttribute("hujiadaofa")
        if affixAttr and affixAttr > 0 then
            self.damage = self.damage * (1 + affixAttr * 0.01)
        end

        local direction = (target:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized()
        local projectile =
        {
            Ability				= self,
            EffectName			= "particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf",
            vSpawnOrigin		= self:GetCaster():GetAbsOrigin(),
            fDistance			= self.distance,
            fStartRadius		= self.radius,
            fEndRadius			= self.radius,
            Source				= self:GetCaster(),
            bHasFrontalCone		= false,
            bReplaceExisting	= false,
            iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            fExpireTime 		= GameRules:GetGameTime() + 5.0,
            bDeleteOnHit		= false,
            vVelocity			= Vector(direction.x,direction.y,0) * 1600,
            bProvidesVision		= false,
            ExtraData			= {}
        }

        if self:GetCaster():HasModifier("modifier_hujiadaoxinfa") then
            for i = 1, 8 do
                local newDirection = Vector2D:New(direction.x,direction.y)
                newDirection:Rotate(45 * i)
                projectile.vVelocity = Vector(newDirection.x,newDirection.y,0) * 1600
                ProjectileManager:CreateLinearProjectile(projectile)
            end
        else
            ProjectileManager:CreateLinearProjectile(projectile)
        end

        EmitSoundOnLocationWithCaster(self:GetCaster():GetAbsOrigin(), "Hero_Magnataur.ShockWave.Target", self:GetCaster())
    end
end


function ability_custom_hujiadaofa:OnProjectileHit_ExtraData(target, location, ExtraData)
    local caster = self:GetCaster()
    if IsNull(caster) or IsNull(target) then return end
    target:AddNewModifier(caster, nil, "modifier_huajiadaofa_debuff",{duration = self.slow_duration, move_speed_slow = self.move_speed_slow})
    if target:HasModifier("modifier_huajiadaofa_pull") == false then
        target:AddNewModifier(caster, nil, "modifier_huajiadaofa_pull",{duration = self.pull_duration, distance = self.pull_distance, x = location.x, y = location.y})
    end
    ApplyDamage({victim = target, attacker = caster, ability = self, damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL})
end

modifier_huajiadaofa_debuff = class({})

function modifier_huajiadaofa_debuff:IsHidden()
    return true
end

function modifier_huajiadaofa_debuff:GetEffectName()
	return "particles/units/heroes/hero_magnataur/magnataur_shockwave_hit.vpcf"
end

function modifier_huajiadaofa_debuff:OnCreated(params)
	self.movement_slow	= params.move_speed_slow or 75
end

function modifier_huajiadaofa_debuff:DeclareFunctions()
	local decFuncs =
	{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return decFuncs
end

function modifier_huajiadaofa_debuff:GetModifierMoveSpeedBonus_Percentage()
    if IsServer() then
	   return -self.movement_slow
    end
end

modifier_huajiadaofa_pull = class({})

function modifier_huajiadaofa_pull:IsHidden()
    return true
end

function modifier_huajiadaofa_pull:OnCreated(params)
	if not IsServer() then return end
	self.parent = self:GetParent()
    if IsNull(self.parent) then return end
	self.pull_duration	= params.duration or 0.2
	self.pull_distance	= params.distance or 150
	self.pull_speed	= self.pull_distance / self.pull_duration

	self.position	= GetGroundPosition(Vector(params.x, params.y, 0), self.parent)
	self.parent:StartGesture(ACT_DOTA_FLAIL)

	if self:ApplyHorizontalMotionController() == false then
		self:Destroy()
		return
	end
end

function modifier_huajiadaofa_pull:UpdateHorizontalMotion( me, dt )
	if not IsServer() then return end
    if IsNull(me) then return end
	local distance = (self.position - me:GetOrigin()):Normalized()
	me:SetOrigin( me:GetOrigin() + distance * self.pull_speed * dt )
end

function modifier_huajiadaofa_pull:OnDestroy()
	if not IsServer() then return end
    if IsNull(self.parent) then return end
	-- Destroy trees around landing zone
	GridNav:DestroyTreesAroundPoint( self.parent:GetOrigin(), self.parent:GetHullRadius(), true )

	self.parent:FadeGesture(ACT_DOTA_FLAIL)

	self.parent:RemoveHorizontalMotionController( self )
end
