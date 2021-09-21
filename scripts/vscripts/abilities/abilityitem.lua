function AddStatusResistance(keys)
    local caster = keys.caster

    if IsNull(caster) or IsNull(keys.ability) then
        return
    end

    caster:AddNewModifier(caster, keys.ability, "modifier_status_resistance", {status_res = keys.status_res})
end

function IntDamage(keys)
    local target = keys.target
    local caster = keys.caster
    local ability = keys.ability

    if IsNull(caster) or IsNull(ability) or IsNull(target) then
        return
    end

    local int = caster:GetIntellect()
    local multiple = keys.Multiple or 1
    local damageTable = {
        victim = target,
        attacker = caster,
        damage = int * multiple,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = ability,
    }
    ApplyDamage(damageTable)
end
