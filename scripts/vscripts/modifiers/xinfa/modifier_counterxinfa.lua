modifier_counterxinfa = class({})

function modifier_counterxinfa:IsHidden() return false end
function modifier_counterxinfa:IsDebuff() return false end
function modifier_counterxinfa:IsPurgable() return false end
function modifier_counterxinfa:RemoveOnDeath() return false end

function modifier_counterxinfa:GetTexture()
	return "ability_custom_counter"
end


