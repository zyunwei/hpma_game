modifier_xianjixinfa = class({})

function modifier_xianjixinfa:IsHidden() return false end
function modifier_xianjixinfa:IsDebuff() return false end
function modifier_xianjixinfa:IsPurgable() return false end
function modifier_xianjixinfa:RemoveOnDeath() return false end

function modifier_xianjixinfa:GetTexture()
	return "ability_custom_burn_around"
end

function modifier_xianjixinfa:OnCreated(params)
    if not IsServer() then return end
    self.bonus_radius = params.bonus_radius or 300
end

function modifier_xianjixinfa:GetBonusRadius()
    return self.bonus_radius
end