modifier_hudunxinfa = class({})

function modifier_hudunxinfa:IsHidden() return false end
function modifier_hudunxinfa:IsDebuff() return false end
function modifier_hudunxinfa:IsPurgable() return false end
function modifier_hudunxinfa:RemoveOnDeath() return false end

function modifier_hudunxinfa:GetTexture()
	return "ability_custom_pet_armor_up"
end


