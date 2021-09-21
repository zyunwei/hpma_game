modifier_status_resistance = class({})
local public = modifier_status_resistance

function public:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
    }
    return funcs
end

function public:GetModifierStatusResistanceStacking(t)
    return self.status_res
end

function public:IsHidden() 
    return true
end

function public:OnCreated(params)
    self.status_res = 0
    if params.status_res then
        self.status_res = params.status_res
    else
        local ability = self:GetAbility()
        if NotNull(ability) then
            local status_resistance = ability:GetSpecialValueFor("bonus_status_resistance")
            if status_resistance then
                self.status_res = status_resistance
            end
        end
    end
end