modifier_moridaoxinfa = class({})

function modifier_moridaoxinfa:IsHidden() return false end
function modifier_moridaoxinfa:IsDebuff() return false end
function modifier_moridaoxinfa:IsPurgable() return false end
function modifier_moridaoxinfa:RemoveOnDeath() return false end

function modifier_moridaoxinfa:GetTexture()
	return "ability_custom_doom"
end


