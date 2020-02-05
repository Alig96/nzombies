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

--Possible spots players may teleport to on power generator flippage
local possibleTeleports = {
	{ --Blocked-off area teleport (otherwise inaccessible)
		{pos = Vector(0, 0, 0), ang = Angle(0, 0, 0), post = true}
	},
	{ --Basement teleport (essentially useless), 3 spots so it feels more genuinely random
		{pos = Vector(0, 0, 0), ang = Angle(0, 0, 0)},
		{pos = Vector(0, 0, 0), ang = Angle(0, 0, 0)},
		{pos = Vector(0, 0, 0), ang = Angle(0, 0, 0)}
	},
	{ --Random spots in areas that MUST have been purchased thus far (essentially useless), 3 spots again
		{pos = Vector(0, 0, 0), ang = Angle(0, 0, 0)},
		{pos = Vector(0, 0, 0), ang = Angle(0, 0, 0)},
		{pos = Vector(0, 0, 0), ang = Angle(0, 0, 0)}
	},
	{ --"Bunker" area w/ PaP
		{pos = Vector(0, 0, 0), ang = Angle(0, 0, 0), post = true}
	}
}

local spawnTeleport = {pos = Vector(0, 0, 0), ang = Angle(0, 0, 0)}

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
function SetPermaElectrify(ent, enable) 
	local function PermaElectrify(ent_)
		if not game.active then --Find the appropriate variable/function return
			return false
		end
		local effecttimer = 0
		if effecttimer < CurTime() then
			local effect = EffectData()
			effect:SetScale(1)
			effect:SetEntity(ent_)
			util.Effect("lightning_aura", effect)
			effecttimer = CurTime() + 0.5
		end
	end

	if enable then
		ent.Think = PermaElectrify --May not really work on the player class
	else
		ent.Think = function() end
	end
end

--How should the effect work? Nothing for 2 seconds then the zap? Do any of the effects follow the zombies as they move?
function ZapZombies(vec1, vec2, ply)
	EmitSound("", vec1:Cross(vec2), 1) --Zap sfx
	timer.Simple(2, function()
		for _, zom in pairs(ents.FindInBox(vec1, vec2)) do
			if zom:IsValidZombie() then
				--Do zombie effect
				timer.Simple(2, function()
					if IsValid(zom) then
						local insta = DamageInfo()
						insta:SetAttacker(ply)
						insta:SetDamageType() --Need to find an acceptable damage type, old was DMG_BLAST_SURFACE
						insta:SetDamage(zom:Health())
						zom:TakeDamageInfo(insta)
						mapscript.bloodGodKills = mapscript.bloodGodKills + 1
					end
				end)
			end
		end
	end)
end

function SpecialTeleport(ply, pos, ang, delay)
	ply:GodEnable()
	ply:Lock()
	SetPermaElectrify(ply, true)
	timer.Simple(delay or 0, function()
		--Play build-up sound
	end)

	timer.Simple(--[[buildupSoundLength]] + (delay or 0), function() --Delay the teleport for a bit to play sounds
		ply:SetNoDraw(true) --may also need to set their equipped weapons invisible
		--ply:Freeze(true)
		ply:SetPos(pos)
		ply:SetAngles(ang)
		SetPermaElectrify(ply, false)

		--Do HUD effects
		--Play sound effects

		timer.Simple(--[[fullEffectLength]] - 1.4, function()
			local effectData = EffectData()
			effectData:SetOrigin(pos)
			effectData:SetMagnitude(2)
			effectData:SetEntity(nil)
			util.Effect("lightning_prespawn", effectData)

			timer.Simple(1.4, function()
				effectData = EffectData()
				effectData:SetStart( ply:GetPos() + Vector(0, 0, 1000) )
				effectData:SetOrigin( ply:GetPos() )
				effectData:SetMagnitude( 0.75 )
				util.Effect("lightning_strike", effectData)

				ply:SetNoDraw(false)
				ply:GodDisable()
				ply:UnLock()
				timer.Simple(1, function() --We don't want the player spawning inside a zombie and not being able to move
					ply:SetCollisionGroup(COLLISION_GROUP_NONE) --TO CHECK
					timer.Simple(1, function()
						ply:SetCollisionGroup() --Change back
					end)
				end)
			end)
		end)
	end)
end

