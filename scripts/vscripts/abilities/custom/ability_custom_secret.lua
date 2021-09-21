ability_custom_secret = ability_custom_secret or class({})

function ability_custom_secret:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        if IsNull(caster) then return end
        local modifierParams = {
            no_injury_duartion = self:GetSpecialValueFor("no_injury_duartion"),
            debuff_duartion = self:GetSpecialValueFor("debuff_duartion")
        }
        caster:AddNewModifier(caster, nil, "modifier_secret", modifierParams)
    end
end

LinkLuaModifier("modifier_secret", "abilities/custom/ability_custom_secret", LUA_MODIFIER_MOTION_NONE)

modifier_secret = class({})

function modifier_secret:IsHidden() return false end
function modifier_secret:IsDebuff() return false end
function modifier_secret:IsPurgable() return false end
function modifier_secret:RemoveOnDeath() return true end

function modifier_secret:GetTexture()
    return "ability_custom_secret"
end

function modifier_secret:OnCreated(params)
    self.no_injury_duartion = params.no_injury_duartion or 1
    self.debuff_duartion = params.debuff_duartion or 60
end

function modifier_secret:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_TOOLTIP,
    }
end

function modifier_secret:OnTooltip()
    return self.no_injury_duartion
end


function modifier_secret:GetModifierIncomingDamage_Percentage(ModifierAttackEvent)
    local parent = self:GetParent()
    if IsNull(parent) then return end
    if parent:GetHealth() <= ModifierAttackEvent.damage and parent:HasModifier("modifier_secret_debuff") == false then
        parent:EmitSound("DOTA_Item.ComboBreaker")
        parent:AddNewModifier(parent, nil, "modifier_secret_debuff", {duration = self.debuff_duartion})
        parent:AddNewModifier(parent, nil, "modifier_secret_prevent_damage", {duration = self.no_injury_duartion})
        return -100
    end
end

LinkLuaModifier("modifier_secret_prevent_damage", "abilities/custom/ability_custom_secret", LUA_MODIFIER_MOTION_NONE)

modifier_secret_prevent_damage = class({})

function modifier_secret_prevent_damage:IsHidden() return false end
function modifier_secret_prevent_damage:IsDebuff() return false end
function modifier_secret_prevent_damage:IsPurgable() return false end
function modifier_secret_prevent_damage:RemoveOnDeath() return true end

function modifier_secret_prevent_damage:GetTexture()
    return "ability_custom_secret"
end

function modifier_secret_prevent_damage:OnCreated(params)
	if IsServer() then
        if IsNull(self:GetParent()) then return end
        local modifierSecret = self:GetParent():FindModifierByName("modifier_secret")
        if modifierSecret then
            modifierSecret:Destroy()
        end
		self.particle = ParticleManager:CreateParticle("particles/items4_fx/combo_breaker_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(self.particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(self.particle, false, false, -1, true, false)
	 end

end

function modifier_secret_prevent_damage:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }
end

function modifier_secret_prevent_damage:GetModifierIncomingDamage_Percentage(ModifierAttackEvent)
    return -100
end

function modifier_secret_prevent_damage:OnDestroy()
    if self.particle ~= nil then
        ParticleManager:DestroyParticle(self.particle, true)
    end
end

LinkLuaModifier("modifier_secret_debuff", "abilities/custom/ability_custom_secret", LUA_MODIFIER_MOTION_NONE)

modifier_secret_debuff = class({})

function modifier_secret_debuff:IsHidden() return false end
function modifier_secret_debuff:IsDebuff() return true end
function modifier_secret_debuff:IsPurgable() return false end
function modifier_secret_debuff:RemoveOnDeath() return true end

function modifier_secret_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP,
    }
end

function modifier_secret_debuff:GetTexture()
    return "ability_custom_secret"
end

function modifier_secret_debuff:OnTooltip()
    return self:GetDuration()
end