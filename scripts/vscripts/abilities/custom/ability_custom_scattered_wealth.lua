ability_custom_scattered_wealth = ability_custom_scattered_wealth or class({})

function ability_custom_scattered_wealth:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
    local bonus_spell_amp = self:GetSpecialValueFor("bonus_spell_amp")
    local bonus_attack = self:GetSpecialValueFor("bonus_attack")
    local bonus_attack_speed = self:GetSpecialValueFor("bonus_attack_speed")

    local gold = caster:GetGold()
    local remain = gold % 100
    caster:SpendGold(gold - remain)
    EmitSoundOnClient("General.Buy", PlayerResource:GetPlayer(caster:GetPlayerID()))
    local bonus_count = (gold - remain) / 100

    caster:ModifyCustomAttribute("spell_amp", "ability_custom_scattered_wealth", bonus_spell_amp * bonus_count)
    caster:ModifyCustomAttribute("attack_damage", "ability_custom_scattered_wealth", bonus_attack * bonus_count)
    caster:ModifyCustomAttribute("attack_speed", "ability_custom_scattered_wealth", bonus_attack_speed * bonus_count)
end