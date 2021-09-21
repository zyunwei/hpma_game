-- 传送
local teleport_points = nil
function Teleport(keys)
	local point = keys.target_points[1]

	if teleport_points == nil then
		teleport_points = {}
		for k in pairs(ItemsKV) do
			if string.find(k,"item_teleport_") == 1 then
				local entity = Entities:FindByName(nil, k)
				if entity then
					table.insert(teleport_points,entity:GetOrigin())
				end
			end
		end
	end

	local len = -1
	local end_point = nil
	for i,v in ipairs(teleport_points) do
		if (v-point):Length2D() <= len or len == -1 then
			len = (v-point):Length2D()
			end_point = v
		end
	end

	if end_point then
		FindClearSpaceForUnit(keys.caster, end_point, true)
		keys.caster:CameraLock(0.1)
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "ability_xxwar_teleport", {duration=0.1})
	end
end

-- 冲刺
local EvadeMotions = {}
function HeroEvade(keys)
	local caster = keys.caster
	local ability = keys.ability
	local motion = EvadeMotions[caster:GetEntityIndex()]

	local crystalCost = ability:GetSpecialValueFor("crystal_cost_special")
    local crystal = caster:GetCustomAttribute("crystal")
    if crystal >= crystalCost then
    	caster:ModifyCustomAttribute("crystal", "crystal", -crystalCost)
    else
    	ability:EndCooldown()
        caster:ShowCustomMessage({type="bottom", msg="#xxwar_msg_not_enough_crystal", class="error"})
        return false
    end

    ability:ApplyDataDrivenModifier(caster, caster, "modifier_ability_xxwar_evade", { duration = 0.5 })

	-- 注册移动器
	if motion == nil then
		motion = caster:CreateMotion()
		motion:SetStopIfBlocked(true)

		motion:OnEnd(function()
			
		end)

		EvadeMotions[caster:GetEntityIndex()] = motion
	end

	if motion:IsRunning() then
		return
	end

	-- 启动移动器
	local origin = caster:GetOrigin()
	local face = caster:GetForwardVector()
	face.z = 0
	-- caster:Stop()
	caster:StartGesture(ACT_GLIDE)

	motion.__shushan_evade_end_time = GameRules:GetGameTime() + 0.4

	-- 残影特效
	local p = ParticleManager:CreateParticle("particles/avalon/evade_effect.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(p, 0, caster, 5, "follow_origin", caster:GetOrigin(), true)
	ParticleManager:SetParticleControlForward(p, 0, face)
	ParticleManager:DestroyParticleSystem(p)

	motion:Linear(origin, origin+face*350, 0, 0.4, "modifier_xxwar_evade")
end
