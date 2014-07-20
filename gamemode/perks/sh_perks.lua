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