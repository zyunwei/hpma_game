ability_custom_one_punch = ability_custom_one_punch or class({})

LinkLuaModifier("modifier_ability_custom_one_punch_buff", "abilities/custom/ability_custom_one_punch", LUA_MODIFIER_MOTION_NONE)

function ability_custom_one_punch:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
    local modifierParams = {
        move_speed_pct = self:GetSpecialValueFor("move_speed_pct"),
        duration = self:GetSpecialValueFor("duration"),
    }
    caster:AddNewModifier(caster, nil, "modifier_ability_custom_one_punch_buff", modifierParams)

end

modifier_ability_custom_one_punch_buff = modifier_ability_custom_one_punch_buff or class({})

function modifier_ability_custom_one_punch_buff:IsHidden() return false end
function modifier_ability_custom_one_punch_buff:IsDebuff() return false end
function modifier_ability_custom_one_punch_buff:IsPurgable() return false end
function modifier_ability_custom_one_punch_buff:RemoveOnDeath() return true end

function modifier_ability_custom_one_punch_buff:GetEffectName()
    return "particles/items2_fx/teleport_start_c.vpcf"
end

function modifier_ability_custom_one_punch_buff:GetEffectAttachType()
    return PATTACH_CENTER_FOLLOW
end

function modifier_ability_custom_one_punch_buff:GetTexture()
    return "ability_custom_one_punch"
end

function modifier_ability_custom_one_punch_buff:OnCreated(params)
    if not IsServer() then return end
    local parent = self:GetParent()
    if IsNull(parent) then return end
    self.move_speed_pct = params.move_speed_pct or 1
    self.start_time = GameRules:GetGameTime()
end

function modifier_ability_custom_one_punch_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_ability_custom_one_punch_buff:GetModifierMoveSpeedBonus_Percentage()
    if not IsServer() then return end
    return self.move_speed_pct * (GameRules:GetGameTime() - self.start_time)
end

function modifier_ability_custom_one_punch_buff:GetModifierBaseAttack_BonusDamage()
    local parent = self:GetParent()
    if IsNull(parent) then return end
    return (GameRules:GetGameTime() - self.start_time) * parent:GetLevel() * 1
end

function modifier_ability_custom_one_punch_buff:OnAttackLanded(keys)
    local parent = self:GetParent()
    local attacker =  keys.attacker
    local target = keys.target
    if IsNull(parent) or IsNull(attacker) or IsNull(target) then return end
    if attacker == parent then
        if not parent:HasModifier("modifier_yiquanchaorenxinfa") then
            self.start_time = GameRules:GetGameTime()
        end

        local targetPos = target:GetAbsOrigin()
        local biasPos = -250 * target:GetForwardVector()

        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_seer/dark_seer_normal_punch_rays1.vpcf", PATTACH_ABSORIGIN, target)
        ParticleManager:SetParticleControl(particle, 0, targetPos + biasPos)
        ParticleManager:ReleaseParticleIndex(particle)
        parent:EmitSound("Hero_Dark_Seer.NormalPunch.Lv3")

        local particle2 = ParticleManager:CreateParticle("particles/econ/items/ancient_apparition/aa_blast_ti_5/ancient_apparition_ice_blast_sphere_final_explosion_smoke_ti5.vpcf", PATTACH_ABSORIGIN, target)
        ParticleManager:SetParticleControl(particle2, 0, targetPos)
        ParticleManager:ReleaseParticleIndex(particle2)
    end
end
