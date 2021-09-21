modifier_boss_shakeground_lua_thinker = class({})

-----------------------------------------------------------------------------

function modifier_boss_shakeground_lua_thinker:OnCreated( kv )
	if IsServer() then
		if IsNull(self:GetAbility()) then return end
		self.radius = self:GetAbility():GetSpecialValueFor("radius")
		self.damage = self:GetAbility():GetSpecialValueFor("damage")
		self:StartIntervalThink( 1 )
	end
end

-----------------------------------------------------------------------------

function modifier_boss_shakeground_lua_thinker:OnIntervalThink()
	if IsServer() then
		if IsNull(self:GetCaster()) or IsNull(self:GetParent()) then return end
		if self:GetCaster():IsAlive()  then
			EmitSoundOnLocationWithCaster( self:GetParent():GetOrigin(), "Hero_Leshrac.Split_Earth", self:GetCaster() )
			local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_leshrac/leshrac_split_earth.vpcf", PATTACH_WORLDORIGIN,  self:GetCaster()  )
			ParticleManager:SetParticleControl( nFXIndex, 0, self:GetCaster():GetAbsOrigin() )
			ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.radius,1,1 ) )
			ParticleManager:ReleaseParticleIndex( nFXIndex )
			local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), self:GetParent(), self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE , 0, false )
			for _,enemy in pairs( enemies ) do
				if NotNull(enemy) and enemy:IsInvulnerable() == false then
					local damageInfo =
					{
						victim = enemy,
						attacker = self:GetCaster(),
						damage = self.damage,
						damage_type = DAMAGE_TYPE_MAGICAL,
						ability = self,
					}

					ApplyDamage( damageInfo )
				end
			end

			ScreenShake( self:GetParent():GetOrigin(), 10.0, 100.0, 0.5, 1300.0, 0, true )
		else
			UTIL_Remove( self:GetParent() )
			return nil
		end
	end
end

-----------------------------------------------------------------------------

function modifier_boss_shakeground_lua_thinker:OnDestroy()
	if IsServer() then
		if IsNull(self:GetCaster()) or IsNull(self:GetParent()) then return end
		if self:GetCaster():IsAlive() then
			UTIL_Remove( self:GetParent() )
		end
	end
end

-----------------------------------------------------------------------------

