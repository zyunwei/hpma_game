modifier_yiquanchaorenxinfa = class({})

function modifier_yiquanchaorenxinfa:IsHidden() return false end
function modifier_yiquanchaorenxinfa:IsDebuff() return false end
function modifier_yiquanchaorenxinfa:IsPurgable() return false end
function modifier_yiquanchaorenxinfa:RemoveOnDeath() return false end

function modifier_yiquanchaorenxinfa:GetTexture()
	return "ability_custom_one_punch"
end


