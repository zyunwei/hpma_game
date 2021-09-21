ability_custom_mana_shield = ability_custom_mana_shield or class({})

LinkLuaModifier("modifier_ability_custom_mana_shield_buff", "abilities/custom/ability_custom_mana_shield", LUA_MODIFIER_MOTION_NONE)

function ability_custom_mana_shield:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end

    local modifierParams = {
        duration = self:GetSpecialValueFor("duration"),
        block_damage_rate = self:GetSpecialValueFor("block_damage_rate"),
        block_damage_per_mana = self:GetSpecialValueFor("block_damage_per_mana"),
    }
    caster:ModifyCustomAttribute("int", "ability_custom_mana_shield", self:GetSpecialValueFor("bonus_int"))
    caster:EmitSound("Hero_Medusa.ManaShield.On")

    caster:AddNewModifier(caster, nil, "modifier_ability_custom_mana_shield_buff", modifierParams)
end

modifier_ability_custom_mana_shield_buff = modifier_ability_custom_mana_shield_buff or class({})

function modifier_ability_custom_mana_shield_buff:IsHidden() return false end
function modifier_ability_custom_mana_shield_buff:IsDebuff() return false end
function modifier_ability_custom_mana_shield_buff:IsPurgable() return false end
function modifier_ability_custom_mana_shield_buff:RemoveOnDeath() return true end

function modifier_ability_custom_mana_shield_buff:GetEffectName()
	return "particles/units/heroes/hero_medusa/medusa_mana_shield.vpcf"
end

function modifier_ability_custom_mana_shield_buff:GetTexture()
    return "ability_custom_mana_shield"
end

function modifier_ability_custom_mana_shield_buff:OnCreated(params)
    if not IsServer() then return end

    self.block_damage_rate = params.block_damage_rate or 70
    self.block_damage_per_mana = params.block_damage_per_mana or 2.5
end

function modifier_ability_custom_mana_shield_buff:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }

    return decFuncs
end

function modifier_ability_custom_mana_shield_buff:GetModifierIncomingDamage_Percentage(keys)
	if not IsServer() then return end
    local parent = self:GetParent()
    local target = keys.target
    if IsNull(target) or IsNull(parent) then return end
    if target ~= parent then return end

	if not (keys.damage_type == DAMAGE_TYPE_MAGICAL and parent:IsMagicImmune()) and parent.GetMana then

		local mana_to_block	= keys.original_damage * self.block_damage_rate * 0.01 / self.block_damage_per_mana

		if mana_to_block >= parent:GetMana() then
			parent:EmitSound("Hero_Medusa.ManaShield.Proc")

			local shield_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_medusa/medusa_mana_shield_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
			ParticleManager:ReleaseParticleIndex(shield_particle)
		end

		parent:ReduceMana(mana_to_block)
        if parent:GetManaPercent() < 20 then
            self:Destroy()
        end

		return math.min(self.block_damage_rate, self.block_damage_rate * parent:GetMana() / math.max(mana_to_block, 1)) * (-1)
	end
end


function modifier_ability_custom_mana_shield_buff:OnDestroy()
    if not IsServer() then return end
    local parent = self:GetParent()
    if IsNull(parent) then return end
    parent:EmitSound("Hero_Medusa.ManaShield.Off")
end

