modifier_nuyikuangjixinfa = class({})

function modifier_nuyikuangjixinfa:IsHidden() return false end
function modifier_nuyikuangjixinfa:IsDebuff() return false end
function modifier_nuyikuangjixinfa:IsPurgable() return false end
function modifier_nuyikuangjixinfa:RemoveOnDeath() return false end

function modifier_nuyikuangjixinfa:GetTexture()
	return "ability_custom_fury_swipes"
end
