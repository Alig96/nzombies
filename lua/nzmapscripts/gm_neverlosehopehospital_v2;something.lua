local mapscript = {}

//The gas cans used to fill the generators, 2 cans per generator
//lua_run print(Entity(1):GetEyeTrace().Entity:GetPos())
local gascanspawns = {
    { --Can 1, found around the power rooms
        {pos = Vector(-213.891785 2372.032959 15.332347), ang = Angle(0, -90, 0)},
        {pos = Vector(-114.092148 2931.946777 14.76), ang = Angle(-36, -98.5, 0)},
        {pos = Vector(-1923.289063 3534.208740 15.263), ang = Angle(0, 106, 0)}
    }
    { --Can 2, found in the bathroom & beyond areas
        {pos = Vector(-3972.647949 2598.693848 15.330338), ang = Angle(0, -180, 0)},
        {pos = Vector(-5784.763184 2332.365723 260.4929), ang = Angle(-89.5, -146, -57.5)},
        {pos = Vector(-5627.165039 2128.645020 15.2646), ang = Angle(0, 0, 0)}
    }
    { --Can 3, found in the tiled corridors after the long hallways
        {pos = Vector(-3958.973145 4838.710938 79.33548), ang = Angle(0, 0, 0)},
        {pos = Vector(-6857.171875 9401.148438 79.33123), ang = Angle(0, 85.5, 0)},
        {pos = Vector(-6239.565430 7497.475586 79.300950), ang = Angle(0, 178, 0)}
    }
    { --Can 4, found in the hospital wing after the tiled corridors
        {pos = Vector(-5547.892090 10435.421875 79.27690), ang = Angle(0, 82, 0)},
        {pos = Vector(-6529.118652 9991.431641 83.4996), ang = Angle(26, -109, 0)},
        {pos = Vector(-4294.641602 10248.747070 79.1447), ang = Angle(-32.5, 136.5, 0)}
    }
}

local poweredgenerators = {}
local generators = {
    {pos = Vector(-2241.5, 1219.5, 27.5), ang = Angle(0, -180, 0)},
    {pos = Vector(-2723, 1790, 27.5), ang = Angle(0, -90, 0)}
}

--The "pile" of flashlights
local flashlights = {
	{	
		{pos = Vector(0, 0, 0), ang = Angle(0, 0, 0)},
		{pos = Vector(0, 0, 0), ang = Angle(0, 0, 0)},
		{pos = Vector(0, 0, 0), ang = Angle(0, 0, 0)}
	},
	{	
		{pos = Vector(0, 0, 0), ang = Angle(0, 0, 0)},
		{pos = Vector(0, 0, 0), ang = Angle(0, 0, 0)},
		{pos = Vector(0, 0, 0), ang = Angle(0, 0, 0)}
	},
	{	
		{pos = Vector(0, 0, 0), ang = Angle(0, 0, 0)},
		{pos = Vector(0, 0, 0), ang = Angle(0, 0, 0)},
		{pos = Vector(0, 0, 0), ang = Angle(0, 0, 0)}
	}
}

