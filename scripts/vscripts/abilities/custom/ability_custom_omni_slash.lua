ability_custom_omni_slash = ability_custom_omni_slash or class({})

LinkLuaModifier("modifier_ability_custom_omni_slash_buff", "abilities/custom/ability_custom_omni_slash", LUA_MODIFIER_MOTION_NONE)

function ability_custom_omni_slash:OnAbilityPhaseStart()
	return self:CheckPhaseStart()
end

function ability_custom_omni_slash:OnSpellStart()
	return self:CheckSpellStart()
end

function ability_custom_omni_slash:CastAbilityTarget(target)
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) or IsNull(target) then return end
    self.previous_position = caster:GetAbsOrigin()

    local modifierParams = {
        bonus_damage = self:GetSpecialValueFor("bonus_damage"),
        bonus_attack_speed = self:GetSpecialValueFor("bonus_attack_speed"),
        duration = self:GetSpecialValueFor("duration"),
    }
    local omnislash_modifier_handler

    omnislash_modifier_handler = caster:AddNewModifier(caster, nil, "modifier_ability_custom_omni_slash_buff", modifierParams)


    if omnislash_modifier_handler then
        omnislash_modifier_handler.original_caster = caster
    end

    self:SetActivated(false)

    -- caster:CenterCameraOnEntity(caster)


    FindClearSpaceForUnit(caster, target:GetAbsOrigin() + RandomVector(128), false)

    caster:EmitSound("Hero_Juggernaut.OmniSlash")



    self.current_position = caster:GetAbsOrigin()


    local trail_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_trail.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(trail_pfx, 0, self.previous_position)
    ParticleManager:SetParticleControl(trail_pfx, 1, self.current_position)
    ParticleManager:ReleaseParticleIndex(trail_pfx)
end

modifier_ability_custom_omni_slash_buff = class({})

function modifier_ability_custom_omni_slash_buff:CheckState()
	local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_ROOTED] = true
	}

	return state
end

function modifier_ability_custom_omni_slash_buff:StatusEffectPriority()
	return 20
end

function modifier_ability_custom_omni_slash_buff:GetStatusEffectName()
	return "particles/status_fx/status_effect_omnislash.vpcf"
end

function modifier_ability_custom_omni_slash_buff:IsHidden() return true end
function modifier_ability_custom_omni_slash_buff:IsPurgable() return false end
function modifier_ability_custom_omni_slash_buff:IsDebuff() return false end

function modifier_ability_custom_omni_slash_buff:OnCreated(params)
    if not IsServer() then return end

    self.bonus_damage = params.damage or 50
    self.bonus_attack_speed = params.bonus_attack_speed or 40
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.base_bonus_damage = 100
	self.last_enemy = nil



	self.slash = true

	if IsServer() then
		Timers:CreateTimer(FrameTime(), function()
			if (not self.parent:IsNull()) then
				
				self.bounce_range = 425
				
				self.hero_agility = self.original_caster:GetAgility()


				self:BounceAndSlaughter(true)
				
				
				local slash_rate = (self.caster:GetSecondsPerAttack() / 1.5)
				
				self:StartIntervalThink(slash_rate)
			end
		end)
	end
end

function modifier_ability_custom_omni_slash_buff:OnIntervalThink()

	self.hero_agility = self.original_caster:GetAgility()
	self:BounceAndSlaughter()

	local slash_rate = (self.caster:GetSecondsPerAttack() / 1.5)
	self:StartIntervalThink(slash_rate)
end

function modifier_ability_custom_omni_slash_buff:BounceAndSlaughter(first_slash)
	local order = FIND_ANY_ORDER
	
	if first_slash then
		order = FIND_CLOSEST
	end
	
	self.nearby_enemies = FindUnitsInRadius(
		self.parent:GetTeamNumber(),
		self.parent:GetAbsOrigin(),
		nil,
		self.bounce_range,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
		order,
		false
	)
	
	for count = #self.nearby_enemies, 1, -1 do
		if self.nearby_enemies[count] and (self.nearby_enemies[count]:GetName() == "npc_dota_unit_undying_zombie" or self.nearby_enemies[count]:GetName() == "npc_dota_elder_titan_ancestral_spirit") then
			table.remove(self.nearby_enemies, count)
		end
	end

	if #self.nearby_enemies >= 1 then
		for _,enemy in pairs(self.nearby_enemies) do
			if NotNull(enemy) then 
				local previous_position = self.parent:GetAbsOrigin()

				FindClearSpaceForUnit(self.parent, enemy:GetAbsOrigin() + RandomVector(100), false)
				

				local current_position = self.parent:GetAbsOrigin()


				self.parent:FaceTowards(enemy:GetAbsOrigin())
				

				AddFOWViewer(self:GetCaster():GetTeamNumber(), enemy:GetAbsOrigin(), 200, 1, false)


				self.slash = true
				
				self.parent:PerformAttack(enemy, true, true, true, true, true, false, false)



				enemy:EmitSound("Hero_Juggernaut.OmniSlash.Damage")


				local hit_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
				ParticleManager:SetParticleControl(hit_pfx, 0, current_position)
				ParticleManager:SetParticleControl(hit_pfx, 1, current_position)
				ParticleManager:ReleaseParticleIndex(hit_pfx)

				local trail_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_trail.vpcf", PATTACH_ABSORIGIN, self.parent)
				ParticleManager:SetParticleControl(trail_pfx, 0, previous_position)
				ParticleManager:SetParticleControl(trail_pfx, 1, current_position)
				ParticleManager:ReleaseParticleIndex(trail_pfx)

				if self.last_enemy ~= enemy then
					local dash_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_dash.vpcf", PATTACH_ABSORIGIN, self.parent)
					ParticleManager:SetParticleControl(dash_pfx, 0, previous_position)
					ParticleManager:SetParticleControl(dash_pfx, 2, current_position)
					ParticleManager:ReleaseParticleIndex(dash_pfx)
				end

				self.last_enemy = enemy

				break
			end
		end
	else
		self:Destroy()
	end
end

function modifier_ability_custom_omni_slash_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end

function modifier_ability_custom_omni_slash_buff:GetModifierAttackSpeedBonus_Constant()
    return self.bonus_attack_speed
end

function modifier_ability_custom_omni_slash_buff:GetModifierBaseAttack_BonusDamage()

	if self.hero_agility then
	local bonus_damage = self.hero_agility * self.base_bonus_damage * 0.01

	return bonus_damage
	end
	return 0
end

function modifier_ability_custom_omni_slash_buff:GetModifierPreAttack_BonusDamage(kv)
	return self.bonus_damage
end

function modifier_ability_custom_omni_slash_buff:GetOverrideAnimation()
	return ACT_DOTA_OVERRIDE_ABILITY_4
end

function modifier_ability_custom_omni_slash_buff:OnDestroy()
    if IsServer() then
        local parent = self:GetParent()
        if NotNull(parent) then 
            parent:FadeGesture(ACT_DOTA_OVERRIDE_ABILITY_4)
            parent:MoveToPositionAggressive(self.parent:GetAbsOrigin())
        end
    end
end