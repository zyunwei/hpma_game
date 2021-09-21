ability_custom_defense_matrix = ability_custom_defense_matrix or class({})

LinkLuaModifier("modifier_ability_custom_defense_matrix_buff", "abilities/custom/ability_custom_defense_matrix", LUA_MODIFIER_MOTION_NONE)

function ability_custom_defense_matrix:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    if IsNull(caster) then return end

    EmitSoundOn("Hero_Tinker.DefensiveMatrix.Cast", caster)

    local modifierName = self:GetTargetModifier()
    local modifierParams = {
        duration = self:GetSpecialValueFor("duration"),
        block_damage = self:GetSpecialValueFor("block_damage"),
        bonus_status_resistance = self:GetSpecialValueFor("bonus_status_resistance"),
    }

    local modifier = caster:FindModifierByName("modifier_fangyujuzhenxinfa")
    if NotNull(modifier) then
        modifierParams.block_damage = modifierParams.block_damage + modifier:GetBonusBlockDamage()
    end

    for _, playerInfo in pairs(GameRules.XW.PlayerList) do
        local hero = playerInfo.Hero
        if NotNull(hero) and hero:IsAlive() and hero:GetTeamNumber() == caster:GetTeamNumber() then
            hero:AddNewModifier(caster, nil, modifierName, modifierParams)
        end
    end
end

function ability_custom_defense_matrix:GetTargetModifier()
    return "modifier_ability_custom_defense_matrix_buff"
end

modifier_ability_custom_defense_matrix_buff = class({})

function modifier_ability_custom_defense_matrix_buff:IsHidden() return false end
function modifier_ability_custom_defense_matrix_buff:IsDebuff() return false end
function modifier_ability_custom_defense_matrix_buff:IsPurgable() return false end
function modifier_ability_custom_defense_matrix_buff:RemoveOnDeath() return true end

function modifier_ability_custom_defense_matrix_buff:GetTexture()
	return "ability_custom_defense_matrix"
end

function modifier_ability_custom_defense_matrix_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
	}
end

function modifier_ability_custom_defense_matrix_buff:OnCreated(params)
    if not IsServer() then return end
    if IsNull(self:GetParent()) then return end
    self.block_damage = params.block_damage or 500
    self.bonus_status_resistance = params.bonus_status_resistance or 50
    self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/tinker_defense_matrix.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetParent())
    local position = self:GetParent():GetAbsOrigin()
    ParticleManager:SetParticleControlEnt(self.particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", position, true)
    self:AddParticle(self.particle, false, false, -1, false, false)
end

function modifier_ability_custom_defense_matrix_buff:GetModifierTotal_ConstantBlock(keys)
	local parent = self:GetParent()
	local caster = self:GetCaster()
	local target = keys.target
    local damage = keys.damage
	if IsNull(parent) or IsNull(caster) or IsNull(target) then return end

    if target ~= parent then return end

    local remainBlockDamage = self.block_damage

    if damage <= self.block_damage then
        self.block_damage = self.block_damage - damage
        return damage
    else
        local modifier = caster:FindModifierByName("modifier_fangyujuzhenxinfa")
        if NotNull(modifier) then
            modifier:IncrementStackCount()
        end
        self:Destroy()
        return remainBlockDamage
    end
end

function modifier_ability_custom_defense_matrix_buff:GetModifierStatusResistanceStacking()
    return self.bonus_status_resistance
end