modifier_anyingzhiwuxinfa = class({})

function modifier_anyingzhiwuxinfa:IsHidden() return false end
function modifier_anyingzhiwuxinfa:IsDebuff() return false end
function modifier_anyingzhiwuxinfa:IsPurgable() return false end
function modifier_anyingzhiwuxinfa:RemoveOnDeath() return false end

function modifier_anyingzhiwuxinfa:GetTexture()
	return "ability_custom_shadow_dance"
end


