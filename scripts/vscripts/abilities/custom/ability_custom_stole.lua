ability_custom_stole = ability_custom_stole or class({})

function ability_custom_stole:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
    local modifierParams = {
        buff_duration = self:GetSpecialValueFor("duration"),
        chance = self:GetSpecialValueFor("chance"),
        bonus_magic_find = self:GetSpecialValueFor("bonus_magic_find"),
    }
    caster:AddNewModifier(caster, nil, "modifier_ability_custom_stole_buff", modifierParams)

end

LinkLuaModifier("modifier_ability_custom_stole_buff", "abilities/custom/ability_custom_stole", LUA_MODIFIER_MOTION_NONE)

modifier_ability_custom_stole_buff = modifier_ability_custom_stole_buff or class({})

function modifier_ability_custom_stole_buff:IsHidden() return false end
function modifier_ability_custom_stole_buff:IsDebuff() return false end
function modifier_ability_custom_stole_buff:IsPurgable() return false end
function modifier_ability_custom_stole_buff:RemoveOnDeath() return true end

function modifier_ability_custom_stole_buff:GetTexture()
    return "ability_custom_stole"
end

function modifier_ability_custom_stole_buff:OnCreated(params)
    if not IsServer() then return end
    local parent = self:GetParent()
    if IsNull(parent) then return end
    self.duration = params.buff_duration or 15
    self.chance = params.chance or 10
    self.bonus_magic_find = params.bonus_magic_find or 20
    parent:ModifyCustomAttribute("magic_find", "magic_find", self.bonus_magic_find)
end

function modifier_ability_custom_stole_buff:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_ability_custom_stole_buff:OnAttackLanded(keys)
	if not IsServer() then return end

	local parent = self:GetParent()
	local attacker = keys.attacker
	local target = keys.target
	if IsNull(parent) or IsNull(attacker) or IsNull(target) then return end

	if attacker ~= parent then return end
    if self:GetDuration() == -1 then
		self:SetDuration(self.duration, true)
	end

    if target.IsRealHero == nil or target:IsRealHero() == false or target:GetPlayerOwner() == nil then return end

    if RollPercentage(self.chance) then
        if not target.IsPet then
            local bag = target:GetBag()
            if bag then
                local items = bag:GetAllItems()
                if #items ~= 0 then
                    local item = table.random(items)
                    parent:AddOwnerItemByName(item)
                    bag:RemoveItemByName(item, 1)
                end
            end
        else
            local itemList = {}
            for i=0,5 do
                local item = target:GetItemInSlot(i)
                if item then
                    table.insert(itemList, item)
                end
            end
            if #itemList ~= 0 then
                local targetItem = table.random(itemList)
                target:RemoveItem(targetItem)
                local pets = CallHeroPool:GetPlayerPets()
                if #pets ~= 0 then
                    local pet = table.random(pets)
                    pet:AddItem(targetItem)
                end
            end
        end
        local path = "particles/units/heroes/hero_rubick/rubick_spell_steal.vpcf"
        local particle_index = ParticleManager:CreateParticle(path, PATTACH_POINT_FOLLOW, target)
        ParticleManager:SetParticleControl( particle_index, 0, parent:GetAbsOrigin())
        ParticleManager:SetParticleControl( particle_index, 1, parent:GetAbsOrigin())
        ParticleManager:SetParticleControl( particle_index, 3, parent:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle_index)
        local sound_cast = "Hero_Rubick.SpellSteal.Cast"
        EmitSoundOn( sound_cast, parent )
        local sound_target = "Hero_Rubick.SpellSteal.Target"
        EmitSoundOn( sound_target, target )
    end
end

function modifier_ability_custom_stole_buff:OnDestroy()
    if not IsServer() then return end
    local parent = self:GetParent()
    if IsNull(parent) then return end
    parent:ModifyCustomAttribute("magic_find", "magic_find", -self.bonus_magic_find)
end