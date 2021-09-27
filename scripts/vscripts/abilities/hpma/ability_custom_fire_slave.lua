ability_custom_fire_slave = ability_custom_fire_slave or class({})

function ability_custom_fire_slave:OnAbilityPhaseStart()
    return self:CheckPhaseStartWithMessage()
end

function ability_custom_fire_slave:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function ability_custom_fire_slave:OnSpellStart()
	if IsServer() then
		-- Preventing projectiles getting stuck in one spot due to potential 0 length vector
		if self:GetCursorPosition() == self:GetCaster():GetAbsOrigin() then
			self:GetCaster():SetCursorPosition(self:GetCursorPosition() + self:GetCaster():GetForwardVector())
		end
	
		local caster = self:GetCaster()
		local target_loc = self:GetCursorPosition()
		local caster_loc = caster:GetAbsOrigin()

		-- Parameters
		local primary_damage = self:GetSpecialValueFor("primary_damage")
		local secondary_damage = self:GetSpecialValueFor("secondary_damage")
		local secondary_amount = self:GetSpecialValueFor("secondary_amount")
		local speed = self:GetSpecialValueFor("speed")
		local width_initial = self:GetSpecialValueFor("width_initial")
		local width_end = self:GetSpecialValueFor("width_end")
		local primary_distance = self:GetCastRange(caster_loc,caster)
		local secondary_distance = self:GetSpecialValueFor("secondary_distance")
		local split_delay = self:GetSpecialValueFor("split_delay")
		local secondary_width_initial = self:GetSpecialValueFor("secondary_width_initial")
		local secondary_width_end = self:GetSpecialValueFor("secondary_width_end")

		-- Distances
		local direction = (target_loc - caster_loc):Normalized()
		local primary_direction = (target_loc - caster_loc):Normalized()
		local split_timer = (CalculateDistance(caster_loc,target_loc) / speed)
		local velocity = direction * speed
		local primary_velocity = primary_direction * speed

		local projectile =
			{
				Ability				= self,
				EffectName			= "particles/units/heroes/hero_lina/lina_spell_dragon_slave.vpcf",
				vSpawnOrigin		= caster_loc,
				fDistance			= primary_distance,
				fStartRadius		= width_initial,
				fEndRadius			= width_end,
				Source				= caster,
				bHasFrontalCone		= true,
				bReplaceExisting	= false,
				iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
				iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
				iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				fExpireTime 		= GameRules:GetGameTime() + 10.0,
				bDeleteOnHit		= false,
				vVelocity			= Vector(velocity.x,velocity.y,0),
				bProvidesVision		= false,
				ExtraData			= {damage = primary_damage}
			}
		ProjectileManager:CreateLinearProjectile(projectile)

		if secondary_amount == 0 then
			return true
		end

		caster:EmitSound("Hero_Lina.DragonSlave")

		Timers:CreateTimer(split_timer - 0.1, function()
			Timers:CreateTimer(split_delay + 0.1, function()
				local particle_fx2 = ParticleManager:CreateParticle("particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_loadout.vpcf", PATTACH_ABSORIGIN, caster)
				ParticleManager:SetParticleControl(particle_fx2, 0, target_loc)
				Timers:CreateTimer(1, function()
					ParticleManager:DestroyParticle(particle_fx2, false)
					ParticleManager:ReleaseParticleIndex(particle_fx2)
				end)
			end)
		end)

		for i = 1, secondary_amount, 1 do
			Timers:CreateTimer((1 + i) * split_delay, function()
				EmitSoundOnLocationWithCaster( target_loc, "Hero_Lina.DragonSlave", caster )
				local direction = (target_loc - caster:GetAbsOrigin()):Normalized()
				velocity = direction * speed
				local projectile =
					{
						Ability				= self,
						EffectName			= "particles/units/heroes/hero_lina/lina_spell_dragon_slave.vpcf",
						vSpawnOrigin		= caster:GetAbsOrigin(),
						fDistance			= secondary_distance,
						fStartRadius		= secondary_width_initial,
						fEndRadius			= secondary_width_end,
						Source				= caster,
						bHasFrontalCone		= true,
						bReplaceExisting	= false,
						iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
						iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
						iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
						fExpireTime 		= GameRules:GetGameTime() + 10.0,
						bDeleteOnHit		= false,
						vVelocity			= Vector(velocity.x,velocity.y,0),
						bProvidesVision		= false,
						ExtraData			= {damage = secondary_damage}
					}
				ProjectileManager:CreateLinearProjectile(projectile)
			end)
		end

		local new_loc = target_loc + primary_direction * secondary_distance
		local new_timer = (CalculateDistance(caster_loc,new_loc) / speed)

		Timers:CreateTimer((new_timer + split_delay), function()
			EmitSoundOnLocationWithCaster( new_loc, "Hero_Lina.DragonSlave", caster )

			local projectile =
				{
					Ability				= self,
					EffectName			= "particles/units/heroes/hero_lina/lina_spell_dragon_slave.vpcf",
					vSpawnOrigin		= new_loc,
					fDistance			= primary_distance,
					fStartRadius		= width_initial,
					fEndRadius			= width_end,
					Source				= caster,
					bHasFrontalCone		= true,
					bReplaceExisting	= false,
					iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
					iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
					iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
					fExpireTime 		= GameRules:GetGameTime() + 10.0,
					bDeleteOnHit		= false,
					vVelocity			= Vector(primary_velocity.x,primary_velocity.y,0),
					bProvidesVision		= false,
					ExtraData			= {damage = primary_damage}
				}

			ProjectileManager:CreateLinearProjectile(projectile)
		end)
	end
end

function ability_custom_fire_slave:OnProjectileHit_ExtraData(target, location, ExtraData)
	if target then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_spell_dragon_slave_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControl(pfx, 0, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx, 1, target:GetAbsOrigin())

		ApplyDamage({victim = target, attacker = self:GetCaster(), ability = self, damage = ExtraData.damage, damage_type = self:GetAbilityDamageType()})
	end

	return false
end
