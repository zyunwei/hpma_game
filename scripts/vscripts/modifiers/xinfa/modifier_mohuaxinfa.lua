modifier_mohuaxinfa = class({})

function modifier_mohuaxinfa:IsHidden() return false end
function modifier_mohuaxinfa:IsDebuff() return false end
function modifier_mohuaxinfa:IsPurgable() return false end
function modifier_mohuaxinfa:RemoveOnDeath() return false end

function modifier_mohuaxinfa:GetTexture()
	return "ability_custom_crazy_pet"
end


