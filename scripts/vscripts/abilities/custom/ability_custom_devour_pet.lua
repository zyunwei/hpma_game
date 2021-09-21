ability_custom_devour_pet = ability_custom_devour_pet or class({})

LinkLuaModifier("modifier_ability_custom_devour_pet_buff", "abilities/custom/ability_custom_devour_pet", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_pet_enhancement", "abilities/custom/ability_custom_devour_pet", LUA_MODIFIER_MOTION_NONE)

function ability_custom_devour_pet:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
    local modifierParams = {
        pet_bonus_health = self:GetSpecialValueFor("pet_bonus_health"),
        pet_bonus_attack_damage = self:GetSpecialValueFor("pet_bonus_attack_damage"),
    }

    local particle_index = ParticleManager:CreateParticle("particles/units/heroes/hero_doom_bringer/doom_bringer_devour.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle_index, 0, caster:GetOrigin() + caster:GetForwardVector():Normalized() * 100)
    ParticleManager:SetParticleControl(particle_index, 1, caster:GetOrigin())

    EmitSoundOn("Hero_DoomBringer.DevourCast", caster)

    local modifier = caster:FindModifierByName("modifier_ability_custom_devour_pet_buff")
    if NotNull(modifier) then
        modifier:IncrementStackCount()
    else
        modifier = caster:AddNewModifier(caster, nil, "modifier_ability_custom_devour_pet_buff", modifierParams)
    end

    local tonglingxinfa = caster:FindModifierByName("modifier_tonglingxinfa")
    if NotNull(tonglingxinfa) and NotNull(modifier) then
        for i = 1, tonglingxinfa:GetBonusDevourCount() do
            modifier:IncrementStackCount()
        end
    end
end

modifier_ability_custom_devour_pet_buff = modifier_ability_custom_devour_pet_buff or class({})

function modifier_ability_custom_devour_pet_buff:IsHidden() return false end
function modifier_ability_custom_devour_pet_buff:IsDebuff() return false end
function modifier_ability_custom_devour_pet_buff:IsPurgable() return false end
function modifier_ability_custom_devour_pet_buff:RemoveOnDeath() return false end

function modifier_ability_custom_devour_pet_buff:GetTexture()
    return "ability_custom_devour_pet"
end

function modifier_ability_custom_devour_pet_buff:GetEffectName()
    return "particles/econ/events/ti10/aghanim_aura_ti10/agh_aura_ti10.vpcf"
end

function modifier_ability_custom_devour_pet_buff:GetEffectAttachType()
    return PATTACH_CENTER_FOLLOW
end

function modifier_ability_custom_devour_pet_buff:OnCreated(params)
    self.pet_bonus_health = params.pet_bonus_health or 300
    self.pet_bonus_attack_damage = params.pet_bonus_attack_damage or 25
    if not IsServer() then return end
    self:SetStackCount(1)
end

function modifier_ability_custom_devour_pet_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP,
    }
end

function modifier_ability_custom_devour_pet_buff:OnStackCountChanged(oldValue)
    if not IsServer() then return end
    if IsNull(self:GetParent()) then return end
    local playerId = self:GetParent():GetPlayerID()
    local pets = CallHeroPool:GetPlayerHeroPets(playerId)
    if pets == nil then return end
    for _, entIndex in ipairs(pets) do
        local pet = EntIndexToHScript(entIndex)
        local modifierParams = {
            pet_bonus_health = self.pet_bonus_health * self:GetStackCount(),
            pet_bonus_attack_damage = self.pet_bonus_attack_damage * self:GetStackCount(),
        }
        if NotNull(pet) and pet:IsBaseNPC() then
            local modifier = pet:FindModifierByName("modifier_pet_enhancement")
            if NotNull(modifier) then
                modifier:Destroy()
            end
            pet:AddNewModifier(self:GetParent(), nil, "modifier_pet_enhancement", modifierParams)
        end
    end
end

function modifier_ability_custom_devour_pet_buff:OnTooltip()
    return self.pet_bonus_health
end

function modifier_ability_custom_devour_pet_buff:GetPetBonusHealth()
    return self.pet_bonus_health * self:GetStackCount()
end

function modifier_ability_custom_devour_pet_buff:GetPetBonusAttackDamage()
    return self.pet_bonus_attack_damage * self:GetStackCount()
end

modifier_pet_enhancement = modifier_pet_enhancement or class({})

function modifier_pet_enhancement:IsHidden() return false end
function modifier_pet_enhancement:IsDebuff() return false end
function modifier_pet_enhancement:IsPurgable() return false end
function modifier_pet_enhancement:RemoveOnDeath() return true end

function modifier_pet_enhancement:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_HEALTH_BONUS,
    }
end

function modifier_pet_enhancement:GetTexture()
    return "ability_custom_devour_pet"
end

function modifier_pet_enhancement:GetModifierHealthBonus()
    return self.pet_bonus_health
end

function modifier_pet_enhancement:GetModifierPreAttack_BonusDamage()
    return self.pet_bonus_attack_damage
end

function modifier_pet_enhancement:OnCreated(params)
    if not IsServer() then return end
    self.pet_bonus_health = params.pet_bonus_health or 300
    self.pet_bonus_attack_damage = params.pet_bonus_attack_damage or 25
end
