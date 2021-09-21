ability_custom_crystal_explosion = ability_custom_crystal_explosion or class({})

LinkLuaModifier("modifier_ability_custom_crystal_explosion_buff", "abilities/custom/ability_custom_crystal_explosion", LUA_MODIFIER_MOTION_NONE)

function ability_custom_crystal_explosion:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
    if IsNull(caster) then return end
    local bonus_multiple = self:GetSpecialValueFor("bonus_multiple")
    local crystal_damage_multiple = self:GetSpecialValueFor("crystal_damage_multiple")
    local remainCrystal = caster:GetCustomAttribute("crystal")
    local crystalCost = self:GetSpecialValueFor("crystal_cost") + remainCrystal
    local damage_type = self:GetAbilityDamageType()
    caster:ModifyCustomAttribute("crystal", "crystal", -remainCrystal)

    EmitGlobalSound("Hero_Crystal.CrystalNova")
    local modifier = caster:FindModifierByName("modifier_ability_custom_crystal_explosion_buff")
    if NotNull(modifier) then
        crystal_damage_multiple = crystal_damage_multiple + modifier:GetStackCount() * bonus_multiple
        modifier:IncrementStackCount()
    else
        caster:AddNewModifier(caster, nil, "modifier_ability_custom_crystal_explosion_buff", {})
    end

    local affixAttr = self:GetCaster():GetCustomAttribute("explosion")
    if affixAttr and affixAttr > 0 then
        crystal_damage_multiple = crystal_damage_multiple + affixAttr
    end

    local damage = crystal_damage_multiple * crystalCost
    local hero = nil
    for i = 1, 20 do
        hero = table.random(GameRules.XW.PlayerList).Hero
        if NotNull(hero) and hero ~= caster and not hero:IsMagicImmune() and hero:GetTeamNumber() ~= caster:GetTeamNumber() then break end
    end
    if NotNull(hero) then
        local particle_damage_fx = ParticleManager:CreateParticle("particles/econ/items/crystal_maiden/crystal_maiden_cowl_of_ice/maiden_crystal_nova_cowlofice.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
        ParticleManager:SetParticleControl(particle_damage_fx, 0, hero:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle_damage_fx)
        ApplyDamage({
            victim = hero,
            attacker = caster,
            damage_type = damage_type,
            damage = damage
        })
        -- AddFOWViewer(caster:GetTeamNumber(), hero:GetAbsOrigin(), 300, 3, true)
    end
end

modifier_ability_custom_crystal_explosion_buff = modifier_ability_custom_crystal_explosion_buff or class({})

function modifier_ability_custom_crystal_explosion_buff:IsHidden() return false end
function modifier_ability_custom_crystal_explosion_buff:IsDebuff() return false end
function modifier_ability_custom_crystal_explosion_buff:IsPurgable() return false end
function modifier_ability_custom_crystal_explosion_buff:RemoveOnDeath() return false end

function modifier_ability_custom_crystal_explosion_buff:GetTexture()
    return "ability_custom_crystal_explosion"
end

function modifier_ability_custom_crystal_explosion_buff:OnCreated()
    if not IsServer() then return end
    self:SetStackCount(1)
end
