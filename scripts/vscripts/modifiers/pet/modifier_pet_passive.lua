modifier_pet_passive = class({})
LinkLuaModifier("modifier_custom_aghanims_shard", "modifiers/pet/modifier_pet_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_custom_ultimate_scepter", "modifiers/pet/modifier_pet_passive", LUA_MODIFIER_MOTION_NONE)

local public = modifier_pet_passive

function public:IsHidden() return true end
function public:IsDebuff() return false end
function public:IsPurgable() return false end
function public:RemoveOnDeath() return false end

function public:CheckState()
	local state = {
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = false,
	}

	return state
end

function public:OnCreated()
	if IsServer() then 
		self:StartIntervalThink(0.5)
	end
end

function public:OnIntervalThink()
	local parent = self:GetParent()
	if IsNull(parent) then return end
	local gameTime = math.floor(GameManager.GetGameTime())
	if gameTime ~= 0 and gameTime % PetExpCtrl:GetTickTime() == 0 then
		parent:AddExperience(gameTime * 0.7, 0, false, false)
	end
	if parent:HasModifier("modifier_item_aghanims_shard") and not parent:HasModifier("modifier_custom_aghanims_shard") then
		parent:AddNewModifier(parent, nil, "modifier_custom_aghanims_shard", {})
	end
	
	if not parent:HasModifier("modifier_item_aghanims_shard") and parent:HasModifier("modifier_custom_aghanims_shard") then 
		parent:RemoveModifierByName("modifier_custom_aghanims_shard")
	end

	if parent:HasModifier("modifier_item_ultimate_scepter") and not parent:HasModifier("modifier_custom_ultimate_scepter") then
		parent:AddNewModifier(parent, nil, "modifier_custom_ultimate_scepter", {})
	end

	if not parent:HasModifier("modifier_item_ultimate_scepter") and parent:HasModifier("modifier_custom_ultimate_scepter") then
		parent:RemoveModifierByName("modifier_custom_ultimate_scepter")
	end
end

modifier_custom_aghanims_shard = class({})

function modifier_custom_aghanims_shard:IsHidden() return false end
function modifier_custom_aghanims_shard:IsDebuff() return false end
function modifier_custom_aghanims_shard:IsPurgable() return false end
function modifier_custom_aghanims_shard:RemoveOnDeath() return false end

function modifier_custom_aghanims_shard:GetTexture()
    return "item_aghanims_shard"
end


modifier_custom_ultimate_scepter = class({})

function modifier_custom_ultimate_scepter:IsHidden() return false end
function modifier_custom_ultimate_scepter:IsDebuff() return false end
function modifier_custom_ultimate_scepter:IsPurgable() return false end
function modifier_custom_ultimate_scepter:RemoveOnDeath() return false end

function modifier_custom_ultimate_scepter:GetTexture()
    return "item_ultimate_scepter"
end