ability_custom_pet_armor_up = ability_custom_pet_armor_up or class({})

LinkLuaModifier("modifier_ability_custom_pet_armor_up_buff", "abilities/custom/ability_custom_pet_armor_up", LUA_MODIFIER_MOTION_NONE)

function ability_custom_pet_armor_up:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
    local modifierParams = {
        pet_bonus_armor = self:GetSpecialValueFor("pet_bonus_armor"),
    }

    local modifier = caster:FindModifierByName("modifier_ability_custom_pet_armor_up_buff")
    if NotNull(modifier) then
        modifier:SetPetBonusArmor(modifierParams.pet_bonus_armor)
        modifier:IncrementStackCount()
    else
        caster:AddNewModifier(caster, nil, "modifier_ability_custom_pet_armor_up_buff", modifierParams)
    end
end

function ability_custom_pet_armor_up:OnFold()
	local caster = self:GetCaster()
	if IsNull(caster)  then return end

	if caster:HasModifier("modifier_hudunxinfa") then
		CardGroupSystem:ReplaceCard(caster:GetPlayerID(), "ability_custom_pet_armor_up", "ability_custom_pet_bulwark", true)
	end
end

modifier_ability_custom_pet_armor_up_buff = modifier_ability_custom_pet_armor_up_buff or class({})

function modifier_ability_custom_pet_armor_up_buff:IsHidden() return false end
function modifier_ability_custom_pet_armor_up_buff:IsDebuff() return false end
function modifier_ability_custom_pet_armor_up_buff:IsPurgable() return false end
function modifier_ability_custom_pet_armor_up_buff:RemoveOnDeath() return false end

function modifier_ability_custom_pet_armor_up_buff:GetTexture()
    return "ability_custom_pet_armor_up"
end

function modifier_ability_custom_pet_armor_up_buff:GetEffectName()
    return "particles/econ/events/ti10/aghanim_aura_ti10/agh_aura_ti10.vpcf"
end

function modifier_ability_custom_pet_armor_up_buff:GetEffectAttachType()
    return PATTACH_CENTER_FOLLOW
end

function modifier_ability_custom_pet_armor_up_buff:OnCreated(params)
    self.pet_bonus_armor = params.pet_bonus_armor or 1.0
    if not IsServer() then return end
    local caster = self:GetCaster()
    if IsNull(caster) then return end
    self:SetStackCount(1)
    self:OnStackCountChanged()
end

function modifier_ability_custom_pet_armor_up_buff:SetPetBonusArmor(value)
    self.pet_bonus_armor = value
end

function modifier_ability_custom_pet_armor_up_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP,
    }
end

function modifier_ability_custom_pet_armor_up_buff:OnStackCountChanged()
    if not IsServer() then return end
    if IsNull(self:GetParent()) then return end
    local playerId = self:GetParent():GetPlayerID()
    local pets = CallHeroPool:GetPlayerHeroPets(playerId)
    if pets == nil then return end
    for _, entIndex in ipairs(pets) do
        local pet = EntIndexToHScript(entIndex)
        if NotNull(pet) and pet:IsBaseNPC() then
            pet:AddNewModifier(self:GetParent(), nil, "modifier_pet_armor_up", {})
        end
    end
end

function modifier_ability_custom_pet_armor_up_buff:OnTooltip()
    return self.pet_bonus_armor
end

function modifier_ability_custom_pet_armor_up_buff:GetPetBonusArmor()
    return self.pet_bonus_armor
end