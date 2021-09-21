modifier_bingxinjue	= class({})

function modifier_bingxinjue:IsHidden() return false end
function modifier_bingxinjue:IsDebuff() return false end
function modifier_bingxinjue:IsPurgable() return false end
function modifier_bingxinjue:RemoveOnDeath() return false end

function modifier_bingxinjue:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
    }
end

function modifier_bingxinjue:GetModifierStatusResistanceStacking(t)
    return self.status_res
end

function modifier_bingxinjue:GetTexture()
	return "ability_custom_frost_armor"
end

function modifier_bingxinjue:OnCreated(params)
    self.status_res = 0
    if params.status_res then
        self.status_res = params.status_res
    end
end
