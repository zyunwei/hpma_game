ability_custom_mana_drain = ability_custom_mana_drain or class({})

LinkLuaModifier("modfier_ability_custom_mana_drain_debuff", "abilities/custom/ability_custom_mana_drain", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modfier_ability_custom_mana_drain_buff", "abilities/custom/ability_custom_mana_drain", LUA_MODIFIER_MOTION_NONE)

function ability_custom_mana_drain:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
    local castRange = self:GetSpecialValueFor("max_distance")
    local modifierParams = {
        duration = self:GetSpecialValueFor("duration"),
        move_speed_slow = self:GetSpecialValueFor("move_speed_slow"),
        mana_per_sec = self:GetSpecialValueFor("mana_per_sec"),
        max_distance = castRange,
    }
    if caster:HasModifier("modifier_mofatouquxinfa") then
        modifierParams.max_count = 3
    end
    caster:AddNewModifier(caster, nil, "modfier_ability_custom_mana_drain_buff", modifierParams)
end

modfier_ability_custom_mana_drain_buff = modfier_ability_custom_mana_drain_buff or class({})

function modfier_ability_custom_mana_drain_buff:IsHidden() return false end
function modfier_ability_custom_mana_drain_buff:IsDebuff() return false end
function modfier_ability_custom_mana_drain_buff:IsPurgable() return false end
function modfier_ability_custom_mana_drain_buff:RemoveOnDeath() return true end

function modfier_ability_custom_mana_drain_buff:GetTexture()
    return "ability_custom_mana_drain"
end

function modfier_ability_custom_mana_drain_buff:OnCreated(params)
    if not IsServer() then return end
    self.move_speed_slow = params.move_speed_slow or 35
    self.mana_per_sec = params.mana_per_sec or 200
    self.max_distance = params.max_distance or 1200
    self.max_count = params.max_count or 1
    self.debuff_list = {}
    self:StartIntervalThink(0.5)
end

function modfier_ability_custom_mana_drain_buff:OnIntervalThink()
    local target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP
    local target_team =  DOTA_UNIT_TARGET_TEAM_ENEMY
    local target_flags = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE
    local caster = self:GetCaster()
    if IsNull(caster) then return end
    if caster:IsStunned() or caster:IsSilenced() then
        for _, debuff in ipairs(self.debuff_list) do
            if NotNull(debuff) then
                debuff:Destroy()
            end
        end
        self.debuff_list = {}
        return
    end

    local enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, self.max_distance, target_team, target_type, target_flags, FIND_CLOSEST, false)
    table.sort(enemies, function(a,b) return a.IsRealHero ~= nil and a:IsRealHero() end)

    for _, enemy in pairs(enemies) do
        if NotNull(enemy) and enemy:IsMagicImmune() == false then
            if #self.debuff_list >= self.max_count then break end
            if not enemy:HasModifier("modfier_ability_custom_mana_drain_debuff") then
                local modifierParams = {
                    duration = self:GetRemainingTime(),
                    move_speed_slow = self.move_speed_slow,
                    mana_per_sec = self.mana_per_sec,
                    max_distance = self.max_distance,
                }
                local debuff = enemy:AddNewModifier(caster, nil, "modfier_ability_custom_mana_drain_debuff", modifierParams)
                table.insert(self.debuff_list, debuff)
            end
        end
    end
end

function modfier_ability_custom_mana_drain_buff:RemoveModifier(modifier)
    table.remove_value(self.debuff_list, modifier)
end

modfier_ability_custom_mana_drain_debuff = modfier_ability_custom_mana_drain_debuff or class({})

function modfier_ability_custom_mana_drain_debuff:IsHidden() return false end
function modfier_ability_custom_mana_drain_debuff:IsDebuff() return true end
function modfier_ability_custom_mana_drain_debuff:IsPurgable() return false end
function modfier_ability_custom_mana_drain_debuff:RemoveOnDeath() return true end

function modfier_ability_custom_mana_drain_debuff:GetTexture()
    return "ability_custom_mana_drain"
end

function modfier_ability_custom_mana_drain_debuff:OnCreated(params)

    self.move_speed_slow = params.move_speed_slow or 35
    self.mana_per_sec = params.mana_per_sec or 200
    self.max_distance = params.max_distance or 1200
    if not IsServer() then return end
    local parent = self:GetParent()
    local caster = self:GetCaster()
    if IsNull(parent) or IsNull(caster) then return end

    self.particle_drain_fx = ParticleManager:CreateParticle("particles/econ/items/lion/lion_demon_drain/lion_spell_mana_drain_demon.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, parent)
    ParticleManager:SetParticleControlEnt(self.particle_drain_fx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.particle_drain_fx, 1, caster, PATTACH_POINT_FOLLOW, "attach_mouth", caster:GetAbsOrigin(), true)
    self:AddParticle(self.particle_drain_fx, false, false, -1, false, false)
    self:StartIntervalThink(0.1)
end

function modfier_ability_custom_mana_drain_debuff:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
    return decFuncs
end


function modfier_ability_custom_mana_drain_debuff:OnIntervalThink()
    if not IsServer() then return end
    local parent = self:GetParent()
    local caster = self:GetCaster()
    if IsNull(parent) or IsNull(caster) then return end
    local target_mana = parent:GetMana()

    local drainMana = self.mana_per_sec / 10
    if target_mana > drainMana then
        parent:ReduceMana(drainMana)
        if caster:GetManaPercent() ~= 100 then
            caster:GiveMana(drainMana)
        else
            caster:Heal(drainMana, nil)
        end
    else
        parent:ReduceMana(target_mana)
        if caster:GetManaPercent() ~= 100 then
            caster:GiveMana(drainMana)
        else
            caster:Heal(drainMana, nil)
        end
    end

    local distance = (caster:GetAbsOrigin() - parent:GetAbsOrigin()):Length()
    if distance > self.max_distance then
        self:Destroy()
    end
end

function modfier_ability_custom_mana_drain_debuff:GetModifierMoveSpeedBonus_Percentage()
    return -self.move_speed_slow
end

function modfier_ability_custom_mana_drain_debuff:OnDestroy()
    if not IsServer() then return end
    local caster = self:GetCaster()
    if IsNull(caster) then return end
    local modifier = caster:FindModifierByName("modfier_ability_custom_mana_drain_buff")
    if NotNull(modifier) then
        modifier:RemoveModifier(self)
    end
end