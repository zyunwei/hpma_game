modifier_tonglingxinfa = class({})

function modifier_tonglingxinfa:IsHidden() return false end
function modifier_tonglingxinfa:IsDebuff() return false end
function modifier_tonglingxinfa:IsPurgable() return false end
function modifier_tonglingxinfa:RemoveOnDeath() return false end

function modifier_tonglingxinfa:GetTexture()
	return "ability_custom_devour_pet"
end

function modifier_tonglingxinfa:OnCreated(params)
    if not IsServer() then return end
    self.bonus_devour_count = params.bonus_devour_count or 1
end

function modifier_tonglingxinfa:GetBonusDevourCount()
    return self.bonus_devour_count
end

