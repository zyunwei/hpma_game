modifier_corruption = class({})

local public = modifier_corruption

function public:IsHidden()
	return false
end

function public:IsDebuff()
	return true
end

function public:IsPurgable()
	return true
end

function public:IsPurgeException()
	return true
end

function public:OnCreated(params)
    self.armor_reduction = 0

    if IsServer() and params ~= nil then
    	self.armor_reduction = params.armor_reduction or -5
    end
end

function public:GetTexture()
    return "item_desolator"
end

function public:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function public:GetModifierPhysicalArmorBonus()
	return self.armor_reduction
end
