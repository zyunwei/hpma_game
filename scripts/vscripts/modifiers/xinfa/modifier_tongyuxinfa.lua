modifier_tongyuxinfa = class({})

function modifier_tongyuxinfa:IsHidden() return false end
function modifier_tongyuxinfa:IsDebuff() return false end
function modifier_tongyuxinfa:IsPurgable() return false end
function modifier_tongyuxinfa:RemoveOnDeath() return false end

function modifier_tongyuxinfa:GetTexture()
	return "ability_custom_jiasulunhui"
end


