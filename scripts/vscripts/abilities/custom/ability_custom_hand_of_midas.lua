ability_custom_hand_of_midas = ability_custom_hand_of_midas or class({})

function ability_custom_hand_of_midas:OnSpellStart()
    local caster = self:GetCaster()
    if IsNull(caster) then return end
    local radius = self:GetCastRange(vec3_invalid, nil)
    local target = caster:GetCreepInRadius(radius, true)
    if IsNull(target) then return end
    local bonus_gold_multipler = self:GetSpecialValueFor("bonus_gold_multipler")
    local bonus_exp_multipler = self:GetSpecialValueFor("bonus_exp_multipler")
    target:EmitSound("DOTA_Item.Hand_Of_Midas")
    local bonus_gold = target:GetGoldBounty() * bonus_gold_multipler
    local bonus_exp = target:GetDeathXP() * bonus_exp_multipler

    local playerId = caster:GetPlayerOwnerID()
    if playerId == nil then
        return
    end

    SendOverheadEventMessage(PlayerResource:GetPlayer(playerId), OVERHEAD_ALERT_GOLD, target, bonus_gold, nil)

    local midas_particle = ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(midas_particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false)

	target:SetDeathXP(0)
	target:SetMinimumGoldBounty(0)
	target:SetMaximumGoldBounty(0)
	target:Kill(nil, caster)

    caster:AddExperience(bonus_exp, false, false)
	caster:ModifyGold(bonus_gold, true, 0)
end