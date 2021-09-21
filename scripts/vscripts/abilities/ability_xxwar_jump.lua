ability_xxwar_jump = ability_xxwar_jump or class({})

local public = ability_xxwar_jump
local JumpMotions = {}

function public:OnSpellStart()
	local caster = self:GetCaster()
	if IsNull(caster) then
		return false
	end

	-- local hero = CreateUnitByName("npc_dota_hero_sven", caster:GetAbsOrigin(), true, caster, caster, DOTA_TEAM_BADGUYS)
	-- hero:AddNewModifier(hero, nil, "modifier_black_king_bar_immune", {})
	-- local ab = hero:AddAbility("ability_custom_zhiheng")
	-- ab:SetLevel(1)
	-- ab:CastAbility()

	local motion = JumpMotions[caster:GetEntityIndex()]

	-- 注册移动器
	if motion == nil then
		local firstAnimation = false
		local secondAnimation = false
		motion = caster:CreateMotion()
		motion:SetDelayToDeleteStun(0.1)

		motion:OnStart(function ()
			firstAnimation = true
			secondAnimation = true
			caster:ForcePlayActivityOnce(ACT_JUMP_AUTOGUN)
		end)

		motion:OnUpdate(function(time)
			if time >= 0.1 and firstAnimation then
				firstAnimation = false
				caster:ForcePlayActivityOnce(ACT_JUMP)
			elseif time >= 0.4 and secondAnimation then
				secondAnimation = false
				caster:ForcePlayActivityOnce(ACT_JUMP_DUAL)
			end
		end)

		JumpMotions[caster:GetEntityIndex()] = motion
	end

	if motion:IsRunning() then
		return
	end

	-- 启动移动器
	local origin = caster:GetOrigin()

	-- 最大跳跃距离
	local jump_length = 500

	if caster.GetCustomAttribute ~= nil and caster:GetCustomAttribute("jump_length") ~= nil then
		jump_length = jump_length + caster:GetCustomAttribute("jump_length")
	end

	-- 往前跳
	local end_pos = caster:GetOrigin() + caster:GetForwardVector() * jump_length

	local cursorPosition = self:GetCursorPosition()
    if cursorPosition ~= nil then
    	end_pos = cursorPosition
    end

	if end_pos.z - origin.z >= 500 then return end

	local face = (end_pos - origin):Normalized()
	local len = (origin - end_pos):Length2D()
	face.z = 0

	if GridNav:IsBlocked(end_pos) then
		return Avalon:Throw(caster,"avalon_can_not_jump_to_here")
	end

	if len < 200 then
		len = 200
		end_pos = origin + face*len
	elseif len > jump_length then
		len = jump_length
		end_pos = origin + face*len
	end

	motion:OnEnd(function()
		local h = origin.z - GetGroundPosition(end_pos, caster).z - 750
		if h > 0 then
			local p = h / 100
			if p >= 1 then
				caster:ForceKill(true)
				return
			else
				local health = caster:GetMaxHealth()*p
				if caster:GetHealth() <= health then
					caster:ForceKill(true)
					return
				else
					caster:SetHealth(caster:GetHealth() - health)
					if caster:GetHealth() <= 0 then
						caster:ForceKill(true)
					end
					return
				end
			end
		end

		local newOrigin = caster:GetOrigin()
		if (motion:GetEndPosition() - newOrigin):Length2D() >= 100 then
			caster:SetOrigin(origin)
		end

		-- if IsInToolsMode() == true then
		-- 	self:EndCooldown()
		-- end
	end)

	local height_speed = 2000 * len / 500
	
	caster:SetAngles(0, VectorToAngles(face).y, 0)
	-- caster:EmitSound("ShuShanAbility.JumpStart")
	motion:Jump(origin, end_pos, height_speed, 0.6, "modifier_custom_stun")

	--每周任务
	local playerId = caster:GetPlayerID()
	local playerInfo = GameRules.XW:GetPlayerInfo(playerId)
	if playerInfo then
		playerInfo.TaskTable.jump_count = playerInfo.TaskTable.jump_count + 1
	end
end
