if PetTalentCtrl == nil then
	PetTalentCtrl = RegisterController('pet_talent')
    setmetatable(PetTalentCtrl, PetTalentCtrl)
end

local public = PetTalentCtrl

function public:SaveTalent(pet)
    if IsNull(pet) then return end
    if CustomNetTables:GetTableValue("PetTalent", pet:GetUnitName()) then return end
    local specialValues = {}
    for i = 0, pet:GetAbilityCount()-1 do
		local ability = pet:GetAbilityByIndex(i)
		-- and ability:GetAbilityName() == "special_bonus_unique_mars_spear_bonus_damage"
		if NotNull(ability) and string.find(ability:GetAbilityName(), "special_bonus") ~= nil then
            local abilitySpecials = ability:GetAbilityKeyValues()["AbilitySpecial"]
            if abilitySpecials then
                local values = {}
                for _, v in pairs(abilitySpecials) do
                    if v.value then
                        table.insert(values, v.value)
                    end
                end
                specialValues[ability:GetAbilityName()] = values
            end
		end
        -- table.print(specialValues)
        CustomNetTables:SetTableValue("PetTalent", pet:GetUnitName(), specialValues)
	end
end