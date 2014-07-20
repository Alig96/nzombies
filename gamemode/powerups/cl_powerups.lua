// RAWR!
local playSound = nil
net.Receive("nz_PowerUps_Sync", function()
	local id = net.ReadString()
	local data = net.ReadTable()
	data.bool = tobool(data.bool)
	nz.PowerUps.data[id] = data
end)

net.Receive("nz_PowerUps_Sound", function()
	local snd = net.ReadString()
	playSound = CreateSound(LocalPlayer(), snd)
	playSound:Play()
end)