modifier_zhihengxinfa = class({})

function modifier_zhihengxinfa:IsHidden() return false end
function modifier_zhihengxinfa:IsDebuff() return false end
function modifier_zhihengxinfa:IsPurgable() return false end
function modifier_zhihengxinfa:RemoveOnDeath() return false end

function modifier_zhihengxinfa:GetTexture()
	return "ability_custom_renwang"
end


