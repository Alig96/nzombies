util.AddNetworkString("RunFireOverlay")
util.AddNetworkString("RunTeleportOverlay")
util.AddNetworkString("StopOverlay")
util.AddNetworkString("StartBloodCount")
util.AddNetworkString("UpdateBloodCount")
util.AddNetworkString("SendBatteryLevel")

local mapscript = {}
mapscript.bloodGodKills = 0
mapscript.bloodGodKillsGoal = 30
mapscript.batteryLevels = {}
mapscript.flashlightStatuses = {}

--The gas cans used to fill the generators, 2 cans per generator
--lua_run print(Entity(1):GetEyeTrace().Entity:GetPos())
local gascanspawns = {
    { --Can 1, found around the power rooms
        {pos = Vector(-214, 2372, 15), ang = Angle(0, -90, 0)},
        {pos = Vector(-114, 2932, 14.75), ang = Angle(-36, -98.5, 0)},
        {pos = Vector(-1923.25, 3534.25, 15.25), ang = Angle(0, 106, 0)}
    },
    { --Can 2, found in the bathroom & beyond areas
        {pos = Vector(-3972.647949, 2598.693848, 15.330338), ang = Angle(0, -180, 0)},
        {pos = Vector(-5784.763184, 2332.365723, 260.4929), ang = Angle(-89.5, -146, -57.5)},
        {pos = Vector(-5627.165039, 2128.645020, 15.2646), ang = Angle(0, 0, 0)}
    },
    { --Can 3, found in the tiled corridors after the long hallways
        {pos = Vector(-3959, 4838.75, 79), ang = Angle(0, 0, 0)},
        {pos = Vector(-6857, 9401, 79.3), ang = Angle(0, 85.5, 0)},
        {pos = Vector(-6239.5, 7497.5, 79.3), ang = Angle(0, 178, 0)}
    },
    { --Can 4, found in the hospital wing after the tiled corridors
        {pos = Vector(-5548, 10435.5, 79.25), ang = Angle(0, 82, 0)},
        {pos = Vector(-6529, 9991.5, 83.5), ang = Angle(26, -109, 0)},
        {pos = Vector(-4294.5, 10248.75, 797), ang = Angle(-32.5, 136.5, 0)}
    }
}

local poweredgenerators = {}
local generators = {
    {pos = Vector(-2241.5, 1219.5, 27.5), ang = Angle(0, -180, 0)},
    {pos = Vector(-2723, 1790, 27.5), ang = Angle(0, -90, 0)}
}

--Batteries
local batteries = {
	{pos = Vector(), ang = Angle()},
	{pos = Vector(), ang = Angle()},
	{pos = Vector(), ang = Angle()},
	{pos = Vector(), ang = Angle()},
	{pos = Vector(), ang = Angle()},
	{pos = Vector(), ang = Angle()},
	{pos = Vector(), ang = Angle()},
	{pos = Vector(), ang = Angle()}
}

--Possible spots players may teleport to on power generator flippage
local possibleTeleports = {
    { --Blocked-off area teleport (otherwise inaccessible)
      --Must default to this when neither switch has been flipped, so the player isn't teleported outside a purchased area
		{pos = Vector(-6751.75, 3268.5, 0), ang = Angle(0, -1800, 0), post = true}
	},
	{ --Basement teleport (essentially useless), 3 spots so it feels more genuinely random
		{pos = Vector(-3064, 195, -3580), ang = Angle(0, -180, 0)},
		{pos = Vector(-5082, 724, -3582), ang = Angle(3.5 -17.5, 0)},
		{pos = Vector(-3604, 2306.5 -3584), ang = Angle(0, -90, 0)}
	},
	{ --Random spots in areas that MUST have been purchased thus far (essentially useless), 3 spots again
		{pos = Vector(-5963.5, 2369, -61.5), ang = Angle(0, 0, 0)},
		{pos = Vector(-1825.5, 3709.75, 0.0), ang = Angle(0, -7.5, 0)},
		{pos = Vector(-3007.5, 512.5, 0.0), ang = Angle(0, -90, 0)}
	},
	{ --"Bunker" area w/ PaP
		{pos = Vector(-2844.5, 297, -1663), ang = Angle(0, 0, 0), post = true}
	}
}
local spawnTeleport = {pos = Vector(-2232, -1028, 2.75), ang = Angle(0, 106.75, 0)}

