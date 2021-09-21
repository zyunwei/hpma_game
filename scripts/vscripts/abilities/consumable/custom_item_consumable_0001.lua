require 'client'
custom_item_consumable_0001 = CustomItemSpellSystem:GetBaseClass()

local public = custom_item_consumable_0001

function public:OnCustomSpellStart(item)
    local caster = self:GetCaster()

    if IsNull(item) or IsNull(caster) or caster.GetPlayerID == nil then
        return
    end

    local playerId = caster:GetPlayerID()
    if PlayerInfo:AddRandomItemForPet(playerId, false) == false then
    	local modifierName = "modifier_pet_random_item"
		if caster:HasModifier(modifierName) then
            local modifier = caster:FindModifierByName(modifierName)
            if NotNull(modifier) then
            	modifier:IncrementStackCount()
            end
        else
            caster:AddNewModifier(caster, nil, modifierName, {})
        end
    end
end

LinkLuaModifier("modifier_pet_random_item", "abilities/consumable/custom_item_consumable_0001", LUA_MODIFIER_MOTION_NONE)

modifier_pet_random_item = class({})

function modifier_pet_random_item:IsHidden() return false end
function modifier_pet_random_item:IsDebuff() return false end
function modifier_pet_random_item:IsPurgable() return false end
function modifier_pet_random_item:RemoveOnDeath() return false end

function modifier_pet_random_item:OnCreated()
	self:SetStackCount(1)
end

function modifier_pet_random_item:GetTexture()
    return "item_consumable_0001"
end

function modifier_pet_random_item:OnStackCountChanged(iStackCount)
    if self:GetStackCount() <= 0 then
        self:Destroy()
    end
end
