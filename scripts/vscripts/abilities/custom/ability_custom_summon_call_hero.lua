function CallHero(keys)
    if IsServer() == false then return end

    local caster = keys.caster
    if IsNull(caster) then
        return
    end
    local unit_name = keys.unit_name
    if unit_name == nil then
        return
    end
    local duration = keys.duration or 40

    local unit = CallHeroPool:SummonHero(caster, duration, unit_name)

    local petModifier = caster:FindModifierByName("modifier_ability_custom_crazy_pet_buff")
    if NotNull(petModifier) then
        unit:AddNewModifier(caster, nil, "modifier_crazy_pet", {
            bonus_attackspeed = petModifier:GetPetBonusAttackSpeed()
        })
        petModifier:Destroy()
    end

    if NotNull(keys.ability) then
        if string.find(keys.ability:GetName(), "ability_custom_call_summon_") == 1 then
            CardGroupSystem:RemoveCard(caster:GetPlayerID(), keys.ability:GetName())
        end
    end
end
