require 'client'
custom_item_consumable_time_scroll = CustomItemSpellSystem:GetBaseClass()

local public = custom_item_consumable_time_scroll

function public:OnCustomSpellStart(item)
    local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if IsNull(caster) or IsNull(target) then
		return
	end

	if(target.IsRealHero == nil or target:IsRealHero() == false) then
		return
	end

	local blink_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_start.vpcf", PATTACH_ABSORIGIN, target)
	ParticleManager:ReleaseParticleIndex(blink_pfx)
	target:EmitSound("Hero_Antimage.Blink_out")

	Timers:CreateTimer(0.01, function()
		if IsNull(caster) or IsNull(target) then
			return
		end

		local target_point = nil
		local targetRegions = {1,2,3,4,6,7,8,9}
		local regionId = table.random(targetRegions)
        local region = BlockadeSystem:GetRegionById(regionId)
        if region then
            target_point = region:RandomPointInRegion()
        end
		if target_point ~= nil then 
			AddFOWViewer(caster:GetTeamNumber(), target_point, 1000, 5, false)

			FindClearSpaceForUnit(target, target_point, true)

			PlayerResource:SetCameraTarget(target:GetPlayerID(), target)
		    Timers:CreateTimer(0.1, function()
		    	if IsNull(target) == false then
		        	PlayerResource:SetCameraTarget(target:GetPlayerID(), nil)
		        end
		    end)

			local blink_end_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_end.vpcf", PATTACH_ABSORIGIN, target)
			ParticleManager:ReleaseParticleIndex(blink_end_pfx)
			target:EmitSound("Hero_Antimage.Blink_in")
		end
	end)
end
