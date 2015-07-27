//
local tab = {
 [ "$pp_colour_addr" ] = 0,
 [ "$pp_colour_addg" ] = 0,
 [ "$pp_colour_addb" ] = 0,
 [ "$pp_colour_brightness" ] = 0,
 [ "$pp_colour_contrast" ] = 1,
 [ "$pp_colour_colour" ] = 1,
 [ "$pp_colour_mulr" ] = 0,
 [ "$pp_colour_mulg" ] = 0,
 [ "$pp_colour_mulb" ] = 0
}
local fade = 1

function nz.Revive.Functions.ResetColorFade()
	tab = {
		 [ "$pp_colour_addr" ] = 0,
		 [ "$pp_colour_addg" ] = 0,
		 [ "$pp_colour_addb" ] = 0,
		 [ "$pp_colour_brightness" ] = 0,
		 [ "$pp_colour_contrast" ] = 1,
		 [ "$pp_colour_colour" ] = 1,
		 [ "$pp_colour_mulr" ] = 0,
		 [ "$pp_colour_mulg" ] = 0,
		 [ "$pp_colour_mulb" ] = 0
	}
	fade = 1
	
	print("Color reset!")
end

function nz.Revive.Functions.CalcDownView(ply, pos, ang, fov, znear, zfar)
	if !nz.Revive.Data.Players[LocalPlayer()] then return end
	
	local pos = pos + Vector(0,0,-30)
	local ang = ang + Angle(0,0,20)
	
	return {origin = pos, angles = ang, fov = fov, znear = znear, zfar = zfar, drawviewer = false }
end

function nz.Revive.Functions.DrawColorModulation()
	if !nz.Revive.Data.Players[LocalPlayer()] then return end
	
	local fadeadd = ((1/45) * FrameTime()) * -1 	//Change 45 to the revival time
	tab[ "$pp_colour_colour" ] = math.Approach(tab[ "$pp_colour_colour" ], 0, fadeadd)
	tab[ "$pp_colour_brightness" ] = math.Approach(tab[ "$pp_colour_brightness" ], -0.5, fadeadd * 0.5)
	
	--print(fadeadd, tab[ "$pp_colour_colour" ], tab[ "$pp_colour_brightness" ]) 
	DrawColorModify(tab)
end

function nz.Revive.Functions.DrawDownedPlayers()
	local font = "nz.display.hud.main"
	local font2 = "nz.display.hud.small"
	
	for k,v in pairs(nz.Revive.Data.Players) do
		local posxy = (k:GetPos() + Vector(0,0,50)):ToScreen()
		--print(posxy["x"], posxy["y"], posxy["visible"])
		if posxy["visible"] then
			draw.SimpleText(v.ReviveTime and "REVIVING" or "DOWNED", font, posxy["x"], posxy["y"] + 10, v.ReviveTime and Color(255,255,255) or Color(200, 0, 0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			draw.SimpleText(k:Nick(), font2, posxy["x"], posxy["y"] - 20, v.ReviveTime and Color(255,255,255) or Color(200, 0, 0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end
	end
end

function nz.Revive.Functions.DrawDownedNotify()

	if !LocalPlayer():GetNotDowned() then
		local text = "YOU NEED HELP!"
		local font = "nz.display.hud.main"
		local rply = nz.Revive.Data.Players[LocalPlayer()].RevivePlayer
		
		if IsValid(rply) and rply:IsPlayer() then
			text = rply:Nick().." is reviving you!"
		end
		draw.SimpleText(text, font, ScrW() / 2, ScrH() * 0.85, Color(200, 0, 0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

end

//Hooks
hook.Add("CalcView", "CalcDownedView", nz.Revive.Functions.CalcDownView )
hook.Add("RenderScreenspaceEffects", "DrawColorModulation", nz.Revive.Functions.DrawColorModulation)
hook.Add("HUDPaint", "DrawDownedPlayers", nz.Revive.Functions.DrawDownedPlayers )