modifier_pet_armor_up = modifier_pet_armor_up or class({})

function modifier_pet_armor_up:IsHidden() return false end
function modifier_pet_armor_up:IsDebuff() return false end
function modifier_pet_armor_up:IsPurgable() return false end
function modifier_pet_armor_up:RemoveOnDeath() return true end


function modifier_pet_armor_up:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }
end

function modifier_pet_armor_up:GetTexture()
    return "ability_custom_pet_armor_up"
end

function modifier_pet_armor_up:GetModifierPhysicalArmorBonus()
    if not IsServer() then return end
    local parent = self:GetParent()
    if IsNull(parent) then return end
    local owner = parent:GetOwner()
    local bonus_armor = 0;
    if NotNull(owner) and owner:IsBaseNPC() and owner.IsRealHero ~= nil and owner:IsRealHero() then 
        local modifier = owner:FindModifierByName("modifier_ability_custom_pet_armor_up_buff")
        if NotNull(modifier) then
            bonus_armor = modifier:GetPetBonusArmor()

            local affixAttr = self:GetCaster():GetCustomAttribute("pet_armor")
            if affixAttr and affixAttr > 0 then
                bonus_armor = bonus_armor + affixAttr
            end

            bonus_armor = bonus_armor * modifier:GetStackCount()
        end
    end
    return bonus_armor
end
