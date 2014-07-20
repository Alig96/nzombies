// RAWR!
util.AddNetworkString("nz_Effects_Sound")
function nz.Rounds.Effects.Sound(str)
	net.Start("nz_Effects_Sound")
		net.WriteString(str)
	net.Broadcast()
end