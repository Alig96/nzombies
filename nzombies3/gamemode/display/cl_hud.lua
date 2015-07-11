//

function nz.Display.Functions.StatesHud()
	local text = ""
	local font = "nz.display.hud.main"
	local w = ScrW() / 2
	if nz.Rounds.Data.CurrentState == ROUND_INIT then
		text = "Waiting for players. Type /ready to ready up."
		font = "nz.display.hud.small"
	elseif nz.Rounds.Data.CurrentState == ROUND_PREP then
		if nz.Rounds.Data.CurrentRound != 0 then
			text = nz.Rounds.Data.CurrentRound
		else 
			text = "1"
		end
		w = ScrW() * 0.1
	elseif nz.Rounds.Data.CurrentState == ROUND_PROG then
		if nz.Rounds.Data.CurrentRound != 0 then
			text = nz.Rounds.Data.CurrentRound
		else
			text = "1"
		end
		w = ScrW() * 0.1
	elseif nz.Rounds.Data.CurrentState == ROUND_CREATE then
		text = "Creative Mode"
	elseif nz.Rounds.Data.CurrentState == ROUND_GO then
		text = "Game Over"
	end
	draw.SimpleText(text, font, w, ScrH() * 0.85, Color(200, 0, 0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function nz.Display.Functions.ScoreHud()
	if nz.Rounds.Data.CurrentState == ROUND_PREP or nz.Rounds.Data.CurrentState == ROUND_PROG then
		for k,v in pairs(player.GetAll()) do
			if v:GetPoints() >= 0 then
				draw.SimpleText(v:Nick().." - "..v:GetPoints(), "nz.display.hud.small", ScrW() * 0.8, ScrH() / 2 + (20*k), Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)			
			end
		end
	end
	if LocalPlayer():GetActiveWeapon():IsValid() and nz.Rounds.Data.CurrentState == ROUND_CREATE then
		draw.SimpleText(LocalPlayer():GetActiveWeapon():GetClass(), "nz.display.hud.small", ScrW() * 0.8, ScrH() - 70, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end	
end

function nz.Display.Functions.PowerUpsHud()
	local font = "nz.display.hud.main"
	local w = ScrW() / 2
	local offset = 20
	local c = 0
	for k,v in pairs(nz.PowerUps.Data.ActivePowerUps) do
		if nz.PowerUps.Functions.IsPowerupActive(k) then
			local powerupData = nz.PowerUps.Functions.Get(k)
			draw.SimpleText(powerupData.name .. " - " .. math.Round(v - CurTime()), font, w, ScrH() * 0.85 + offset * c, Color(255, 255, 255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			c = c + 1
		end
	end
end

//Hooks
hook.Add("HUDPaint", "roundHUD", nz.Display.Functions.StatesHud )
hook.Add("HUDPaint", "scoreHUD", nz.Display.Functions.ScoreHud )
hook.Add("HUDPaint", "powerupHUD", nz.Display.Functions.PowerUpsHud )