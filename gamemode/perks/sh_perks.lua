// RAWR!
nz.Perks.buffer = nz.Perks.buffer or {}
function nz.Perks.Add(perkData)
	perkData.OneTimeUse = perkData.OneTimeUse or true
	perkData.scale = perkData.scale or 1
	perkData.price = perkData.price or 0
	perkData.snd = perkData.snd or false
	perkData.material = perkData.material or false
	perkData.func = perkData.func or function() end
	nz.Perks.buffer[perkData.id] = perkData
end

function nz.Perks.GetAll()
	return nz.Perks.buffer
end
function nz.Perks.Get(id)
	return nz.Perks.buffer[id]
end

nz.Perks.Add({
	id = "jug",
	name = "Juggernog",
	model = "models/perkacola/jug.mdl",
	material = "mkservers/nz/perks/juggernog.png",
	scale = 1,
	price = 2000,
	snd = {"nz_juggernog", 1},
	func = (function(self, ply)
		ply:SetHealth(200)
		return true
	end),
})
nz.Perks.Add({
	id = "dtap",
	name = "Double Tap",
	model = "models/perkacola/dtap.mdl",
	material = "mkservers/nz/perks/doubletap.png",
	scale = 1,
	price = 1500,
	snd = {"nz_juggernog", 1},
	func = (function(self, ply)
		//Check if they're holding any FAS2 weps
		timer.Simple(1, function() FAS2_DTAPCOLA( ply ) end )
		return true
	end),
})
nz.Perks.Add({
	id = "speedcola",
	name = "Speed Cola",
	model = "models/perkacola/sleight.mdl",
	material = "mkservers/nz/perks/speedcola.png",
	scale = 1,
	price = 3000,
	snd = {"nz_juggernog", 1},
	func = function(self, ply)
		timer.Simple(1, function() FAS2_SPEEDCOLA( ply ) end )
		return true
	end,
})
nz.Perks.Add({
	id = "pap",
	name = "Pack A Punch",
	model = "models/perkacola/packapunch.mdl",
	scale = 1,
	price = 2000,
	snd = {"nz_juggernog", 1},
	func = (function(self, ply)
		return false
	end),
})
nz.Perks.Add({
	id = "revive",
	name = "Quick Revive",
	model = "models/perkacola/revive.mdl",
	material = "mkservers/nz/perks/quickrevive.png",
	scale = 1,
	price = 2000,
	snd = {"nz_juggernog", 1},
	func = (function(self, ply)
		return false
	end),
})