local zapRoomEffectLocations = {
    {
        {start = Vector(-1216.6, 3552.3, 0), origin = Vector(-1071.4, 3774.0, 192.0)},
        {start = Vector(-1129.4, 3564.2, 61.4), origin = Vector(-863.7, 3625.4, 54.7)},
        {start = Vector(-925.9, 3898.5, 0), origin = Vector(-986.9, 3524.3, 123)},
        {start = Vector(-1056.8, 3771.4, 45.7), origin = Vector(-1075.7, 3552.3, 47.3)},
        {start = Vector(-1131.1, 3552.6, 45.0), origin = Vector(-1011.8, 3787.6, 0)},
        {start = Vector(-864.7, 3560.9, 119.2), origin = Vector(-1216.6, 3633.6, 10.5)},
        {start = Vector(-864.7, 3882.1, 111.6), origin = Vector(-997.4, 3552.3, 49.4)},
        {start = Vector(-1099.2, 3680.8, 192.0), origin = Vector(-864.7, 3749.5, 5.0)}
    },
    {}
}
for k, v in pairs(zapRoomEffectLocations[1]) do
    zapRoomEffectLocations[2][k] = {start = v.start + Vector(895.97, 0, 0), origin = v.origin + Vector(895.97, 0, 0)}
end

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

