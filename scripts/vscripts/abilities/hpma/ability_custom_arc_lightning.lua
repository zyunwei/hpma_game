ability_custom_arc_lightning = ability_custom_arc_lightning or class({})

LinkLuaModifier("modifier_custom_chain", "abilities/hpma/ability_custom_arc_lightning", LUA_MODIFIER_MOTION_NONE)

function ability_custom_arc_lightning:OnAbilityPhaseStart()
    return self:CheckPhaseStartWithMessage()
end

function ability_custom_arc_lightning:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
    local target = self:GetCursorTarget()
	if IsNull(caster) or IsNull(target) then return end
	local ability = self
	if ability:CostCrystal() then
        caster:EmitSound("Hero_Zuus.ArcLightning.Cast")
        if not target:TriggerSpellAbsorb(self) then
            local head_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_head.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
            ParticleManager:SetParticleControlEnt(head_particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(head_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
            ParticleManager:SetParticleControl(head_particle, 62, Vector(2, 0, 2))
    
            ParticleManager:ReleaseParticleIndex(head_particle)
            
            caster:AddNewModifier(caster, self, "modifier_custom_chain", {
                starting_unit_entindex	= target:entindex()
            })
        end
	end
end

modifier_custom_chain = class({})

function modifier_custom_chain:IsHidden()		return true end
function modifier_custom_chain:IsPurgable()		return false end
function modifier_custom_chain:RemoveOnDeath()	return false end
function modifier_custom_chain:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_custom_chain:OnCreated(keys)
	if not IsServer() or not self:GetAbility() then return end

	self.arc_damage = 80
	self.radius = 600	
	self.jump_count	= 5		
	self.jump_delay	= 0.2	

	self.starting_unit_entindex	= keys.starting_unit_entindex
	
	self.units_affected			= {}
	
	if self.starting_unit_entindex and EntIndexToHScript(self.starting_unit_entindex) then
		
		self.current_unit						= EntIndexToHScript(self.starting_unit_entindex)
		self.units_affected[self.current_unit]	= 1
		
		ApplyDamage({
			victim 			= self.current_unit,
			damage 			= self.arc_damage,
			damage_type		= DAMAGE_TYPE_MAGICAL,
			damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
			attacker 		= self:GetCaster(),
			ability 		= self:GetAbility()
		})
	else
		self:Destroy()
		return
	end
	
	self.unit_counter			= 0
	
	self:StartIntervalThink(self.jump_delay)
end

function modifier_custom_chain:OnIntervalThink()
	self.zapped = false
	
	for _, enemy in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self.current_unit:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)) do
		if not self.units_affected[enemy] and enemy ~= self.current_unit and enemy ~= self.previous_unit then
			enemy:EmitSound("Hero_Zuus.ArcLightning.Target")
			
			self.lightning_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.current_unit)
			ParticleManager:SetParticleControlEnt(self.lightning_particle, 0, self.current_unit, PATTACH_POINT_FOLLOW, "attach_hitloc", self.current_unit:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(self.lightning_particle, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
			ParticleManager:SetParticleControl(self.lightning_particle, 62, Vector(2, 0, 2))
			ParticleManager:ReleaseParticleIndex(self.lightning_particle)
		
			self.unit_counter						= self.unit_counter + 1
			self.previous_unit						= self.current_unit
			self.current_unit						= enemy
			
			if self.units_affected[self.current_unit] then
				self.units_affected[self.current_unit]	= self.units_affected[self.current_unit] + 1
			else
				self.units_affected[self.current_unit]	= 1
			end
			
			self.zapped								= true
			
			ApplyDamage({
				victim 			= enemy,
				damage 			= self.arc_damage,
				damage_type		= DAMAGE_TYPE_MAGICAL,
				damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
				attacker 		= self:GetCaster(),
				ability 		= self:GetAbility()
			})
			
			break
		end
	end
end