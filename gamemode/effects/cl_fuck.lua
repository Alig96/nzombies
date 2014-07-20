// RAWR!
net.Receive("nz_Effects_Sound", function()
	nz.Rounds.Effects.Sound(net.ReadString())
end)

function nz.Rounds.Effects.Sound(snd)
	playSound = CreateSound(LocalPlayer(), snd)
	playSound:Play()
end