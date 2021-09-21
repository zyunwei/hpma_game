modifier_mofatouquxinfa = class({})

function modifier_mofatouquxinfa:IsHidden() return false end
function modifier_mofatouquxinfa:IsDebuff() return false end
function modifier_mofatouquxinfa:IsPurgable() return false end
function modifier_mofatouquxinfa:RemoveOnDeath() return false end

function modifier_mofatouquxinfa:GetTexture()
	return "ability_custom_mana_drain"
end


