util.AddNetworkString("RunFireOverlay")
util.AddNetworkString("RunTeleportOverlay")
util.AddNetworkString("StopOverlay")
util.AddNetworkString("StartBloodCount")
util.AddNetworkString("UpdateBloodCount")
util.AddNetworkString("SendBatteryLevel")
util.AddNetworkString("RunSound")

--[[    Post script-load work    ]]

local mapscript = {}
mapscript.bloodGodKills = 0
mapscript.bloodGodKillsGoal = 30
mapscript.batteryLevels = {}
mapscript.flashlightStatuses = {}

--The gas cans used to fill the generators
local gascanspawns = {
    { --Can 1, found around the power room
        {pos = Vector(-214, 2372, 15), ang = Angle(0, -90, 0)},
        {pos = Vector(-114, 2932, 14.75), ang = Angle(-36, -98.5, 0)},
        {pos = Vector(-1923.25, 3534.25, 15.25), ang = Angle(0, 106, 0)}
    },
    { --Can 2, found in the bathroom & beyond areas
        {pos = Vector(-3972.647949, 2598.693848, 15.330338), ang = Angle(0, -180, 0)},
        {pos = Vector(-5784.763184, 2332.365723, 260.4929), ang = Angle(-89.5, -146, -57.5)},
        {pos = Vector(-6898.134766, 2221.869385, 15.725049), ang = Angle(-22.767, -8.385, 0.0)}
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

--Batteries
local batteries = {
	{pos = Vector(-2436.871582, 1014.399536, 46.50404), ang = Angle(-55.045, 151.149, -167.21)},
	{pos = Vector(-1786.455444, 2370.384521, 48.57032), ang = Angle(-37.775, -64.178, 11.95)},
	{pos = Vector(-1979.874268, 3566.959473, 37.85770), ang = Angle(-37.916, 51.778, 11.93)},
	{pos = Vector(-97.313683, 2924.940186, 37.81508), ang = Angle(-37.314, -118.791, 12.04)},
	{pos = Vector(-2902.511963, 2597.846436, 48.59691), ang = Angle(-38.151, -84.157, 11.88)},
	{pos = Vector(-4622.492188, 3658.279297, -92.48356), ang = Angle(-36.196, -164.181, 11.34)},
	{pos = Vector(-6782.381836, 3432.891602, 34.38910), ang = Angle(-37.794, 157.666, 11.94)},
    {pos = Vector(-3403.921875, 3300.159668, 18.95353), ang = Angle(-53.143, 85.770, -168.46)},
    {pos = Vector(-3647.955078, 6750.748047, 112.58902), ang = Angle(-40.741, 55.908, 14.65)},
    {pos = Vector(-4929.287109, 7471.330566, 101.76261), ang = Angle(-26.939, -4.668, 9.41)},
    {pos = Vector(-5460.764160, 7138.412598, 104.58886), ang = Angle(-38.037, 73.588, 11.90)},
    {pos = Vector(-5473.729980, 7142.676270, 104.53120), ang = Angle(-37.222, 42.693, 12.05)},
    {pos = Vector(-5536.578125, 10493.915039, 81.09477), ang = Angle(-36.348, 35.411, 11.37)},
    {pos = Vector(-5536.988281, 10531.532227, 81.09297), ang = Angle(-36.311, -43.786, 11.36)},
    {pos = Vector(-4273.901855, 10044.547852, 112.55004), ang = Angle(-61.845, -110.469, -164.04)},
    {pos = Vector(-4270.998047, 10008.869141, 112.57056), ang = Angle(58.348, -49.255, -8.13)},
    {pos = Vector(-4270.181152, 9983.740234, 112.65776), ang = Angle(42.282, 107.380, 175.01)},
    {pos = Vector(-4273.702637, 9886.146484, 112.59091), ang = Angle(56.654, 167.444, -11.40)},
    {pos = Vector(-4272.020020, 9822.676758, 112.52522), ang = Angle(-53.056, -105.436, -163.68)},
    {pos = Vector(-4274.509277, 9803.791992, 112.66100), ang = Angle(34.587, -25.402, 174.65)},
    {pos = Vector(-2430.007080, 1346.526367, -3528.44970), ang = Angle(64.863, 66.468, -14.13)},
    {pos = Vector(-2433.776855, 1347.847412, -3528.48461), ang = Angle(-52.461, 142.025, -167.32)},
    {pos = Vector(-3339.458984, 1488.409424, -3549.39941), ang = Angle(71.161, -74.220, -19.93)},
    {pos = Vector(-3364.109375, 662.760254, -3549.39843), ang = Angle(61.172, -85.910, -14.430)},
    {pos = Vector(-3360.204834, 572.172607, -3549.368652), ang = Angle(-38.956, 132.059, 12.01)},
    {pos = Vector(-3364.406982, 566.230713, -3549.42529), ang = Angle(-60.017, 123.212, -164.98)},
    {pos = Vector(-5174.005859, 560.970459, -3531.32959), ang = Angle(30.249, 21.286, 173.75)},
    {pos = Vector(-5174.726074, 578.369934, -3531.48828), ang = Angle(-51.760, 97.969, -169.90)},
    {pos = Vector(-3269.567871, 2077.697754, -3549.38061), ang = Angle(-38.943, -139.653, 11.97)},
    {pos = Vector(-3282.178711, 2076.142822, -3549.47021), ang = Angle(-58.391, 58.327, -166.00)},
    {pos = Vector(-2439.740967, 781.870728, 46.52282), ang = Angle(-61.265, 11.267, -170.51)},
    {pos = Vector(158.518555, 3749.448486, 34.58102), ang = Angle(-38.046, -115.702, 11.60)},
    {pos = Vector(-351.988251, 2292.685791, 52.67468), ang = Angle(-38.877, -170.935, 10.76)}
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

local radiosByID = {"1456", "2144", "1403"}

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

--Batteries are only created on round & game start, you'll find code for spawning them in mapscript.OnRoundStart and mapscript.OnGameBegin
local battery = nzItemCarry:CreateCategory("battery")
	battery:SetIcon("spawnicons/zworld_equipment/zpile.png")
	battery:SetText("Press E to pick up a battery.")
	battery:SetDropOnDowned(false)
	battery:SetShowNotification(true)
	battery:SetResetFunction(function(self)
		for _, info in pairs(batteries) do
			if info.spawned and info.ent and info.ent:IsValid() then
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

--[[    Non-mapscript functions    ]]

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

--This function is only ever ran with electricity being on
function ZapZombies(id, vec1, vec2, ply)
    if id == 1 then
        ents.GetMapCreatedEntity("1556"):EmitSound("misc/charge_up.ogg", 75, 100, 1, CHAN_AUTO)
    else
        ents.GetMapCreatedEntity("1650"):EmitSound("misc/charge_up.ogg", 75, 100, 1, CHAN_AUTO)
    end

    timer.Simple(7.5, function()
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
			nzElec:Reset()
			ents.GetMapCreatedEntity("2767"):Fire("Use")
			--Play some "backup power enabled" sound? Should explain why there's lights

			timer.Simple(2, function()
				net.Start("UpdateBloodCount")
					net.WriteInt(math.Clamp(mapscript.bloodGodKills, 0, 999), 16)
				net.Broadcast()

				if mapscript.bloodGodKills >= mapscript.bloodGodKillsGoal then
					--Do something here
				end
			end)
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

--Generates a random set length totalDesired of values between 1 and maxNum as a table, returns nil if the 2 params are equal or total is under max
function GenerateRandomSet(maxNum, totalDesired)
    if totalDesired >= maxNum then
        return
    end

    local throwawayTab = {}
    for counter = 1, totalDesired do
        local randomNum = math.random(1, maxNum)
        while throwawayTab[randomNum] do
            randomNum = math.random(1, maxNum)
        end
        throwawayTab[randomNum] = true
    end

    return throwawayTab
    --[[local returnTab = {}
    for k, v in pairs(throwawayTab) do
        returnTab[#returnTab + 1] = k
    end

    return returnTab]]
end

--[[    Mapscript functions    ]]

function mapscript.OnGameBegin()
    gascans:Reset()
    battery:Reset()

    local throwawayTab = GenerateRandomSet(#batteries, #batteries / 2)
    for k, v in pairs(batteries) do
        if throwawayTab[k] then
            local ent = ents.Create("nz_script_prop")
			ent:SetModel("zworld_equipment/zpile.mdl")
			ent:SetPos(v.pos)
			ent:SetAngles(v.ang)
			ent:Spawn()
            battery:RegisterEntity(ent)
            v.spawned = true
        end
    end

    timer.Simple(0, function()
        for k, v in pairs(player.GetAll()) do
            mapscript.flashlightStatuses[v] = false
            v:AllowFlashlight(false)
        end
    end )

	timer.Create("RadioSounds", 60 + math.random(-30, 30), 0, function()
		local soundToPlay = "" --probably shouldn't play anything unqiue, only sounds we can repeat
		for k, v in pairs(radiosByID) do
			ents.GetMapCreatedEntity(v):EmitSound(soundToPlay)
		end
    end)

    --Need to lock the elevator doors & buttons here

	mapscript.bloodGodKills = 0
	local initialUse = false
	local killSwitch = ents.GetMapCreatedEntity("1556") --Non-bloody room button
	killSwitch.OnUsed = function(but, ply)
        if !nzElec:IsOn() --[[or switchOneOn or switchTwoOn]] then
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

        local throwawayTab = {1, 3, 4} --Have to do this stupid work-around since these are hl2 sounds and there's no teleport2.wav
        net.Start("RunSound")
            net.WriteString("ambient/machines/teleport" .. throwawayTab[math.random(#throwawayTab)] .. ".wav")
        net.Broadcast()
	end

	local nonSparkLever = ents.GetMapCreatedEntity("1920")
	nonSparkLever.OnUsed = function(but, ply)
		if !nonSparkFlipped then
			nonSparkFlipped = true
		else
			nonSparkFlipped = false
        end
        
		local throwawayTab = {1, 3, 4}
        net.Start("RunSound")
            net.WriteString("ambient/machines/teleport" .. throwawayTab[math.random(#throwawayTab)] .. ".wav")
        net.Broadcast()
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
        if powerSwitchDelay or !ply then return end

        powerSwitchDelay = true
        SetPermaElectrify(but, true)
        Electrify(ply)
        timer.Simple(30, function() powerSwitchDelay = false SetPermaElectrify(but, false) end)

		if nzElec:IsOn() then
            but:EmitSound("ambient/energy/zap" .. math.random(9) .. ".wav")

            local insta = DamageInfo()
            insta:SetAttacker(but)
            insta:SetDamageType(DMG_SHOCK) --Need to find an acceptable damage type, old was DMG_BLAST_SURFACE
            insta:SetDamage(ply:Health() - 1)
            ply:TakeDamageInfo(insta)

            timer.Simple(2, function()
                ents.GetMapCreatedEntity("2767"):Fire("Use")
            end)
        else
            timer.Simple(1, function()
                nzElec:Activate()
            end)
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

				teleportTimers[ply:SteamID()] = teleportTimers[ply:SteamID()] - 1
            end)
        end
        return true
	end

    --Creates the elevator generator
    local gasLevel = 0
    local gen = ents.Create("nz_script_prop")
    gen:SetPos(Vector(-2723, 1790, 27.5))
    gen:SetAngles(Angle(0, -90, 0))
    gen:SetModel("models/props_wasteland/laundry_washer003.mdl")
    gen:SetNWString("NZText", "You must fill this generator with gasoline to power it.")
    gen:SetNWString("NZRequiredItem", "gascan")
    gen:SetNWString("NZHasText", "Press E to fuel this generator with gasoline.")
    gen:Spawn()
    gen:Activate()
    gen.OnUsed = function(self, ply)
        if ply:HasCarryItem("gascan") and !generatorPowered and !gasDelay then
            gasDelay = true
            gasLevel = gasLevel + 1

            --This feels unnecessary
            for num, tab in pairs(gascanspawns) do
                if tab.ent == ply.ent then
                    tab.used = true
                    tab.held = false
                    continue
                end
            end

            gen:SetNWString("NZText", "")
            gen:SetNWString("NZHasText", "")
            gen:EmitSound("nz/effects/gas_pour.wav")

            --After the gas_pour sound has played
            timer.Simple(4, function()
                if not gen then return end
                gasDelay = false

                if gasLevel == 4 then
                    generatorPowered = true
                    gen:SetNWString("NZText", "This generator is powered on.")
                    gen:SetNWString("NZHasText", "") --There shouldn't be any more
                    gen:EmitSound("nz/effects/generator_start.wav")

                    --After the 9 second generator_start sound has played
                    timer.Simple(9, function()
                        --Call up the elevator
                        gen:EmitSound("nz/effects/generator_humm.ogg")
                        timer.Create("GeneratorHumm", 3, 0, function()
                            if not gen then return end
                            gen:EmitSound("nz/effects/generator_humm.ogg")
                        end)
                    end)
                else
                    ply:RemoveCarryItem("gascan")
                    gen:SetNWString("NZText", "You must fill this generator with more gasoline to power it.")
                    gen:SetNWString("NZHasText", "Press E to fuel this generator with gasoline.")
                end
            end)
        end
    end
    gen.Think = function()
        --If the generator is removed, or the game has ended, destroy the "on" sound & timer
        if (!generatorPowered and gen:IsValid() or !gen:IsValid()) and timer.Exists("GeneratorHumm") then
            timer.Destroy("GeneratorHumm")
        end
    end

	--Timer for checking battery levels
	timer.Create("BatteryChecks", 1, 0, function()
		for k, v in pairs(player.GetAll()) do
			if v:Alive() and mapscript.batteryLevels[v:SteamID()] then
				if mapscript.batteryLevels[v:SteamID()] == 0 then
					v:Flashlight(false) --turns off the flashlight
					v:AllowFlashlight(false) --prevents the flashlight from changing states
				end
				if v:FlashlightIsOn() then
					mapscript.batteryLevels[c:SteamID()] = math.Clamp(mapscript.batteryLevels[c:SteamID()] - 1, 0, 100)
					net.Start("SendBatteryLevel")
						net.WriteInt(mapscript.batteryLevels[c:SteamID()], 6)
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
	local notSpawned = {}
	for k, v in pairs(batteries) do
        if !v.spawned then
            notSpawned[#notSpawned + 1] = v
        end
    end
    
    newBat = notSpawned[math.random(#notSpawned)]
    local ent = ents.Create("nz_script_prop")
    ent:SetModel("zworld_equipment/zpile.mdl")
    ent:SetPos(newBat.pos)
    ent:SetAngles(newBat.ang)
    ent:Spawn()
    battery:RegisterEntity(ent)
end

function mapscript.ElectricityOn()
    if !postFirstActivation then
        local colorEditor = ents.FindByClass("edit_color")[1]
        local contrastScale = 0.5 --This is the value it's set to in the config, we scale this value up here
        timer.Create("RemoveGrayscale", 0.5, 10, function()
            contrastScale = contrastScale + 0.05
            colorEditor:SetContrast(contrastScale)
        end)

        ents.GetMapCreatedEntity("2767"):Fire("Use")

		timer.Simple(5, function()
            local fakeSwitch, fakeLever = ents.Create(class), ents.Create(class)
            --Do more

            ents.FindByClass("power_box")[1]:SetPos()
		end)
	end
    
	postFirstActivation = true
end

function mapscript.OnGameEnd()
    powerSwitch = ents.FindByClass("power_box")[1]
	if powerSwitch and IsValid(powerSwitch) then powerSwitch:Remove() end
end

return mapscript

--[[	Any hooks    ]]

hook.Add("OnDoorUnlocked", "CreepyLaugh", function(_, _, link, _, ply)
	if link == "1" then
		local throwaway = ents.Create("")
		throwaway:SetPos(Vector())
		throwaway:SetAngles(Angle())
		throwaway:Spawn()
		throwaway:SetNoDraw(true)
		throwaway:EmitSound("misc/evilgiggle.ogg", 100, 100, 1, CHAN_AUTO)
		--:EmitSound(string soundName, number soundLevel=75, number pitchPercent=100, number volume=1, number channel=CHAN_AUTO)
		timer.Simple(10, function() throwaway:Remove() end)	
	end
end)

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