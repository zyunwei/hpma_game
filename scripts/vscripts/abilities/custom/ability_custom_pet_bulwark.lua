ability_custom_pet_bulwark = ability_custom_pet_bulwark or class({})

LinkLuaModifier("modifier_ability_custom_pet_bulwark_buff", "abilities/custom/ability_custom_pet_bulwark", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_pet_bulwark", "abilities/custom/ability_custom_pet_bulwark", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_ability_custom_pet_armor_up_buff", "abilities/custom/ability_custom_pet_armor_up", LUA_MODIFIER_MOTION_NONE)

function ability_custom_pet_bulwark:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
    local modifierParams = {
        duration = self:GetSpecialValueFor("duration"),
        pet_damage_reduction = self:GetSpecialValueFor("pet_damage_reduction"),
    }
    caster:AddNewModifier(caster, nil, "modifier_ability_custom_pet_bulwark_buff", modifierParams)

    local modifier = caster:FindModifierByName("modifier_ability_custom_pet_armor_up_buff")
    if NotNull(modifier) then
        modifier:IncrementStackCount()
    else
        caster:AddNewModifier(caster, nil, "modifier_ability_custom_pet_armor_up_buff", {pet_bonus_armor = self:GetSpecialValueFor("pet_bonus_armor")})
    end
end

modifier_ability_custom_pet_bulwark_buff = modifier_ability_custom_pet_bulwark_buff or class({})

function modifier_ability_custom_pet_bulwark_buff:IsHidden() return false end
function modifier_ability_custom_pet_bulwark_buff:IsDebuff() return false end
function modifier_ability_custom_pet_bulwark_buff:IsPurgable() return false end
function modifier_ability_custom_pet_bulwark_buff:RemoveOnDeath() return true end

function modifier_ability_custom_pet_bulwark_buff:GetTexture()
    return "ability_custom_pet_bulwark"
end

function modifier_ability_custom_pet_bulwark_buff:GetEffectName()
    return "particles/econ/events/ti10/aghanim_aura_ti10/agh_aura_ti10.vpcf"
end

function modifier_ability_custom_pet_bulwark_buff:GetEffectAttachType()
    return PATTACH_CENTER_FOLLOW
end

function modifier_ability_custom_pet_bulwark_buff:OnCreated(params)
    if not IsServer() then return end
    local caster = self:GetCaster()
    if IsNull(caster) then return end
    self.pet_damage_reduction = params.pet_damage_reduction or 50
    self:StartIntervalThink(FrameTime())
end

function modifier_ability_custom_pet_bulwark_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP,
    }
end

function modifier_ability_custom_pet_bulwark_buff:OnIntervalThink()
    if IsNull(self:GetParent()) then return end
    local playerId = self:GetParent():GetPlayerID()
    local pets = CallHeroPool:GetPlayerHeroPets(playerId)
    if pets == nil then return end
    for _, entIndex in ipairs(pets) do
        local pet = EntIndexToHScript(entIndex)
        local modifierParams = {
            duration = FrameTime(),
            pet_damage_reduction = self.pet_damage_reduction,
        }
        if NotNull(pet) and pet:IsBaseNPC() then
            pet:AddNewModifier(self:GetParent(), nil, "modifier_pet_bulwark",modifierParams)
        end
    end
end

function modifier_ability_custom_pet_bulwark_buff:OnTooltip()
    return self.pet_bonus_armor
end

modifier_pet_bulwark = modifier_pet_bulwark or class({})

function modifier_pet_bulwark:IsHidden() return false end
function modifier_pet_bulwark:IsDebuff() return false end
function modifier_pet_bulwark:IsPurgable() return false end
function modifier_pet_bulwark:RemoveOnDeath() return true end


function modifier_pet_bulwark:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK
    }
end

function modifier_pet_bulwark:GetTexture()
    return "ability_custom_pet_bulwark"
end

function modifier_pet_bulwark:OnCreated(params)
    self.pet_damage_reduction = params.pet_damage_reduction or 50
    self.angle_front = 70
end

function modifier_pet_bulwark:GetModifierPhysical_ConstantBlock( params )

    if IsNull(params.target) or IsNull(params.attacker) then return 0 end
	-- cancel if from ability
	if params.inflictor then return 0 end

    if params.target ~= self:GetParent() then return 0 end

	local parent = params.target
	local attacker = params.attacker

	-- Check target position
	local facing_direction = parent:GetAnglesAsVector().y
	local attacker_vector = (attacker:GetOrigin() - parent:GetOrigin())
	local attacker_direction = VectorToAngles( attacker_vector ).y
	local angle_diff = math.abs( AngleDiff( facing_direction, attacker_direction ) )

	if angle_diff >= self.angle_front then return 0 end

    local reduction = self.pet_damage_reduction

    self:PlayEffects()

	local damage_blocked = reduction * params.damage / 100

	return damage_blocked
end

function modifier_pet_bulwark:PlayEffects()
	local particle_cast = "particles/units/heroes/hero_mars/mars_shield_of_mars.vpcf"
	local sound_cast = "Hero_Mars.Shield.Block"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	self:GetParent():EmitSound(sound_cast)
end