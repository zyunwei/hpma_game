ability_custom_yuanshengzhili = ability_custom_yuanshengzhili or class({})

function ability_custom_yuanshengzhili:OnAbilityPhaseStart()
    return self:CheckPhaseStart()
end

function ability_custom_yuanshengzhili:OnSpellStart()
    return self:CheckSpellStart()
end

function ability_custom_yuanshengzhili:CastAbilityTarget(target, keys)
    if target ~= nil and IsNull(target) == false then

        local caster = self:GetCaster()
        local duration = self:GetSpecialValueFor("duration")
        local knock_up_height = self:GetSpecialValueFor("height")
        local damage_rate = self:GetSpecialValueFor("damage_rate")
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

function ability_custom_yuanshengzhili:OnFold()
	local caster = self:GetCaster()
	if IsNull(caster) then return end

	if caster:HasModifier("modifier_wuyingjiaoxinfa") then
		CardGroupSystem:ReplaceCard(caster:GetPlayerID(), "ability_custom_yuanshengzhili", "ability_custom_wuyingjiao", true)
	end
end