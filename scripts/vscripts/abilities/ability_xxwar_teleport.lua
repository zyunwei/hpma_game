ability_xxwar_teleport = ability_xxwar_teleport or class({})

function ability_xxwar_teleport:CastFilterResultTarget(target)
    return UF_SUCCESS
end

function ability_xxwar_teleport:OnAbilityPhaseStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
    self.target = self:GetCursorTarget()
    if IsNull(self.target) or IsNull(caster) then
        return false
    end

    self.start_pos = caster:GetAbsOrigin()
    self.end_pos = self.target:GetAbsOrigin()

    if self.target.IsSpecialTeleportTarget then
        self.end_pos = self.end_pos + RandomVector(1000)
    end

	if caster:HasModifier("modifier_teleport_hero_touching") == false then
		caster:ShowCustomMessage({type="bottom", msg="#xxwar_msg_teleport_not_in_range", class="error"})
		return false
	end

	self.start_pfx = ParticleManager:CreateParticle(ParticleRes.TP_START, PATTACH_OVERHEAD_FOLLOW, caster)
	ParticleManager:SetParticleControl(self.start_pfx, 0, self.start_pos)

	self.end_pfx = ParticleManager:CreateParticle(ParticleRes.TP_END, PATTACH_OVERHEAD_FOLLOW, self.target)
	ParticleManager:SetParticleControl(self.end_pfx, 0, self.end_pos)

	EmitSoundOn(SoundRes.TP_START_LOOP, caster)
	EmitSoundOn(SoundRes.TP_END_LOOP, self.target)

	return true
end

function ability_xxwar_teleport:GetChannelTime()
    if IsServer() then
        local affixAttr = self:GetCaster():GetCustomAttribute("teleport")
        if affixAttr and affixAttr > 0 then
            return 3 * (1 - affixAttr * 0.01)
        end

        return 3
    else
        local statTable = CustomNetTables:GetTableValue("CustomAttributes",  
            "StatisticalAttributes_" .. tostring(self:GetCaster():GetEntityIndex()))

        if statTable ~= nil and statTable["teleport"] ~= nil then
            return 3 * (1 - statTable["teleport"] * 0.01)
        end

        return 3
    end
end

function ability_xxwar_teleport:OnChannelFinish(bInterrupted)
	if not IsServer() then return end

    local caster = self:GetCaster()
    if IsNull(caster) then return end
    if IsNull(self.target) then return end

	StopSoundOn(SoundRes.TP_START_LOOP, caster)
    StopSoundOn(SoundRes.TP_END_LOOP, self.target)

    if bInterrupted == false then
        FindClearSpaceForUnit(caster, self.end_pos, true)
	    EmitSoundOnLocationWithCaster(self.start_pos, SoundRes.TP_START, caster)
    	EmitSoundOnLocationWithCaster(self.end_pos, SoundRes.TP_END, caster)
    end

    self:StartCooldown(self:GetCooldownTime())

    PlayerResource:SetCameraTarget(caster:GetPlayerID(), caster)
    Timers:CreateTimer(0.1, function()
    	if IsNull(caster) == false then
        	PlayerResource:SetCameraTarget(caster:GetPlayerID(), nil)
        end
    end)

    self.finish_pfx = ParticleManager:CreateParticle(ParticleRes.TP_FINISH, PATTACH_OVERHEAD_FOLLOW, caster)

	if self.start_pfx ~= nil then
		ParticleManager:DestroyParticle(self.start_pfx, true)
		ParticleManager:ReleaseParticleIndex(self.start_pfx)
	end

	if self.end_pfx ~= nil then
		ParticleManager:DestroyParticle(self.end_pfx, true)
		ParticleManager:ReleaseParticleIndex(self.end_pfx)
	end

	Timers:CreateTimer(2.0, function()		
		if self.finish_pfx ~= nil then
			ParticleManager:DestroyParticle(self.finish_pfx, true)
			ParticleManager:ReleaseParticleIndex(self.finish_pfx)
		end
	end)
end
