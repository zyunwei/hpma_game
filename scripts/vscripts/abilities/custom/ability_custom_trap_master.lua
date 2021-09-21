ability_custom_trap_master = ability_custom_trap_master or class({})

function ability_custom_trap_master:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
    if IsNull(caster) then return end
    local damage_multipler = self:GetSpecialValueFor("damage_multipler")
    local duration = self:GetSpecialValueFor("duration")
    TrapCtrl:CreateTrap(caster, damage_multipler, duration)
end