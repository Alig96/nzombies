// RAWR!
function nz.PowerUps.Activate(id, ent, ply)
	local powerData = nz.PowerUps.GetBuffer(id)
	if (powerData.snd) then
		nz.PowerUps.Sound(powerData.snd[1])
	end
	if (!powerData&&!powerData.bool) then
		powerData.func(ent, ply)
		nz.PowerUps.Set(id, true)
		PrintMessage(HUD_PRINTTALK, "[NZ] "..powerData.name.." has begun!")
	end
	if (powerData.effect.time==0) then
		powerData.func(ent, ply)
		PrintMessage(HUD_PRINTTALK, "[NZ] "..powerData.name.."!")
	elseif (powerData.time!=-1) then
		if (timer.Exists(id)) then
			timer.Destroy(id)
		end
		timer.Create(id, 0, powerData.time, function()
			nz.PowerUps.Set(id, false)
			PrintMessage(HUD_PRINTTALK, "[NZ] "..powerData.name.." has ended!")
		end)
	end
	ent:Remove()
end

util.AddNetworkString("nz_PowerUps_Sync")
util.AddNetworkString("nz_PowerUps_Sound")
function nz.PowerUps.Set(id, bool, time)
	local data = table.Copy(nz.PowerUps.Get(id) or {})
	data.id = id
	data.bool = bool
	data.time = time or data.time or -1
	nz.PowerUps.data[id] = data
	net.Start("nz_PowerUps_Sync")
		net.WriteString(id)
		net.WriteTable(data)
	net.Broadcast()
end

function nz.PowerUps.Sound(path)
	net.Start("nz_PowerUps_Sound")
		net.WriteString(path)
	net.Broadcast()
end