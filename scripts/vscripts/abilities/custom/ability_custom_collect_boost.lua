ability_custom_collect_boost = ability_custom_collect_boost or class({})

LinkLuaModifier("modifier_ability_custom_collect_boost_buff", "abilities/custom/ability_custom_collect_boost", LUA_MODIFIER_MOTION_NONE)

function ability_custom_collect_boost:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
    local modifierParams = {
        bonus_exp = self:GetSpecialValueFor("bonus_exp"),
        bonus_gold = self:GetSpecialValueFor("bonus_gold"),
    }
    local ability = caster:FindAbilityByName("ability_xxwar_collection")
    if NotNull(ability) then
        ability:SetCurrentAbilityCharges(ability:GetMaxAbilityCharges(1))
    end
    local modifier = caster:FindModifierByName("modifier_ability_custom_collect_boost_buff")
    if NotNull(modifier) then
        modifier:IncrementStackCount()
    else
        caster:AddNewModifier(caster, nil, "modifier_ability_custom_collect_boost_buff", modifierParams)
    end
end

modifier_ability_custom_collect_boost_buff = class({})

function modifier_ability_custom_collect_boost_buff:IsHidden() return false end
function modifier_ability_custom_collect_boost_buff:IsDebuff() return false end
function modifier_ability_custom_collect_boost_buff:IsPurgable() return false end
function modifier_ability_custom_collect_boost_buff:RemoveOnDeath() return false end

function modifier_ability_custom_collect_boost_buff:GetTexture()
    return "ability_custom_collect_boost"
end

function modifier_ability_custom_collect_boost_buff:OnCreated(params)
    if not IsServer() then return end
    self.bonus_exp = params.bonus_exp or 50
    self.bonus_gold = params.bonus_gold or 50
    self:SetStackCount(1)
end

function modifier_ability_custom_collect_boost_buff:GetBonusExp()
    return self.bonus_exp * self:GetStackCount()
end

function modifier_ability_custom_collect_boost_buff:GetBonusGold()
    return self.bonus_gold * self:GetStackCount()
end