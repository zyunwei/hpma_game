ability_custom_spell_amplify = ability_custom_spell_amplify or class({})

LinkLuaModifier("modifier_custom_spell_amplify_on_cooldown", "abilities/custom/ability_custom_spell_amplify", LUA_MODIFIER_MOTION_NONE)

function ability_custom_spell_amplify:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
    local particle_fx = ParticleManager:CreateParticle("particles/avalon_assets/portal/portal_teleport_07_d.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(particle_fx, 0, caster:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle_fx)

    EmitSoundOn("General.LevelUp", caster)

    caster:ModifyCustomAttribute("spell_amp", "ability_custom_spell_amplify", caster:GetLevel() * 0.2)
    caster:AddNewModifier(caster, self, "modifier_custom_spell_amplify_on_cooldown", {})
end

function ability_custom_spell_amplify:OnStartCooldown()
	local caster = self:GetCaster()
	if IsNull(caster) then return end
    caster:AddNewModifier(caster, self, "modifier_custom_spell_amplify_on_cooldown", {})
end

modifier_custom_spell_amplify_on_cooldown = class({})

function modifier_custom_spell_amplify_on_cooldown:IsHidden() return true end
function modifier_custom_spell_amplify_on_cooldown:IsDebuff() return false end
function modifier_custom_spell_amplify_on_cooldown:IsPurgable() return false end
function modifier_custom_spell_amplify_on_cooldown:RemoveOnDeath() return true end

function modifier_custom_spell_amplify_on_cooldown:OnCreated()
    if not IsServer() then return end
    self.total_damage = 0
    self.ability = self:GetAbility()
end

function modifier_custom_spell_amplify_on_cooldown:DeclareFunctions()
	return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end

function modifier_custom_spell_amplify_on_cooldown:OnTakeDamage(keys)
    if not IsServer() then return end
    local attacker = keys.attacker
    local target = keys.unit
    local parent = self:GetParent()
    if IsNull(attacker) or IsNull(target) or IsNull(parent) or IsNull(self.ability) then return end

    if target ~= parent then return end

    if not parent:HasModifier("modifier_jinengzengqiangxinfa") then return end

    self.total_damage = self.total_damage + keys.damage
    if self.total_damage >= 75 then
        local reduceCooldown = math.floor(self.total_damage / 75)
        self.total_damage = self.total_damage % 75
        if not self.ability:IsCooldownReady() then
            local remainCooldown = self.ability:GetCooldownTimeRemaining()
            if remainCooldown >= 1 then
                self.ability:EndCooldown()
                self.ability:StartCooldown(remainCooldown - reduceCooldown)
            end
        end
    end
end

