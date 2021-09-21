
--@Class CDOTA_Item

function CDOTA_Item:GetQuality()
	local conf = ItemConfig[self:GetAbilityName()]
	if not conf then return -1 end
	return conf["quality"]
end

function CDOTA_Item:GetCustomData()
	return {}
end
