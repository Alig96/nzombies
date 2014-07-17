hook.Add("HUDPaint", "roundHUD", function()
	local text = ""
	local font = "RoundFont"
	local w = ScrW() / 2
	if nz.Rounds.CurrentState == ROUND_INIT then
		text = "Waiting for players. Type /ready to ready up."
		font = "RoundFontSmall"
	elseif nz.Rounds.CurrentState == ROUND_PREP then
		if nz.Rounds.CurrentRound != 0 then
			text = nz.Rounds.CurrentRound
		else 
			text = "1"
		end
		w = ScrW() * 0.1
	elseif nz.Rounds.CurrentState == ROUND_PROG then
		if nz.Rounds.CurrentRound != 0 then
			text = nz.Rounds.CurrentRound
		else
			text = "1"
		end
		w = ScrW() * 0.1
	elseif nz.Rounds.CurrentState == ROUND_CREATE then
		text = "Creative Mode"
	elseif nz.Rounds.CurrentState == ROUND_GO then
		text = "Game Over"
	end
	draw.SimpleText(text, font, w, ScrH() * 0.85, Color(200, 0, 0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end)

hook.Add( "HUDPaint", "scoreHUD", function()
	if nz.Rounds.CurrentState == ROUND_PREP or nz.Rounds.CurrentState == ROUND_PROG then
		for k,v in pairs(player.GetAll()) do
			if v:GetPoints() >= 0 then
				draw.SimpleText(v:Nick().." - "..v:GetPoints(), "ScoreFont", ScrW() * 0.8, ScrH() / 2 + (20*k), Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)			
			end
		end
	end
	if LocalPlayer():GetActiveWeapon():IsValid() and nz.Rounds.CurrentState == ROUND_CREATE then
		draw.SimpleText(LocalPlayer():GetActiveWeapon():GetClass(), "RoundFontSmall", ScrW() * 0.8, ScrH() - 70, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end	
end )