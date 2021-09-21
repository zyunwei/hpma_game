modifier_in_blockade = class({})

local public = modifier_in_blockade

function public:IsHidden() return false end
function public:IsDebuff() return true end
function public:IsPurgable() return false end

function public:OnCreated(params)
    if not IsServer() then return end
    self:StartIntervalThink(1)
    self.particle = ParticleManager:CreateParticleForPlayer("particles/generic_gameplay/screen_damage_indicator.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), self:GetParent():GetPlayerOwner())
    ParticleManager:SetParticleControl(self.particle, 1, Vector(1,0,0))
end

function public:GetEffectName()
    return "particles/econ/events/ti9/ti9_monkey_debuff_puddle.vpcf"
end

function public:GetTexture()
	return "nevermore_dark_lord"
end

function public:OnIntervalThink()
    if not IsServer() then return end
    local hero = self:GetParent()
    if IsAlive(hero) == false or hero.GetPlayerID == nil then
        return
    end

    local player = PlayerResource:GetPlayer(hero:GetPlayerID())
    if NotNull(player) then
        EmitSoundOnClient("Conquest.capture_point_timer", player)
    end

    if IsAlive(hero) and not hero:HasModifier("modifier_ability_custom_outlaw_maniac_buff") then
        hero:ShowCustomMessage({type="bottom", msg="#xxwar_msg_in_blockade_region", class="error"})
    end

    local playerInfo = GameRules.XW:GetPlayerInfo(hero:GetPlayerID())
    if playerInfo and playerInfo.InBlockadeTime > 30 and not hero:HasModifier("modifier_ability_custom_outlaw_maniac_buff") then
        local particlePos = self:GetParent():GetAbsOrigin()
        local blood_particle = ParticleManager:CreateParticle("particles/econ/items/tuskarr/tusk_ti9_immortal/tusk_ti9_golden_walruspunch_start_magic.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl(blood_particle, 0, particlePos)
        ParticleManager:ReleaseParticleIndex(blood_particle)

        ApplyDamage({
            victim = hero,
            attacker = hero,
            damage = math.ceil(hero:GetMaxHealth() * 0.1),
            damage_type = DAMAGE_TYPE_PURE,
            ability = nil
        })
    end
end

function public:OnDestroy()
    if not IsServer() then return end
    ParticleManager:DestroyParticle(self.particle, true)
    ParticleManager:ReleaseParticleIndex(self.particle)
end
