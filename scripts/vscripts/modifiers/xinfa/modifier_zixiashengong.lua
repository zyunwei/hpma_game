modifier_zixiashengong = class({})

function modifier_zixiashengong:IsHidden() return false end
function modifier_zixiashengong:IsDebuff() return false end
function modifier_zixiashengong:IsPurgable() return false end
function modifier_zixiashengong:RemoveOnDeath() return false end

function modifier_zixiashengong:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_EVASION_CONSTANT
    }
end

function modifier_zixiashengong:GetModifierEvasion_Constant(t)
    return self.evasion
end

function modifier_zixiashengong:GetTexture()
	return "ability_custom_bixiejianpu"
end

function modifier_zixiashengong:OnCreated(params)
    self.evasion = 0
    if params.evasion then
        self.evasion = params.evasion
    end
end
