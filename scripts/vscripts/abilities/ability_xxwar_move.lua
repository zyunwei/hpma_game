ability_xxwar_move = ability_xxwar_move or class({})

local public = ability_xxwar_move

function public:OnSpellStart()
	local caster = self:GetCaster()
	if IsNull(caster) then
		return false
	end
end