function mapscript.OnGameBegin()
    gascans:Reset()
	flashlight:Reset()
    
    --Need to lock the elevator doors & buttons here
	mapscript.bloodGodKills = 0
	local initialUse = false
	local killSwitch = ents.GetMapCreatedEntity("1556") --Non-bloody room button
	killSwitch.OnUsed = function(ply)
		if !nzElec:IsOn() or switchOneOn or switchTwoOn then
			return false
		end

		switchOneOn = true
		--Do room effect
		ZapZombies(Vector(-884.5, 3540, 64), Vector(-1200.5, 3888, 64), ply)
	end
	killSwitch = ents.GetMapCreatedEntity("1650") --Bloody room button
	killSwitch.OnUsed = function(ply)
        if !nzElec:IsOn() or switchOneOn or switchTwoOn then
			return false
		end
        
        switchTwoOn = true
        ZapZombies(Vector(11, 3540, 64), Vector(-304.5, 3888, 64), ply)
	end

	local sparkLever = ents.GetMapCreatedEntity("1921")
	sparkLever.OnUsed = function(ply)
		if !sparkFlipped then
			sparkFlipped = true
		else
			sparkFlipped = false
		end
		--Play an indicating sound
	end

	local nonSparkLever = ents.GetMapCreatedEntity("1920")
	nonSparkLever = function(ply)
		if !nonSparkFlipped then
			nonSparkFlipped = true
		else
			nonSparkFlipped = false
		end
		--Play an indicating sound
	end

	local neitherFlippedOption = table.Copy(possibleTeleports[1])
	table.remove(possibleTeleports, 1)
	local randValue = math.random(1, 3)
	local bothFlippedOption = table.Copy(possibleTeleports[randValue])
	table.remove(possibleTeleports, randValue)
	randValue = math.random(1, 2)
	local nonSparkFlippedOption = table.Copy(possibleTeleports[randValue])
	table.remove(possibleTeleports, randValue)
	local sparkFlippedOption = table.Copy(possibleTeleports[1])

	--The generator power switch that teleports the player
	newPowerSwitch = ents.GetMapCreatedEntity("2767")
	newPowerSwitch.OnUsed = function(ply)
		if nzElec:IsOn() then
			--Since a solo player may explore this area before doing anything with the EE, "punish" them instead
			--Do some effect and damage the player
		end

		local teleportAgain, randomValue = false
        if !sparkFlipped and !nonSparkFlipped then
            randomValue = math.random(#neitherFlippedOption)
			SpecialTeleport(ply, neitherFlippedOption[randomValue].pos, neitherFlippedOption[randomValue].ang, 1)
			teleportAgain = true
        elseif sparkFlipped and !nonSparkFlipped then
            randomValue = math.random(#sparkFlippedOption)
			SpecialTeleport(ply, sparkFlippedOption[randomValue].pos, sparkFlippedOption[randomValue].ang, 1)
            if sparkFlippedOption.post then
                teleportAgain = true
            end
        elseif !sparkFlipped and nonSparkFlipped then
            randomValue = math.random(#nonSparkFlippedOption)
            SpecialTeleport(ply, nonSparkFlippedOption[randomValue].pos, nonSparkFlippedOption[randomValue)].ang, 1)
            if nonSparkFlippedOption.post then
                teleportAgain = true
            end
        else
            randomValue = math.random(#bothFlippedOption)
            SpecialTeleport(ply, bothFlippedOption[randomValue].pos, bothFlippedOption[randomValue)].ang, 1)
            if bothFlippedOption.post then
                teleportAgain = true
            end
        end
        
        if teleportAgain then
            teleportTimers = teleportTimers or {}
            teleportTimers[ply:SteamID()] = 120 + math.random(-30, 30)

            timer.Create(ply:SteamID() + "TeleportTimer", 1, 0, function()
                if !teleportTimers[ply:SteamID()] or !IsValid(ply) then 
                    timer.Remove(ply:SteamID() + "TeleportTimer")
                end
                if teleportTimers[ply:SteamID()] == 0 or !ply:GetNotDowned then
                    timer.Remove(ply:SteamID() + "TeleportTimer")
                    SpecialTeleport(ply, Vector(), Angle()) --Should be back to spawn
                end
				--[[if teleportTimers[ply:SteamID()] == 10 then --or some number 
					--Do something
				end]]

				teleportTimers[ply:SteamID()] = teleportTimers[ply:SteamID()] - 1
            end)
        end
	end

    for _, ply in pairs(player.GetAll()) do
        ply:Flashlight(false)
        --ply:AllowFlashlight(false)
    end

	--Creates the 2 generators
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
	if !postFirstActivation then
		--Remove the grayscale effect here

		timer.Simple(5, function()
			--Move the power switch outside of the map and replace it with a decoy
		end)
	end

	postFirstActivation = true
end

--Need to delete the decoy power switch on game end

/*
Test Effects:
	util.Effect("lightning_prespawn", ) - Hellhound pre-spawn effect
	util.Effect("lightning_strike", ) - Hellspawn spawn effect

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
    Radio: 1456
    Camera console: 1455
    Jail door: 2778 - should auto-open on game start
    Generator to restart power: 2767
    Basement console: 2056
    Basement lever: 1920
    Basement radio: 2144
    Basement lever (sparking): 1921
*/