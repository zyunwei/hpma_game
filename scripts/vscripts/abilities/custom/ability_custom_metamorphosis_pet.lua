ability_custom_metamorphosis_pet = ability_custom_metamorphosis_pet or class({})

function ability_custom_metamorphosis_pet:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
    local modifierParams = {
        pet_bonus_attack_speed = self:GetSpecialValueFor("pet_bonus_attack_speed"),
    }

    local affixAttr = self:GetCaster():GetCustomAttribute("crazy_pet")
    if affixAttr and affixAttr > 0 then
        modifierParams.pet_bonus_attack_speed = modifierParams.pet_bonus_attack_speed + affixAttr
    end
    
    local cards = CardGroupSystem:GetPlayerUsingCards(caster:GetPlayerOwnerID())

    local randomSummon = {}
    for _, card in ipairs(cards) do
        _, index = string.find(card, "ability_custom_call_summon_")
        if index then
            table.insert(randomSummon, string.sub(card, index + 1))
        end
    end

    local summon = table.random(randomSummon)
    if summon == nil then return end
    local unit_name = "npc_dota_hero_"..summon

    local duration = 40

    local unit = CallHeroPool:SummonHero(caster, duration, unit_name)

    unit:AddNewModifier(caster, nil, "modifier_crazy_pet", {
        bonus_attackspeed = modifierParams.pet_bonus_attack_speed
    })
end
