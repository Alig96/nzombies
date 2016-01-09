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

local mat_revive = Material("materials/revive.png", "unlitgeneric smooth")

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
	
	--print("Color reset!")
end

function nz.Revive.Functions.CalcDownView(ply, pos, ang, fov, znear, zfar)
	if !nz.Revive.Data.Players[LocalPlayer()] then return end
	
	local pos = pos + Vector(0,0,-30)
	local ang = ang + Angle(0,0,20)
	
	return {origin = pos, angles = ang, fov = fov, znear = znear, zfar = zfar, drawviewer = false }
end

function nz.Revive.Functions.DrawColorModulation()
	if !nz.Revive.Data.Players[LocalPlayer()] then return end
	
	local fadeadd = ((1/nz.Config.DownTime) * FrameTime()) * -1 	//Change 45 to the revival time
	tab[ "$pp_colour_colour" ] = math.Approach(tab[ "$pp_colour_colour" ], 0, fadeadd)
	tab[ "$pp_colour_brightness" ] = math.Approach(tab[ "$pp_colour_brightness" ], -0.5, fadeadd * 0.5)
	
	--print(fadeadd, tab[ "$pp_colour_colour" ], tab[ "$pp_colour_brightness" ]) 
	DrawColorModify(tab)
end

function surface.DrawTexturedRectRotatedPoint( x, y, w, h, rot, x0, y0 )

	local c = math.cos( math.rad( rot ) )
	local s = math.sin( math.rad( rot ) )

	local newx = y0 * s - x0 * c
	local newy = y0 * c + x0 * s

	surface.DrawTexturedRectRotated( x + newx, y + newy, w, h, rot )

end

function nz.Revive.Functions.DrawDownedPlayers()
	local font = "nz.display.hud.main"
	local font2 = "nz.display.hud.small"
	
	for k,v in pairs(nz.Revive.Data.Players) do
		local posxy = (k:GetPos() + Vector(0,0,35)):ToScreen()
		local dir = ((k:GetPos() + Vector(0,0,35)) - EyeVector()*2):GetNormal():ToScreen()
		--print(posxy["x"], posxy["y"], posxy["visible"])
		
		--[[if posxy.x - 35 < 60 or posxy.x - 35 > ScrW()-130 or posxy.y - 50 < 60 or posxy.y - 50 > ScrH()-110 then
			//Draw arrow pointing there
			local dirang = math.deg(math.atan2(posxy.x - 35, posxy.y - 50))
			
			//Not very accurate?
			draw.NoTexture()
			surface.SetDrawColor(255, 200, 100)
			surface.DrawTexturedRectRotatedPoint(math.Clamp(posxy.x - 35, 60, ScrW()-130), math.Clamp(posxy.y - 50, 60, ScrH()-110), 5, 30, dirang - 45, 0, -15)
			surface.DrawTexturedRectRotatedPoint(math.Clamp(posxy.x - 35, 60, ScrW()-130), math.Clamp(posxy.y - 50, 60, ScrH()-110), 5, 30, dirang + 45, 0, 15)
			
			--LocalPlayer():ChatPrint(dirang)
			--surface.DrawTexturedRect( (ScrW()/2) - math.cos(dirang)*(ScrW()/2), (ScrH()/2) - math.sin(dirang)*(ScrH()/2), 70, 50)
		end]]
		//Not very accurate - if anyone knows how to work 3D to 2D with directional pointers let me know
		
		surface.SetMaterial(mat_revive)
		if v.ReviveTime then
			surface.SetDrawColor(255, 255, 255)
		else
			surface.SetDrawColor(255, 150 - (CurTime() - v.DownTime)*(150/nz.Config.DownTime), 0)
		end
		
		--draw.SimpleText(v.ReviveTime and "REVIVING" or "DOWNED", font, posxy["x"], posxy["y"] + 10, v.ReviveTime and Color(255,255,255) or Color(200, 0, 0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		--draw.SimpleText(k:Nick(), font2, posxy["x"], posxy["y"] - 20, v.ReviveTime and Color(255,255,255) or Color(200, 0, 0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		surface.DrawTexturedRect(math.Clamp(posxy.x - 35, 60, ScrW()-130), math.Clamp(posxy.y - 50, 60, ScrH()-110), 70, 50)
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

function nz.Revive.Functions.DownedHeadsUp(ply, wasrevived)
	nz.Revive.Data.Notify[ply] = {time = CurTime(), revive = wasrevived}
end

function nz.Revive.Functions.DrawDownedHeadsUp()
	local font = "nz.display.hud.small"
	local h = 40
	local offset = 20
	local max = 2
	local c = 0
	--table.SortByMember(nz.Revive.Data.Notify, "time")
	
	for k,v in pairs(nz.Revive.Data.Notify) do
		local fade = math.Clamp(CurTime() - v.time - 5, 0, 1)
		draw.SimpleText(v.revive and k:Nick().." has been revived!" or k:Nick().." needs to be revived!", font, ScrW()/2, ScrH() - h - offset * c, Color(255, 255, 255,255-(255*fade)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		if fade >= 1 then nz.Revive.Data.Notify[k] = nil end
		c = c + 1
	end
end

//Hooks
hook.Add("CalcView", "CalcDownedView", nz.Revive.Functions.CalcDownView )
hook.Add("RenderScreenspaceEffects", "DrawColorModulation", nz.Revive.Functions.DrawColorModulation)
hook.Add("HUDPaint", "DrawDownedPlayers", nz.Revive.Functions.DrawDownedPlayers )
hook.Add("HUDPaint", "DrawDownedPlayersNotify", nz.Revive.Functions.DrawDownedHeadsUp )