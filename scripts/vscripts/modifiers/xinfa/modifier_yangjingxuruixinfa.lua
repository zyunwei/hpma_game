modifier_yangjingxuruixinfa = class({})

function modifier_yangjingxuruixinfa:IsHidden() return false end
function modifier_yangjingxuruixinfa:IsDebuff() return false end
function modifier_yangjingxuruixinfa:IsPurgable() return false end
function modifier_yangjingxuruixinfa:RemoveOnDeath() return false end

function modifier_yangjingxuruixinfa:GetTexture()
	return "ability_custom_recuperate"
end


