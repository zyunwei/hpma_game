modifier_wuyingjiaoxinfa = class({})

function modifier_wuyingjiaoxinfa:IsHidden() return false end
function modifier_wuyingjiaoxinfa:IsDebuff() return false end
function modifier_wuyingjiaoxinfa:IsPurgable() return false end
function modifier_wuyingjiaoxinfa:RemoveOnDeath() return false end

function modifier_wuyingjiaoxinfa:GetTexture()
	return "ability_custom_yuanshengzhili"
end


