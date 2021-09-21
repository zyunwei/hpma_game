modifier_moyejianxinfa = class({})

function modifier_moyejianxinfa:IsHidden() return false end
function modifier_moyejianxinfa:IsDebuff() return false end
function modifier_moyejianxinfa:IsPurgable() return false end
function modifier_moyejianxinfa:RemoveOnDeath() return false end

function modifier_moyejianxinfa:GetTexture()
	return "ability_custom_finger_of_death"
end

function modifier_moyejianxinfa:OnCreated(params)
    self.finger_of_death_radius = params.finger_of_death_radius or 500
end

function modifier_moyejianxinfa:GetFingerOfDeathRadius()
    return self.finger_of_death_radius
end