
--@Class CDOTA_Ability_Lua

function CDOTA_Ability_Lua:CheckPhaseStart()
	print("CDOTA_Ability_Lua:CheckPhaseStart()")
	local ability = self
    local canCast = ability:IsFullyCastable() and ability:IsCooldownReady() and ability:IsInAbilityPhase() == false
    if canCast == false or ability:CheckCostCrystal() == false then
        return false
    end

    local caster = self:GetCaster()
	if IsNull(caster) then return end

    local basemodifier = caster:FindModifierByName("modifier_hero_base")
    if IsNull(basemodifier) then
    	return false
    end

    if basemodifier:CheckAndCastAbility(caster, self) == false then
    	return false
    end

    return true
end
