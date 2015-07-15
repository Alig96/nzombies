//

function nz.Perks.Functions.NewPerk(id, data)
	if SERVER then
		//Sanitise any client data.
	else
		data.Func = nil
	end
	nz.Perks.Data[id] = data
end

function nz.Perks.Functions.Get(id)
	return nz.Perks.Data[id]
end

function nz.Perks.Functions.GetList()
	local tbl = {}
	
	for k,v in pairs(nz.Perks.Data) do
		tbl[k] = v.name
	end
	
	return tbl
end

nz.Perks.Functions.NewPerk("jugg", {
	name = "Juggernog",
	off_model = "models/alig96/perks/jugg/jugg_off.mdl",
	on_model = "models/alig96/perks/jugg/jugg_on.mdl",
	price = 100,
	func = function(self, ply)
			ply:SetMaxHealth(200)
			ply:SetHealth(200)
			return true
	end,
})

nz.Perks.Functions.NewPerk("dtap", {
	name = "Double Tap",
	off_model = "models/alig96/perks/doubletap/doubletap_off.mdl",
	on_model = "models/alig96/perks/doubletap/doubletap_on.mdl",
	price = 100,
	func = function(self, ply)
			print(self)
			print("This perk doesn't have any functionality yet.")
			return false
	end,
})

nz.Perks.Functions.NewPerk("revive", {
	name = "Quick Revive",
	off_model = "models/alig96/perks/revive/revive_off.mdl",
	on_model = "models/alig96/perks/revive/revive_on.mdl",
	price = 100,
	func = function(self, ply)
			print(self)
			print("This perk doesn't have any functionality yet.")
			return false
	end,
})

nz.Perks.Functions.NewPerk("sleight", {
	name = "Sleight of Hand",
	off_model = "models/alig96/perks/sleight/sleight_off.mdl",
	on_model = "models/alig96/perks/sleight/sleight_on.mdl",
	price = 100,
	func = function(self, ply)
			print(self)
			print("This perk doesn't have any functionality yet.")
			return false
	end,
})

nz.Perks.Functions.NewPerk("pap", {
	name = "Pack-a-Punch",
	off_model = "models/alig96/perks/sleight/sleight_off.mdl", //Find a new model.
	on_model = "models/alig96/perks/sleight/sleight_on.mdl",
	price = 100,
	func = function(self, ply)
			print(self)
			print("This perk doesn't have any functionality yet.")
			return false
	end,
})