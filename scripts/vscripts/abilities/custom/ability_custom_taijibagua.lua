ability_custom_taijibagua = ability_custom_taijibagua or class({})

LinkLuaModifier("modifier_ability_custom_taijibagua_buff", "abilities/custom/ability_custom_taijibagua", LUA_MODIFIER_MOTION_NONE)

function ability_custom_taijibagua:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
    local incoming_damage = self:GetSpecialValueFor("incoming_damage")

    local affixAttr = self:GetCaster():GetCustomAttribute("bagua")
    if affixAttr and affixAttr ~= 0 then
        incoming_damage = incoming_damage + affixAttr
    end
    
    caster:ModifyCustomAttribute("incoming_damage", "ability_custom_taijibagua", incoming_damage)
    caster:ModifyCustomAttribute("damage_outgoing", "ability_custom_taijibagua", incoming_damage * 0.5)

    local modifier = caster:FindModifierByName("modifier_ability_custom_taijibagua_buff")
    if NotNull(modifier) then
        modifier:IncrementStackCount()
    else
        caster:AddNewModifier(caster, nil, "modifier_ability_custom_taijibagua_buff", {})
    end
end

modifier_ability_custom_taijibagua_buff = modifier_ability_custom_taijibagua_buff or class({})

function modifier_ability_custom_taijibagua_buff:IsHidden() return false end
function modifier_ability_custom_taijibagua_buff:IsDebuff() return false end
function modifier_ability_custom_taijibagua_buff:IsPurgable() return false end
function modifier_ability_custom_taijibagua_buff:RemoveOnDeath() return false end

function modifier_ability_custom_taijibagua_buff:GetTexture()
    return "ability_custom_taijibagua"
end

function modifier_ability_custom_taijibagua_buff:OnCreated()
    if not IsServer() then return end
    self:SetStackCount(1)
end