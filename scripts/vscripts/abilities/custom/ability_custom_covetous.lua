ability_custom_covetous = ability_custom_covetous or class({})

function ability_custom_covetous:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
    local player = PlayerResource:GetPlayer(caster:GetPlayerID())
    local bonus_gold_pct = self:GetSpecialValueFor("bonus_gold_pct")
    local limit = self:GetSpecialValueFor("limit")
    local total_gold = math.floor(caster:GetGold() * bonus_gold_pct * 0.01)
    if total_gold > limit then
        total_gold = limit
    end
    caster:GiveGold(total_gold)
    local msg_particle = "particles/units/heroes/hero_alchemist/alchemist_lasthit_msg_gold.vpcf"
    local msg_particle_fx = ParticleManager:CreateParticleForPlayer(msg_particle, PATTACH_ABSORIGIN, caster, player)
    ParticleManager:SetParticleControl(msg_particle_fx, 1, Vector(0, total_gold, 0))
    ParticleManager:SetParticleControl(msg_particle_fx, 2, Vector(2, string.len(total_gold) + 1, 0))
    ParticleManager:SetParticleControl(msg_particle_fx, 3, Vector(255, 200, 33) )
    caster:EmitSound("Rune.Bounty")
end