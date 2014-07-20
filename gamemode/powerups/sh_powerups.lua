// RAWR!
nz.PowerUps.buffer = nz.PowerUps.buffer or {}
nz.PowerUps.data = nz.PowerUps.data or {}
function nz.PowerUps.Add(powerData)
	powerData.snd = powerData.snd or false
	powerData.effect = powerData.effect or {}
	powerData.effect.time = powerData.effect.time or 0
	powerData.effect.material = powerData.effect.material or false
	nz.PowerUps.buffer[powerData.id] = powerData
	if (SERVER) then
		nz.PowerUps.Set(powerData.id, false, powerData.effect.time, powerData.name, powerData.effect.material)
	end
end

function nz.PowerUps.GetBufferAll()
	return nz.PowerUps.buffer
end

function nz.PowerUps.GetBuffer(id)
	return nz.PowerUps.buffer[id]
end

function nz.PowerUps.GetAll()
	return nz.PowerUps.data
end

function nz.PowerUps.Get(id)
	return nz.PowerUps.data[id]
end