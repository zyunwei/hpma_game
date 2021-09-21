ability_custom_crazy_pet = ability_custom_crazy_pet or class({})

function ability_custom_crazy_pet:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
    local modifierParams = {
        pet_bonus_attack_speed = self:GetSpecialValueFor("pet_bonus_attack_speed"),
    }

    local affixAttr = self:GetCaster():GetCustomAttribute("crazy_pet")
    if affixAttr and affixAttr > 0 then
        modifierParams.pet_bonus_attack_speed = modifierParams.pet_bonus_attack_speed + affixAttr
    end

    caster:AddNewModifier(caster, nil, "modifier_ability_custom_crazy_pet_buff", modifierParams)
end

function ability_custom_crazy_pet:OnFold()
	local caster = self:GetCaster()
	if IsNull(caster)  then return end

	if caster:HasModifier("modifier_mohuaxinfa") then
		CardGroupSystem:ReplaceCard(caster:GetPlayerID(), "ability_custom_crazy_pet", "ability_custom_metamorphosis_pet", true)
	end
end

LinkLuaModifier("modifier_ability_custom_crazy_pet_buff", "abilities/custom/ability_custom_crazy_pet", LUA_MODIFIER_MOTION_NONE)

modifier_ability_custom_crazy_pet_buff = modifier_ability_custom_crazy_pet_buff or class({})

function modifier_ability_custom_crazy_pet_buff:IsHidden() return false end
function modifier_ability_custom_crazy_pet_buff:IsDebuff() return false end
function modifier_ability_custom_crazy_pet_buff:IsPurgable() return false end
function modifier_ability_custom_crazy_pet_buff:RemoveOnDeath() return true end

function modifier_ability_custom_crazy_pet_buff:GetTexture()
    return "ability_custom_crazy_pet"
end

function modifier_ability_custom_crazy_pet_buff:OnCreated(params)
    self.pet_bonus_attack_speed = params.pet_bonus_attack_speed or 100
	if IsServer() then
        if IsNull(self:GetParent()) then return end
		EmitSoundOnClient("Hero_OgreMagi.Bloodlust.Target", self:GetParent():GetPlayerOwner())
		EmitSoundOnClient("Hero_OgreMagi.Bloodlust.Target.FP", self:GetParent():GetPlayerOwner())
	end
end

function modifier_ability_custom_crazy_pet_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP,
    }
end

function modifier_ability_custom_crazy_pet_buff:OnTooltip()
    return self.pet_bonus_attack_speed
end

function modifier_ability_custom_crazy_pet_buff:GetPetBonusAttackSpeed()
    return self.pet_bonus_attack_speed
end