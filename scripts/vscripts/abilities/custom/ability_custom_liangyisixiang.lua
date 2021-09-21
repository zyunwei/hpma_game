ability_custom_liangyisixiang = ability_custom_liangyisixiang or class({})

LinkLuaModifier("modifier_ability_custom_liangyisixiang_buff", "abilities/custom/ability_custom_liangyisixiang", LUA_MODIFIER_MOTION_NONE)

function ability_custom_liangyisixiang:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if IsNull(caster) then return end
    local incoming_damage = self:GetSpecialValueFor("incoming_damage")

    local affixAttr = self:GetCaster():GetCustomAttribute("bagua")
    if affixAttr and affixAttr ~= 0 then
        incoming_damage = incoming_damage + affixAttr
    end
    
    caster:ModifyCustomAttribute("incoming_damage", "ability_custom_liangyisixiang", incoming_damage)

	local modifier = caster:FindModifierByName("modifier_ability_custom_liangyisixiang_buff")
    if NotNull(modifier) then
        modifier:IncrementStackCount()
    else
        caster:AddNewModifier(caster, nil, "modifier_ability_custom_liangyisixiang_buff", {})
    end
end

function ability_custom_liangyisixiang:OnFold()
	local caster = self:GetCaster()
	if IsNull(caster)  then return end

	if caster:HasModifier("modifier_taijibaguaxinfa") then
		CardGroupSystem:ReplaceCard(caster:GetPlayerID(), "ability_custom_liangyisixiang", "ability_custom_taijibagua", true)
	end
end

modifier_ability_custom_liangyisixiang_buff = modifier_ability_custom_liangyisixiang_buff or class({})

function modifier_ability_custom_liangyisixiang_buff:IsHidden() return false end
function modifier_ability_custom_liangyisixiang_buff:IsDebuff() return false end
function modifier_ability_custom_liangyisixiang_buff:IsPurgable() return false end
function modifier_ability_custom_liangyisixiang_buff:RemoveOnDeath() return false end

function modifier_ability_custom_liangyisixiang_buff:GetTexture()
    return "ability_custom_liangyisixiang"
end

function modifier_ability_custom_liangyisixiang_buff:OnCreated()
    if not IsServer() then return end
    self:SetStackCount(1)
end
