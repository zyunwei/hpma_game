skeleton_king_jump = skeleton_king_jump or class({})

local public = skeleton_king_jump

function public:OnSpellStart()
    local caster = self:GetCaster()
    if IsNull(caster) then return end
    local radius = self:GetSpecialValueFor("radius")
    self.damage = self:GetSpecialValueFor("damage")

    local nFXIndex = ParticleManager:CreateParticle( "particles/clicked_rings_red.vpcf", PATTACH_WORLDORIGIN , nil )
    ParticleManager:SetParticleControl( nFXIndex, 0, caster:GetCursorPosition())
    ParticleManager:SetParticleControl( nFXIndex, 1, Vector(radius,1,1)  )
    ParticleManager:ReleaseParticleIndex(nFXIndex)

    local motion = caster:CreateMotion()
    motion:Jump(caster:GetOrigin(), caster:GetCursorPosition(), 500, 1, "modifier_custom_stun")
    motion:SetStopIfBlocked(true)
    motion:OnEnd(function()
        self:Effect()
    end)
end

function public:Effect()
    if IsNull(self) or IsNull(self:GetCaster()) then return end
    local radius = self:GetSpecialValueFor("radius")
    local nFXIndex1 = ParticleManager:CreateParticle( "particles/econ/items/brewmaster/brewmaster_offhand_elixir/brewmaster_thunder_clap_elixir.vpcf", PATTACH_WORLDORIGIN , nil )
    ParticleManager:SetParticleControlEnt( nFXIndex1, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "", self:GetCaster():GetOrigin(), true )
    ParticleManager:SetParticleControl( nFXIndex1, 1, Vector(radius,1,1)  )
    ParticleManager:ReleaseParticleIndex(nFXIndex1)
    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), self, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE , 0, false )
    for _,enemy in pairs( enemies ) do
        if NotNull(enemy) and enemy:IsInvulnerable() == false then
            local damageInfo =
            {
                victim = enemy,
                attacker = self:GetCaster(),
                damage = self.damage,
                damage_type = DAMAGE_TYPE_MAGICAL,
                ability = self,
            }

            ApplyDamage( damageInfo )
        end
    end
end