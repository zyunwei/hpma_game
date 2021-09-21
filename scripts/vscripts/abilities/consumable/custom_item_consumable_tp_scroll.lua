require 'client'
custom_item_consumable_tp_scroll = CustomItemSpellSystem:GetBaseClass()

local public = custom_item_consumable_tp_scroll

function public:OnCustomSpellStart(item)
    local caster = self:GetCaster()
	if IsNull(caster) then
		return
	end

	local blink_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_start.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:ReleaseParticleIndex(blink_pfx)
	caster:EmitSound("Hero_Antimage.Blink_in")
	Timers:CreateTimer(0.01, function()
		if IsNull(caster) then
			return
		end

		if NotNull(GameRules.XW.OutpostCenter) then
			local target_point = GameRules.XW.OutpostCenter:GetAbsOrigin() + RandomVector(300)
			FindClearSpaceForUnit(caster, target_point, true)
			PlayerResource:SetCameraTarget(caster:GetPlayerID(), caster)
		    Timers:CreateTimer(0.1, function()
		    	if IsNull(caster) == false then
		        	PlayerResource:SetCameraTarget(caster:GetPlayerID(), nil)
		        end
		    end)

			local blink_end_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_end.vpcf", PATTACH_ABSORIGIN, caster)
			ParticleManager:ReleaseParticleIndex(blink_end_pfx)
			caster:EmitSound("Hero_Antimage.Blink_in")
		end
	end)
end
