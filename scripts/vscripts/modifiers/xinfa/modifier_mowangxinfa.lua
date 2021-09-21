modifier_mowangxinfa = class({})

function modifier_mowangxinfa:IsHidden() return false end
function modifier_mowangxinfa:IsDebuff() return false end
function modifier_mowangxinfa:IsPurgable() return false end
function modifier_mowangxinfa:RemoveOnDeath() return false end

function modifier_mowangxinfa:GetTexture()
	return "ability_custom_hujiafushi"
end