local battery = nzItemCarry:CreateCategory("battery")
battery:SetIcon("spawnicons/zworld_equipment/.png")
battery:SetText("Press E to pick up a battery.")
battery:SetDropOnDowned(false)
battery:SetShowNotification(true)
battery:SetResetFunction(function(self)
	--[[if batteries.spawned then
		for _, ent in pairs(batteries.spawned) do
			ent:Remove()
			batteries.spawned[_] = nil
		end
	end]]

	for _, info in pairs(batteries) do
		--[[local ent = ents.Create("nz_script_prop")
		ent:SetModel("zworld_equipment/.mdl")
		ent:SetPos(info.pos)
		ent:SetAngles(info.ang)
		ent:Spawn()
		ent.charge = math.random(50, 100)
		batteries.spawned[#batteries.spawned + 1] = ent
		info.spawned = true
		self:RegisterEntity(ent)]]
		if info.ent and info.spawned then
			info.ent:Remove()
			info.spawned = false
		end
	end
end)
battery:SetPickupFunction(function(self, ply, ent)
	ply:GiveCarryItem(self.id)
    ply:AllowFlashlight(true)
    mapscript.flashlightStatuses[ply] = true
	mapscript.batteryLevels[ply:SteamID()] = math.Clamp(mapscript.batteryLevels[ply:SteamID()] + ent.charge, 0, 100)
	
	for k, v in pairs(batteries) do
		if v.ent == ent then
			ent:Remove()
			v.spawned = false
			break
		end
	end
end)
battery:SetCondition( function(self, ply)
	return (!ply:HasCarryItem("battery") or mapscript.batteryLevels[ply:SteamID()] < 100)
end)
battery:Update()

--//Creates the lightning aura once around the given ent (lasts 0.5 seconds, approximately)
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

function ZapZombies(id, vec1, vec2, ply)
    if id == 1 then
        ents.GetMapCreatedEntity("1556"):EmitSound("misc/charge_up.ogg", 75, 100, 1, CHAN_AUTO)
    else
        ents.GetMapCreatedEntity("1650"):EmitSound("misc/charge_up.ogg", 75, 100, 1, CHAN_AUTO)
    end

    timer.Simple(7, function() --May instead be 7 seconds?
        for _, info in pairs(zapRoomEffectLocations[id]) do
            local effectData = EffectData()
            effectData:SetStart(info.start)
            effectData:SetOrigin(info.origin)
            effectData:SetMagnitude( 0.75 )
            util.Effect("lightning_strike", effectData)
        end

		for _, ent in pairs(ents.FindInBox(vec1, vec2)) do
			if ent:IsValidZombie() or ent:IsPlayer() then
				--Do zombie effect
				timer.Simple(0.2, function()
					if IsValid(ent) then
						local insta = DamageInfo()
						insta:SetAttacker(ply)
						insta:SetDamageType(DMG_MISSILEDEFENSE) --Need to find an acceptable damage type, old was DMG_BLAST_SURFACE
						insta:SetDamage(ent:Health())
						ent:TakeDamageInfo(insta)
						mapscript.bloodGodKills = mapscript.bloodGodKills + 1
					end
				end)
			end
        end
        
        timer.Simple(2, function()
            net.Start("UpdateBloodCount")
                net.WriteInt(math.Clamp(mapscript.bloodGodKills, 0, 999), 16)
            net.Broadcast()
        end)
	end)
end

--This function teleports the player to the given pos with the given angle after a possible delay, and plays HUD and sound effects on the client
function SpecialTeleport(ply, pos, ang, delay)
	ply:GodEnable()
	ply:Lock()
	--SetPermaElectrify(ply, true)
	timer.Simple(delay or 0, function()
        net.Start("RunTeleportOverlay")
        net.Send(ply)
	end)

	timer.Simple(2 + (delay or 0), function() --Delay the teleport for a bit to play sound & HUD effect
		ply:SetNoDraw(true) --may also need to set their equipped weapons invisible
		--ply:Freeze(true)
		--SetPermaElectrify(ply, false)

        --Full length of the HUD effects should be 4 seconds
		timer.Simple(2 - 1.4, function()
			local effectData = EffectData()
			effectData:SetOrigin(pos)
			effectData:SetMagnitude(2)
			effectData:SetEntity(nil)
			util.Effect("lightning_prespawn", effectData)

            timer.Simple(1.4, function()
                ply:SetPos(pos)
                ply:SetAngles(ang)
        
				effectData = EffectData()
				effectData:SetStart( ply:GetPos() + Vector(0, 0, 1000) )
				effectData:SetOrigin( ply:GetPos() )
				effectData:SetMagnitude( 0.75 )
				util.Effect("lightning_strike", effectData)

				ply:SetNoDraw(false)
				ply:GodDisable()
                ply:UnLock()
                --Alternative idea to changing the collision group, we could also just kill the zombies in a box around it
				timer.Simple(1, function() --We don't want the player spawning inside a zombie and not being able to move
					ply:SetCollisionGroup(COLLISION_GROUP_NONE) --TO CHECK
					timer.Simple(1, function()
						ply:SetCollisionGroup(COLLISION_GROUP_PLAYER) --Change back
					end)
				end)
			end)
		end)
	end)
end

function mapscript.OnGameBegin()
    gascans:Reset()
    battery:Reset()

    timer.Simple(0, function()
        for k, v in pairs(player.GetAll()) do
            mapscript.flashlightStatuses[v] = false
            v:AllowFlashlight(false)
        end
    end )
    
    timer.Simple(3, function()
        for k, v in pairs(player.GetAll()) do
            --[[if v:Alive() then
                v:SendLua("surface.PlaySound(\"misc/evilgiggle.ogg)\"")
            end]]
        end
    end)

    --Need to lock the elevator doors & buttons here

	mapscript.bloodGodKills = 0
	local initialUse = false
	local killSwitch = ents.GetMapCreatedEntity("1556") --Non-bloody room button
	killSwitch.OnUsed = function(but, ply)
        if !nzElec:IsOn() --[[or switchOneOn or switchTwoOn]] then
            --but:EmitSound("ambient/buttons/button2.wav") - Already emits this sound
			return
		end

        but:EmitSound("buttons/button24.wav")
        switchOneOn = true
        ZapZombies(1, Vector(-884.5, 3540, 64), Vector(-1200.5, 3888, 64), ply)
	end
	killSwitch = ents.GetMapCreatedEntity("1650") --Bloody room button
	killSwitch.OnUsed = function(but, ply)
        if !nzElec:IsOn() --[[or switchOneOn or switchTwoOn]] then
			return false
		end
        
		but:EmitSound("buttons/button24.wav")
        switchTwoOn = true
        ZapZombies(2, Vector(11, 3540, 64), Vector(-304.5, 3888, 64), ply)
	end

	local sparkLever = ents.GetMapCreatedEntity("1921")
	sparkLever.OnUsed = function(but, ply)
		if !sparkFlipped then
			sparkFlipped = true
		else
			sparkFlipped = false
		end
		--Play an indicating sound
	end

	local nonSparkLever = ents.GetMapCreatedEntity("1920")
	nonSparkLever.OnUsed = function(but, ply)
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
    newPowerSwitch.OnUsed = function(but, ply)
        if delay then return end

        local delay = true
        SetPermaElectrify(but, true)
        Electrify(ply)
        timer.Simple(30, function() delay = false SetPermaElectrify(but, false) end)

		if nzElec:IsOn() then
			--Since a solo player may explore this area before doing anything with the EE, "punish" them instead
			--Do some sound effect and damage the player
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
            SpecialTeleport(ply, nonSparkFlippedOption[randomValue].pos, nonSparkFlippedOption[randomValue].ang, 1)
            if nonSparkFlippedOption.post then
                teleportAgain = true
            end
        else
            randomValue = math.random(#bothFlippedOption)
            SpecialTeleport(ply, bothFlippedOption[randomValue].pos, bothFlippedOption[randomValue].ang, 1)
            if bothFlippedOption.post then
                teleportAgain = true
            end
        end
        
        if teleportAgain then
            teleportTimers = teleportTimers or {}
            teleportTimers[ply:SteamID()] = 120 + math.random(-30, 30)

            timer.Create(ply:SteamID() .. "TeleportTimer", 1, 0, function()
                if !teleportTimers[ply:SteamID()] or !IsValid(ply) then 
                    timer.Remove(ply:SteamID() .. "TeleportTimer")
                end
                if teleportTimers[ply:SteamID()] == 0 or !ply:GetNotDowned() then
                    timer.Remove(ply:SteamID() .. "TeleportTimer")
                    SpecialTeleport(ply, spawnTeleport.pos, spawnTeleport.ang)
                end
				--[[if teleportTimers[ply:SteamID()] == 10 then --or some number 
					--Do something
				end]]

				teleportTimers[ply:SteamID()] = teleportTimers[ply:SteamID()] - 1
            end)
        end
        return true
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

	--Timer for checking battery levels
	timer.Create("BatteryChecks", 1, 0, function()
		for k, v in pairs(player.GetAll()) do
			if v:Alive() and mapscript.batteryLevels[ply:SteamID()] then
				if mapscript.batteryLevels[ply:SteamID()] == 0 then
					v:Flashlight(false) --turns off the flashlight
					v:AllowFlashlight(false) --prevents the flashlight from changing states
				end
				if v:FlashlightIsOn() then
					mapscript.batteryLevels[ply:SteamID()] = math.Clamp(mapscript.batteryLevels[ply:SteamID()] - 1, 0, 100)
					net.Start("SendBatteryLevel")
						net.WriteInt(mapscript.batteryLevels[ply:SteamID()], 6)
					net.Send(v)
				end
			end
		end
	end)
end

function mapscript.OnRoundStart()
	--Redundant flashlight setting, for when players join mid-game
    timer.Simple(0, function()
        for k, v in pairs(player.GetAll()) do
            if mapscript.flashlightStatuses[v] then 
                v:AllowFlashlight(true)
            else 
                mapscript.flashlightStatuses[v] = false
                v:AllowFlashlight(false)
            end

            net.Start("StartBloodCount")
            net.Send(v)
        end
    end)

	--Randomly (re)spawn batteries
	local notSpawned = table.Copy(batteries)
	for k, v in pairs(batteries) do

	end
end

function mapscript.ElectricityOn()
	if !postFirstActivation then
		ents.FindByClass("edit_color")[1]:SetContrast(1)

		timer.Simple(5, function()
			--Move the power switch outside of the map and replace it with a decoy
		end)
	end

	postFirstActivation = true
end

--Need to delete the decoy power switch on game end

return mapscript

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
    - https://wiki.facepunch.com/gmod/navmesh
    - https://wiki.facepunch.com/gmod/CNavArea

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
    Basement lever (sparking): 1921 (first one)
    Bunker console: 1359
    Bunker radio: 1403
*/