local gascans = nzItemCarry:CreateCategory("gascan")
gascans:SetIcon("spawnicons/models/props_junk/metalgascan.png") --spawnicons/models/props_junk/gascan001a.png
gascans:SetText("Press E to pick up the gas can.")
gascans:SetDropOnDowned(false)
gascans:SetShowNotification(true)
gascans:SetResetFunction(function(self)
	for num, tab in pairs(gascanspawns) do
        subtab = tab[math.random(1, #tab)]
		if tab.ent then
			tab.ent:Remove()
		end
		local ent = ents.Create("nz_script_prop")
		ent:SetModel("models/props_junk/metalgascan.mdl")
		ent:SetPos(subtab.pos)
		ent:SetAngles(subtab.ang)
		ent:Spawn()
		tab.ent = ent
		self:RegisterEntity(ent)
	end
end)
gascans:SetDropFunction(function(self, ply )
    --Must keep track of held & dropped gas cans, so on map reset the gas cans are removed properly
	for num, tab in pairs(gascanspawns) do
		if tab.held == ply then
			local ent = ents.Create("nz_script_prop")
			ent:SetModel("models/props_junk/metalgascan.mdl")
			ent:SetPos(ply:GetPos())
			ent:SetAngles(Angle(0, 0, 0))
			ent:Spawn()
			ent:DropToFloor()
			ply:RemoveCarryItem("gascan")
			tab.held = nil
			ply.ent = nil
			self:RegisterEntity(ent)
			break
		end
	end
end)
gascans:SetPickupFunction(function(self, ply, ent)
	for num, tab in pairs(gascanspawns) do
		if tab.ent == ent then
			ply:GiveCarryItem(self.id)
			ent:Remove()
			tab.held = ply
			ply.ent = ent
			break
		end
	end
end)
gascans:SetCondition( function(self, ply)
	return !ply:HasCarryItem("gascan")
end)
gascans:Update()

local flashlight = nzItemCarry:CreateCategory("gascan")
flashlight:SetIcon("spawnicons/") --To set
flashlight:SetText("Press E to pick up a flashlight.")
flashlight:SetDropOnDowned(false)
flashlight:SetShowNotification(true)
flashlight:SetResetFunction(function(self)
	if flashlights.spawned then
		for _, ent in pairs(flashlights.spawned) do
			ent:Remove()
			flashlights.spawned[_] = nil
		end
	end

	for _, info in pairs(flashlights[math.random(1, #flashlights)]) do
		local ent = ents.Create("nz_script_prop")
		ent:SetModel("") --To set
		ent:SetPos(info.pos)
		ent:SetAngles(info.ang)
		ent:Spawn()
		flashlights.spawned = flashlights.spawned or {}
		flashlights.spawned[#flashlights.spawned + 1] = ent
		self:RegisterEntity(ent)
	end
end)
flashlight:SetPickupFunction(function(self, ply, ent)
	ply:GiveCarryItem(self.id)
	ply:Flashlight(true)
end)
flashlight:SetCondition( function(self, ply)
	return !ply:HasCarryItem("flashlight")
end)
flashlight:Update()

--//Creates the lightning aura once around the given ent
function Electrify(ent)
	local effect = EffectData()
	effect:SetScale(1)
	effect:SetEntity(ent)
	util.Effect("lightning_aura", effect)
end

--//Creates a never-ending lightning aura around the given ent
function SetPermaElectrify(penis) 
	local function PermaElectrify(ent)
		if not game.active then --Find the appropriate variable/function return
			return false
		end
		local effecttimer = 0
		if effecttimer < CurTime() then
			local effect = EffectData()
			effect:SetScale(1)
			effect:SetEntity(ent)
			util.Effect("lightning_aura", effect)
			effecttimer = CurTime() + 0.5
		end
	end
	penis.Think = PermaElectrify
end

function mapscript.OnGameBegin()
    gascans:Reset()
	flashlight:Reset()
    
    --Need to lock the elevator doors & buttons here

    for _, ply in pairs(player.GetAll()) do
        ply:Flashlight(false)
        --ply:AllowFlashlight(false)
    end

	//Creates the 2 generators
    for num, tab in pairs(generators) do
		poweredgenerators[num] = false
		local gen = ents.Create("nz_script_prop")
		gen:SetPos(tab.pos)
		gen:SetAngles(tab.ang)
		gen:SetModel("models/props_wasteland/laundry_washer003.mdl")
		gen:SetNWString("NZText", "You must fill this generator with gasoline to power it.")
		gen:SetNWString("NZRequiredItem", "gascan")
		gen:SetNWString("NZHasText", "Press E to fuel this generator with gasoline.")
		gen:Spawn()
		gen:Activate()
		gen.OnUsed = function(self, ply)
			if ply:HasCarryItem("gascan") and not poweredgenerators[num] and not delay then
                local delay = true
				local halffilled = false

				for num, tab in pairs(gascanspawns) do
					if tab == ply.ent then
						tab.used = true
						tab.held = false
						continue
					end
				end

                delay = true
                gen:SetNWString("NZText", "")
                gen:SetNWString("NZHasText", "")

				--Plays the generator fueling and generator humming sounds
				timer.Simple(4, function()
					if not gen then return end
                    delay = false

                    if halffilled then
                        poweredgenerators[num] = true
                        gen:SetNWString("NZText", "This generator is powered on.")
                        gen:SetNWString("NZHasText", "This generator has already been fueled.")
                        gen:EmitSound("player/items/gas_can_fill_pour_01.wav") --gen:EmitSound( "l4d2/gas_pour.wav" )

						if k == 1 then //The first generator leads to the PaP area

						else //The second genereator leads to more of the playable area

						end
	
						timer.Simple(4, function()
							gen:EmitSound("level/generator_start_loop.wav")
							timer.Simple(9, function()
								timer.Create("Gen" .. num, 3, 0, function()
									if not gen then return end
									gen:EmitSound("l4d2/generator_humm.ogg")
								end)
							end)
						end)
                    else
                        halffilled = true
                        ply:RemoveCarryItem("gascan")
                        gen:EmitSound("player/items/gas_can_fill_pour_01.wav")
						gen:SetNWString("NZText", "You must fill this generator with gasoline to power it.")
						gen:SetNWString("NZHasText", "Press E to fuel this generator with gasoline.")
                    end
				end)
			end
		end
		gen.Think = function()
			--If a new script is loaded, destory the generator humming sounds
			if not poweredgenerators[num] and timer.Exists("Gen" .. num) then
				timer.Destroy("Gen" .. num)
			end
		end
	end


end

function mapscript.ElectricityOn()
	--Remove the grayscale effect here
end

/*
Test Effects:
	util.Effect("lightning_prespawn", )
	util.Effect("lightning_strike", )

Puzzle Ideas:
	- Melee some object? Imprisoned incorporated a custom melee weapon that can melee objects in the map
	- Some kind of passcode in a keypad
	- Blood for the blood god
			Use the "power wing buttons" to electrify and kill a certain # of zombies
			Power must be on, running the button shuts off the power
				Normal power lever is still flipped, must turn power back on by flipping the generator switch
					Generator switch will teleport the player to the inaccessible area for some length of time
					then back to spawn - this inaccessible area has PaP & maybe other EE steps
					Maybe under certain conditions it teleports to bunker area
	- Messages should hint at easter egg steps, using chalk effect from wallbuys
	- Simple key & lock puzzle?
	- 

Useful EE function:
	nzNotifications:PlaySound("")
	nzRound:Freeze(true) --Prevents switching and spawning

Entity IDs:
Power wing buttons:	- 1556
					- 1650 (bloody room)


*/