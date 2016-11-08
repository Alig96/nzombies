
if SERVER then

	nzEE.Major.Steps = nzEE.Major.Steps or {}
	nzEE.Major.CurrentStep = nzEE.Major.CurrentStep or 1

	function nzEE.Major:AddStep(func, step)
		if step and tonumber(step) then
			nzEE.Major.Steps[step] = func
		else
			table.insert(nzEE.Major.Steps, func)
		end
	end

	function nzEE.Major:SetCurrentStep(step)
		nzEE.Major.CurrentStep = step
	end

	function nzEE.Major:CompleteStep(step, ...)
		if nzEE.Major.CurrentStep == step then
			if nzEE.Major.Steps[step] then
				print("Completed step "..step)
				local args = {...}
				nzEE.Major.Steps[step](args) -- Varargs passable if you call Complete Step with more stuff
			end
			nzEE.Major.CurrentStep = nzEE.Major.CurrentStep + 1
		end
	end
	
	util.AddNetworkString("nzMajorEEEndScreen")
	
	function nzEE.Major:Reset()
		nzEE.Major.CurrentStep = 1
	end
	
	function nzEE.Major:Cleanup()
		nzEE.Major.CurrentStep = 1
		nzEE.Major.Steps = {}
	end

end

if CLIENT then

	local function ShowWinScreen()
		local easteregg = net.ReadBool()
		local win = net.ReadBool()
		local msg = net.ReadString()
		local camtime = net.ReadFloat()
		local time = CurTime() + camtime
		local endcam = net.ReadBool()
		
		local startpos, endpos
		if endcam then
			startpos = net.ReadVector()
			endpos = net.ReadVector()
		end
		
		local w = ScrW() / 2
		local h = ScrH() / 2
		local font = "DermaLarge"
		
		if startpos and endpos and time then
			local dir = endpos - startpos
			local ang = dir:Angle()
			hook.Add("CalcView", "nzCalcEndCameraView", function(ply, origin, angles, fov, znear, zfar)
				if time < CurTime() then
					hook.Remove("CalcView", "nzCalcEndCameraView")
				end
				
				local delta = math.Clamp((time-CurTime())/camtime, 0, 1)
				local pos = endpos - dir*delta
				
				return {origin = pos, angles = ang, drawviewer = true}
			end)
			hook.Add("CalcViewModelView", "nzCalcEndCameraView", function(wep, vm, oldpos, oldang, pos, ang)
				if time < CurTime() then
					hook.Remove("CalcViewModelView", "nzCalcEndCameraView")
				end
				
				return oldpos - ang:Forward()*50, ang
			end)
		end
		
		hook.Add("HUDPaint", "nzDrawEEEndScreen", function()
			draw.SimpleText(msg, font, w, h, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			if time < CurTime() then
				hook.Remove("HUDPaint", "nzDrawEEEndScreen")
			end
		end)
		
		if easteregg then
			if win then
				surface.PlaySound(GetGlobalString("winmusic", "nz/easteregg/motd_standard.wav"), 21)
			else
				surface.PlaySound(GetGlobalString("losemusic", "nz/round/game_over_4.mp3"), 21)
			end
		end
	end
	net.Receive("nzMajorEEEndScreen", ShowWinScreen)


end