CustomEvents('modal_dialog_response', function(e, data)
	local player = PlayerResource:GetPlayer(data.PlayerID)
	if IsNull(player) then return end

	local hero = player:GetAssignedHero()
	if IsNull(hero) then return end

	local steamid = hero:GetSteamID()
	if steamid == "0" then return end

	local options = ModalDialog:GetPlayerDialogOptions(steamid)
	if not options then return end

	local t = options[tonumber(data.index) or ""]
	if not t then return end

	if t.func then
		t.func()
		ModalDialog:SetPlayerDialogOptions(steamid, nil)
	end
end)