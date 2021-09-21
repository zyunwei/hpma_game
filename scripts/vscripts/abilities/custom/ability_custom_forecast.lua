ability_custom_forecast = ability_custom_forecast or class({})

function ability_custom_forecast:OnSpellStart()
    if GameRules.XW.DynamicVision == false then return end
    if IsServer() then
        local caster = self:GetCaster()
        if IsNull(caster) then return end
        local modifierParams = {
            bonus_vision = self:GetSpecialValueFor("bonus_vision"),
            duration = self:GetSpecialValueFor("duration"),
            bonus_magic_find = self:GetSpecialValueFor("bonus_magic_find"),
        }

        caster:AddNewModifier(caster, nil, "modifier_forecast", modifierParams)
        for _, playerInfo in pairs(GameRules.XW.PlayerList) do
            local hero = playerInfo.Hero
            if NotNull(hero) and hero ~= caster and hero:GetTeamNumber() ~= caster:GetTeamNumber() then
                AddFOWViewer(caster:GetTeamNumber(), hero:GetAbsOrigin(), 300, self:GetSpecialValueFor("duration"), false)
                -- hero:ShowCustomMessage({type="bottom", msg="#xxwar_msg_be_discovered", class="error"})
            end
        end
    end
end

LinkLuaModifier("modifier_forecast", "abilities/custom/ability_custom_forecast", LUA_MODIFIER_MOTION_NONE)

modifier_forecast = class({})

function modifier_forecast:IsHidden() return false end
function modifier_forecast:IsDebuff() return false end
function modifier_forecast:IsPurgable() return false end
function modifier_forecast:RemoveOnDeath() return true end

function modifier_forecast:GetTexture()
    return "ability_custom_forecast"
end

function modifier_forecast:OnCreated(params)
    self.bonus_vision = 1200
    self.bonus_magic_find = params.bonus_magic_find or 10
    if IsServer() then
        if params then
            self.bonus_vision = params.bonus_vision or self.bonus_vision
        end
        self:StartIntervalThink(FrameTime() * 3)
    end
end

function modifier_forecast:OnIntervalThink()
    if IsNull(self:GetParent()) then return end
	AddFOWViewer(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), self.bonus_vision, FrameTime() * 3, false)
end

function modifier_forecast:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP,
    }
end

function modifier_forecast:OnTooltip()
    return self.bonus_vision
end

function modifier_forecast:GetBonusMagicFind()
    return self.bonus_magic_find
end