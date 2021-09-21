if not IsServer() and CustomItemSpellSystem == nil then
    CustomItemSpellSystem = { GetBaseClass = function () return {} end }
    function CustomItemSpellSystem:GetBuffIcon(buff, defaultIcon)
        local texture = ""
        if buff == nil or buff:IsNull() or buff.GetAbility == nil then
            return texture
        end
        local ability = buff:GetAbility()
        if ability ~= nil and ability:IsNull() == false then
            texture = ability:GetName()
            if string.find(texture, "custom_item_") == 1 then
                texture = string.gsub(texture, "custom_item_", "item_")
            end
        else
            texture = defaultIcon
        end

        return texture
    end

    function NotNull(entity)
        return entity and not entity:IsNull()
    end

    function IsNull(entity)
        return not entity or entity:IsNull()
    end
end
