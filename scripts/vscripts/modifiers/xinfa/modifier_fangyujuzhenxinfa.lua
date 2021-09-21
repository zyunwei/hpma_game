modifier_fangyujuzhenxinfa = class({})

function modifier_fangyujuzhenxinfa:IsHidden() return false end
function modifier_fangyujuzhenxinfa:IsDebuff() return false end
function modifier_fangyujuzhenxinfa:IsPurgable() return false end
function modifier_fangyujuzhenxinfa:RemoveOnDeath() return false end

function modifier_fangyujuzhenxinfa:GetTexture()
	return "ability_custom_defense_matrix"
end

function modifier_fangyujuzhenxinfa:OnCreated(params)
    if not IsServer() then return end
    self.block_damage = params.block_damage or 300
    self:SetStackCount(1)
end

function modifier_fangyujuzhenxinfa:GetBonusBlockDamage()
    return self.block_damage * self:GetStackCount()
end