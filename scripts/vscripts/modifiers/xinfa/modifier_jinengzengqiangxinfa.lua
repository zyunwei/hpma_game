modifier_jinengzengqiangxinfa = class({})

function modifier_jinengzengqiangxinfa:IsHidden() return false end
function modifier_jinengzengqiangxinfa:IsDebuff() return false end
function modifier_jinengzengqiangxinfa:IsPurgable() return false end
function modifier_jinengzengqiangxinfa:RemoveOnDeath() return false end

function modifier_jinengzengqiangxinfa:GetTexture()
	return "ability_custom_spell_amplify"
end


