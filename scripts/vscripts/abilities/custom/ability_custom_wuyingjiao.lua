ability_custom_wuyingjiao = ability_custom_wuyingjiao or class({})

LinkLuaModifier("modifier_wuyingjiao_debuff", "abilities/custom/ability_custom_wuyingjiao", LUA_MODIFIER_MOTION_NONE)

function ability_custom_wuyingjiao:OnAbilityPhaseStart()
    return self:CheckPhaseStart()
end

function ability_custom_wuyingjiao:OnSpellStart()
    return self:CheckSpellStart()
end

function ability_custom_wuyingjiao:CastAbilityTarget(target, keys)
    if target ~= nil and IsNull(target) == false then

        local caster = self:GetCaster()
        local duration = self:GetSpecialValueFor("duration")
        local knock_up_height = self:GetSpecialValueFor("height")
        local damage_rate = self:GetSpecialValueFor("damage_rate")
        local slow_duration = self:GetSpecialValueFor("slow_duration")
        local slow_percentage = self:GetSpecialValueFor("slow_percentage")

        if IsNull(caster) then return end

        local affixAttr = self:GetCaster():GetCustomAttribute("kick_damage")
        if affixAttr and affixAttr > 0 then
            damage_rate = damage_rate + affixAttr
        end

        local damage = keys.damage * (1 + damage_rate / 100)

        local location = target:GetAbsOrigin()
        local knockbackProperties = {
            should_stun = true,
            center_x = location.x,
            center_y = location.y,
            center_z = location.z,
            duration = duration * (1 - target:GetStatusResistance()),
            knockback_duration = duration * (1 - target:GetStatusResistance()),
            knockback_distance = 0,
            knockback_height = knock_up_height
        }

        target:AddNewModifier(caster, nil, "modifier_knockback", knockbackProperties)

        target:AddNewModifier(caster, nil, "modifier_wuyingjiao_debuff", {duration = slow_duration, slow_percentage = slow_percentage})

        local particleIndex = ParticleManager:CreateParticle("particles/econ/items/tuskarr/tusk_ti9_immortal/tusk_ti9_golden_walruspunch_start_water.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl( particleIndex, 0, target:GetAbsOrigin() )
        ParticleManager:ReleaseParticleIndex( particleIndex )

        local damageTable = {
            victim = target,
            attacker = caster,
            damage = damage,
            damage_type = self:GetAbilityDamageType(),
        }

        ApplyDamage(damageTable)

        EmitSoundOn("Hero_Tusk.WalrusPunch.Target", target)

        SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, target, damage, nil)
    end
end

modifier_wuyingjiao_debuff = modifier_wuyingjiao_debuff or class({})

function modifier_wuyingjiao_debuff:IsHidden() return false end
function modifier_wuyingjiao_debuff:IsDebuff() return true end
function modifier_wuyingjiao_debuff:IsPurgable() return false end
function modifier_wuyingjiao_debuff:RemoveOnDeath() return true end

function modifier_wuyingjiao_debuff:GetTexture()
    return "ability_custom_wuyingjiao"
end

function modifier_wuyingjiao_debuff:OnCreated(params)
    self.slow_percentage = params.slow_percentage or 40
end

function modifier_wuyingjiao_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_TOOLTIP,
	}
end

function modifier_wuyingjiao_debuff:GetModifierMoveSpeedBonus_Percentage()
	return -self.slow_percentage
end

function modifier_wuyingjiao_debuff:OnTooltip()
    return self.slow_percentage
end
