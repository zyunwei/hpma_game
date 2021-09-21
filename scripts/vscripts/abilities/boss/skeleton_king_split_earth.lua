LinkLuaModifier( "modifier_boss_shakeground_lua_thinker","modifiers/boss/modifier_boss_shakeground_lua_thinker", LUA_MODIFIER_MOTION_NONE )

skeleton_king_split_earth = skeleton_king_split_earth or class({})

local public = skeleton_king_split_earth

function public:OnSpellStart()
    local caster = self:GetCaster()
    if IsNull(caster) then return end
    local radius = self:GetSpecialValueFor("radius")
    local nFXIndex = ParticleManager:CreateParticle( "particles/clicked_rings_red.vpcf", PATTACH_CUSTOMORIGIN, nil )
    ParticleManager:SetParticleControl( nFXIndex, 0, caster:GetOrigin())
    ParticleManager:SetParticleControl( nFXIndex, 1, Vector(radius,1,1)  )
    ParticleManager:ReleaseParticleIndex(nFXIndex)

    CreateModifierThinker( caster, self, "modifier_boss_shakeground_lua_thinker", { duration = 3 }, caster:GetOrigin(), caster:GetTeamNumber(), false )
end