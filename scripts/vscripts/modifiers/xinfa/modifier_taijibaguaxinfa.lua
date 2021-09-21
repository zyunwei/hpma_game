modifier_taijibaguaxinfa = class({})

function modifier_taijibaguaxinfa:IsHidden() return false end
function modifier_taijibaguaxinfa:IsDebuff() return false end
function modifier_taijibaguaxinfa:IsPurgable() return false end
function modifier_taijibaguaxinfa:RemoveOnDeath() return false end

function modifier_taijibaguaxinfa:GetTexture()
	return "ability_custom_taijibagua"
end
