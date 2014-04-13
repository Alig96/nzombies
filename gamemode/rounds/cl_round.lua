net.Receive( "bnpvbWJpZXM_Round_Sync", function( length )
	ROUND_STATE = tonumber(net.ReadString())
	ROUND_NUMBER = tonumber(net.ReadString())
	PLAYER_COLOURS = net.ReadTable()
end )

//ROUND_INIT = 0
//ROUND_PREP = 1
//ROUND_PROG = 2
//ROUND_CREATE = 3
//ROUND_GO = 4

hook.Add("HUDPaint", "roundHUD", function()
	local text = ""
	local font = "RoundFont"
	local w = ScrW() / 2
	if ROUND_STATE == ROUND_INIT then
		text = "Waiting for players. Type /ready to ready up."
		font = "RoundFontSmall"
	elseif ROUND_STATE == ROUND_PREP then
		if ROUND_NUMBER != 0 then
			text = ROUND_NUMBER
		else 
			text = "1"
		end
		w = ScrW() / 2
	elseif ROUND_STATE == ROUND_PROG then
		if ROUND_NUMBER != 0 then
			text = ROUND_NUMBER
		else
			text = "1"
		end
		w = ScrW() / 2
	elseif ROUND_STATE == ROUND_CREATE then
		text = "Creative Mode"
	elseif ROUND_STATE == ROUND_GO then
		text = "Game Over"
	end
	draw.SimpleText(text, font, w, ScrH() * 0.85, Color(200, 0, 0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end)

hook.Add( "HUDPaint", "scoreHUD", function()
	if ROUND_STATE == ROUND_PREP or ROUND_STATE == ROUND_PROG then
		for k,v in pairs(player.GetAll()) do
			if v:GetPoints() > 0 then
				draw.SimpleText(v:Nick().." - "..v:GetPoints(), "ScoreFont", ScrW() * 0.8, ScrH() / 2 + (20*k), PLAYER_COLOURS[v], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)			
			end
		end
	end
	if LocalPlayer():GetActiveWeapon():IsValid() and ROUND_STATE == ROUND_CREATE then
		draw.SimpleText(LocalPlayer():GetActiveWeapon():GetClass(), "RoundFontSmall", ScrW() * 0.8, ScrH() - 70, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end	
end )

