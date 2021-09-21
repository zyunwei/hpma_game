ability_custom_practice_in_seclusion = ability_custom_practice_in_seclusion or class({})

LinkLuaModifier("modifier_ability_custom_practice_in_seclusion_buff", "abilities/custom/ability_custom_practice_in_seclusion", LUA_MODIFIER_MOTION_NONE)

function ability_custom_practice_in_seclusion:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
    local modifierParams = {
        bonus_damage = self:GetSpecialValueFor("bonus_damage"),
        bonus_attack_speed = self:GetSpecialValueFor("bonus_attack_speed"),
        duration = self:GetSpecialValueFor("duration"),
    }
    caster:AddNewModifier(caster, nil, "modifier_ability_custom_practice_in_seclusion_buff", modifierParams)

end

modifier_ability_custom_practice_in_seclusion_buff = modifier_ability_custom_practice_in_seclusion_buff or class({})

function modifier_ability_custom_practice_in_seclusion_buff:IsHidden() return false end
function modifier_ability_custom_practice_in_seclusion_buff:IsDebuff() return false end
function modifier_ability_custom_practice_in_seclusion_buff:IsPurgable() return false end
function modifier_ability_custom_practice_in_seclusion_buff:RemoveOnDeath() return true end

function modifier_ability_custom_practice_in_seclusion_buff:GetEffectName()
    return "particles/addons_gameplay/morokai_orb_glow_energy.vpcf"
end

function modifier_ability_custom_practice_in_seclusion_buff:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW 
end

function modifier_ability_custom_practice_in_seclusion_buff:GetTexture()
    return "ability_custom_practice_in_seclusion"
end

function modifier_ability_custom_practice_in_seclusion_buff:OnCreated(params)
    if not IsServer() then return end
    local parent = self:GetParent()
    if IsNull(parent) then return end
    self.bonus_damage = params.bonus_damage or 1
    self.bonus_attack_speed = params.bonus_attack_speed or 1
    self:StartIntervalThink(1)
end

function modifier_ability_custom_practice_in_seclusion_buff:OnIntervalThink()
    local parent = self:GetParent()
    if IsNull(parent) then return end
    local canBeSeen = false
    for _, playerInfo in pairs(GameRules.XW.PlayerList) do
        local hero = playerInfo.Hero
        if NotNull(hero) and hero:GetTeamNumber() ~= parent:GetTeamNumber() and hero:CanEntityBeSeenByMyTeam(parent) then
            canBeSeen = true
            break
        end
    end
    if not canBeSeen then
        parent:ModifyCustomAttribute("attack_damage", "ability_custom_practice_in_seclusion", self.bonus_damage)
        parent:ModifyCustomAttribute("attack_speed", "ability_custom_practice_in_seclusion", self.bonus_attack_speed)
    end
end



