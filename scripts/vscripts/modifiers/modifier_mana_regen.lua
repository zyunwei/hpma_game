modifier_mana_regen = class({})

local public = modifier_mana_regen

function public:IsHidden() return false end
function public:IsDebuff() return false end
function public:IsPurgable() return false end
function public:IgnoreTenacity() return true end
function public:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function public:OnCreated(params)
    self.interrupt = params.interrupt or 1
    self.mana_regen = params.mana_regen or 10
    self.texture = CustomItemSpellSystem:GetBuffIcon(self, "item_clarity")
end

function public:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function public:GetTexture()
    return self.texture
end

function public:GetModifierConstantManaRegen()
    return self.mana_regen
end

function public:OnAttackLanded(keys)
    if keys.attacker == nil or keys.attacker:IsNull() or self.interrupt == 0 then
        return
    end

    if keys.target == self:GetParent() then
        if keys.attacker.IsHero ~= nil and keys.attacker:IsHero() then
            self:GetParent():RemoveModifierByName("modifier_mana_regen")
        end
    end
end
