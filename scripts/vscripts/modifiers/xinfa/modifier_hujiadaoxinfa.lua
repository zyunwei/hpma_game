modifier_hujiadaoxinfa = class({})

function modifier_hujiadaoxinfa:IsHidden() return false end
function modifier_hujiadaoxinfa:IsDebuff() return false end
function modifier_hujiadaoxinfa:IsPurgable() return false end
function modifier_hujiadaoxinfa:RemoveOnDeath() return false end

function modifier_hujiadaoxinfa:GetTexture()
	return "ability_custom_hujiadaofa"
end


