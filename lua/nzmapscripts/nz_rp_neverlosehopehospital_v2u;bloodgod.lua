util.AddNetworkString("RunFireOverlay")
util.AddNetworkString("RunTeleportOverlay")
util.AddNetworkString("StopOverlay")
util.AddNetworkString("StartBloodCount")
util.AddNetworkString("UpdateBloodCount")
util.AddNetworkString("SendBatteryLevel")
util.AddNetworkString("RunSound")
util.AddNetworkString("StartTeleportTimer")
util.AddNetworkString("UpdateTeleportTimer")
util.AddNetworkString("ResetChalkMessages")
util.AddNetworkString("RunCoward")

--[[    Post script-load work    ]]

local mapscript = {}
mapscript.bloodGodKills = 0
mapscript.bloodGodKillsGoal = 10
mapscript.batteryLevels = {}
mapscript.flashlightStatuses = {}

--The gas cans used to fill the generators
local gascanspawns = {
    { --Can 1, found around the power room
        {pos = Vector(-214, 2372, 15), ang = Angle(0, -90, 0)}, --By jugg
        {pos = Vector(-693.2, 3046.3, 13.9), ang = Angle(-0, 87.8, 0)}, --In the un-barricaded operating room
        {pos = Vector(-1923.25, 3534.25, 15.25), ang = Angle(0, 106, 0)} --By AR-15 wallbuy
    },
    { --Can 2, found in the bathroom & beyond areas
        {pos = Vector(-3972.647949, 2598.693848, 15.330338), ang = Angle(0, -180, 0)}, --In bathroom
        {pos = Vector(-5784.763184, 2332.365723, 260.4929), ang = Angle(-89.5, -146, -57.5)}, --In "vent" area
        {pos = Vector(-6958.002930, 3406.063477, 13.222458), ang = Angle(-35.5, 89.1, 0)} --In the teleport-only area
    },
    { --Can 3, found before or after the long hallways
        {pos = Vector(-2822.691406, 2577.959961, 14.340928), ang = Angle(-0.000, -0.440, 0.000)},
        {pos = Vector(-3575.974854, 2580.693359, 13.587985), ang = Angle(0.453, -17.249, 0.216)},
        {pos = Vector(-3664.124512, 7118.309570, 76.736771), ang = Angle(-21.987, -47.260, -1.129)}
    },
    { --Can 4, found behind the destructible wall
        {pos = Vector(-1521.962036, 3592.954590, 12.954604), ang = Angle(-30.518, 93.740, -1.926)}
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
    {pos = Vector(-351.988251, 2292.685791, 52.67468), ang = Angle(-38.877, -170.935, 10.76)},
    {pos = Vector(-2438.876465, 1012.538818, 46.576851), ang = Angle(-45.786, -23.365, 11.249)},
    {pos = Vector(-2943.356201, 376.680359, 32.539017), ang = Angle(-52.924, 54.885, -167.160)},
    {pos = Vector(-1634.872925, 2501.901611, 48.442104), ang = Angle(-61.534, -126.098, -164.882)},
    {pos = Vector(-1669.691406, 4030.333252, 48.593281), ang = Angle(57.175, 173.273, -12.060)},
    {pos = Vector(-724.885986, 3514.568604, 48.604996), ang = Angle(-35.177, 68.342, 10.817)},
    {pos = Vector(-3065.257080, 3074.691895, 0.541340), ang = Angle(-57.086, -66.165, -167.97)}
}

local areasByVector = {
    { --Spawn area & beyond
        {pos1 = Vector(223.3, 4672.2, -50.0), pos2 = Vector(-4224.0, -1505.1, 256.0)}, --This pair overlaps parts of areasByVector[1][2] & areasByVector[1][3], but that's okay
        {pos1 = Vector(-6873.0, 10810.0, 320.0), pos2 = Vector(-2137.0, 4672.2, -50.0)},
        {pos1 = Vector(-4768, 3008.0, -50.0), pos2 = Vector(-3968.0, 2308.0, 128.0)},
    },
    { --Generator area
        {pos1 = Vector(-4864.0, 2596.0, 0.0), pos2 = Vector(-5695.0, 3451.5, 192)},
        {pos1 = Vector(-5055.0, 3397.4, 128), pos2 = Vector(-4608.4, 4543, -128)}
    },
    { --Teleport area
        {pos1 = Vector(-6336.0, 3904.0, -32.0), pos2 = Vector(-7424.0, 2080.0, 192.0)}
    },
    { --Basement area
        {pos1 = Vector(-5513.0, -63.5, -3632.6), pos2 = Vector(-2305.0, 2368.4, -3392.0)}
    }
}

--Possible spots players may teleport to on power generator flippage
local possibleTeleports = {
    { --Blocked-off area teleport (otherwise inaccessible)
      --Must default to this when neither switch has been flipped, so the player isn't teleported outside a purchased area
		{pos = Vector(-6751.75, 3268.5, 0), ang = Angle(0, -180, 0), post = true}
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
local spawnTeleport = {pos = Vector(-2367, 12, 0), ang = Angle(0, 90, 0)}

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
			if tab.ent and tab.ent:IsValid() then
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
	battery:SetIcon("spawnicons/models/zworld_equipment/zpile.png")
    battery:SetText("Press E to insert battery into flashlight.")
	battery:SetDropOnDowned(false)
	battery:SetShowNotification(true)
	battery:SetResetFunction(function(self)
		for _, info in pairs(batteries) do
			if info.spawned and info.ent and info.ent:IsValid() then
				info.ent:Remove()
				info.spawned = false
			end
        end
        for k, v in pairs(player.GetAll()) do
            v:RemoveCarryItem("battery")
        end
        mapscript.batteryLevels = {}
	end)
	battery:SetPickupFunction(function(self, ply, ent)
        --Play some extra sound? EE object pickup sound doesn't play if you already have the object
		ply:GiveCarryItem(self.id)
		ply:AllowFlashlight(true)
		mapscript.flashlightStatuses[ply] = true
        mapscript.batteryLevels[ply:SteamID()] = math.Clamp(mapscript.batteryLevels[ply:SteamID()] + ent.charge, 0, 100)
        
        net.Start("SendBatteryLevel")
            net.WriteInt(mapscript.batteryLevels[ply:SteamID()], 16)
        net.Send(ply)
		
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

local key = nzItemCarry:CreateCategory("key")
    key:SetIcon("spawnicons/models/zpprops/keychain.png")
    key:SetText("Press E to pick up the keys.")
    key:SetDropOnDowned(false)
    key:SetShowNotification(true)
    key:SetResetFunction(function(self)
		local ent = ents.Create("nz_script_prop")
        ent:SetModel("models/zpprops/keychain.mdl")
        ent:SetPos(Vector(-4619.8, 3686.0, -92.6))
        ent:SetAngles(Angle(-0, -43.7, 0))
        ent:Spawn()
        self:RegisterEntity(ent)
        for k, v in pairs(player.GetAll()) do
            v:RemoveCarryItem("key")
        end
	end)
	key:SetPickupFunction(function(self, ply, ent)
		ply:GiveCarryItem(self.id)
        ent:Remove()
	end)
	key:SetCondition( function(self, ply)
		return !ply:HasCarryItem("key")
	end)
key:Update()

--[[    Non-mapscript functions    ]]

function GetNavFlood(navArea, tab)
    for k, v in pairs(navArea:GetAdjacentAreas()) do 
        if not tab[v:GetID()] then 
            tab[v:GetID()] = true 
            GetNavFlood(v, tab) 
        end 
    end 
end

local NavAreaPrimarySeed = navmesh.GetNavAreaByID(5263) --The primary play area, contains 75% of the map
local NavAreaPrimaryList = {[5263] = true}
GetNavFlood(NavAreaPrimarySeed, NavAreaPrimaryList)
local NavAreaGeneratorSeed = navmesh.GetNavAreaByID(55) --The generator play area, very small, where the players teleport away from
local NavAreaGeneratorList = {[55] = true}
GetNavFlood(NavAreaGeneratorSeed, NavAreaGeneratorList)
local NavAreaTeleportSeed = navmesh.GetNavAreaByID(34) --The teleport-only play area players teleport to when no basement levers have been flipped
local NavAreaTeleportList = {[34] = true}
GetNavFlood(NavAreaTeleportSeed, NavAreaTeleportList)
local NavAreaBasementSeed = navmesh.GetNavAreaByID(77) --The entire basement play area
local NavAreaBasementList = {[77] = true}
GetNavFlood(NavAreaBasementSeed, NavAreaBasementList)

local allZombieSpawns = {{}, {}, {}, {}}
for k, v in pairs(ents.GetAll()) do
    if v:GetClass() == "nz_spawn_zombie_normal" or v:GetClass() == "nz_spawn_zombie_special" then
        v.spawnNav = navmesh.GetNearestNavArea(v:GetPos())
        v.spawnNavID = v.spawnNav:GetID()
        --No loop since no table
        if NavAreaPrimaryList[v.spawnNavID] then
            table.insert(allZombieSpawns[1], v)
            v.spawnZone = 1
        elseif NavAreaGeneratorList[v.spawnNavID] then
            table.insert(allZombieSpawns[2], v)
            v.spawnZone = 2
        elseif NavAreaTeleportList[v.spawnNavID] then
            table.insert(allZombieSpawns[3], v)
            v.spawnZone = 3
        elseif NavAreaBasementList[v.spawnNavID] then
            table.insert(allZombieSpawns[4], v)
            v.spawnZone = 4
        end
    end 
end

--Uses the ID to respawn all zombie entities of the specific ID, called when players have moved beyond a map area, via a ladder, teleporting, or the elevator
function CleanupZombies(id)
    print("CleanupZombies call with id " .. id)
    for k, v in pairs(ents.GetAll()) do
        if v:GetClass() == "nz_zombie_walker" or v:GetClass() == "nz_zombie_special_dog" or v:GetClass() == "nz_zombie_special_burning" then
            if v.spawnZone == id then
                v:RespawnZombie()
            end
        end
    end
end

--//Creates the lightning aura once around the given ent (lasts 0.5 seconds, approximately)
function Electrify(ent)
	local effect = EffectData()
	effect:SetScale(1)
	effect:SetEntity(ent)
	util.Effect("lightning_aura", effect)
end

--//Creates a never-ending lightning aura around the given ent
function SetElectrify(ent, enable, scale)
    electrifiedEnts = electrifiedEnts or {}
    electrifiedScale = electrifiedScale or {}
    electrifiedEnts[ent] = enable
    electrifiedScale[ent] = scale or 1

    local effecttimer = 0
    hook.Add("Think", "PermaElectrifyEntities", function()
        if effecttimer < CurTime() then
            for k, v in pairs(electrifiedEnts) do
                if v then
                    local effect = EffectData()
                    effect:SetScale(1) --Does nothing?
                    effect:SetRadius(electrifiedScale[k])
                    effect:SetEntity(k)
                    util.Effect("lightning_aura", effect)
                end
            end
            effecttimer = CurTime() + 0.3
        end
    end)
end

--This function is only ever ran with electricity being on
function ZapZombies(vec1, vec2, ply)
    ents.GetMapCreatedEntity("1650"):EmitSound("misc/charge_up.ogg", 75, 100, 1, CHAN_AUTO)

    timer.Simple(7.5, function()
        for _, info in pairs(zapRoomEffectLocations[2]) do
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
						insta:SetDamageType(DMG_MISSILEDEFENSE)
						insta:SetDamage(ent:Health())
						ent:TakeDamageInfo(insta)
						mapscript.bloodGodKills = math.Approach(mapscript.bloodGodKills, mapscript.bloodGodKillsGoal, 1) --This  counts players too
					end
				end)
			end
        end
        
        timer.Simple(2, function()
            StopGeneratorHumm()
			nzElec:Reset()
			ents.GetMapCreatedEntity("2767"):Fire("Use") --Turn generator room lights off
			--Play some "backup power enabled" sound? Should explain why there's lights
            for k, v in pairs(player.GetAll()) do
                v:ChatPrint("Building power offline, resorting to backup generators...")
            end

			timer.Simple(2, function()
				net.Start("UpdateBloodCount")
					net.WriteInt(math.Clamp(mapscript.bloodGodKills, 0, mapscript.bloodGodKillsGoal), 16)
				net.Broadcast()

				if mapscript.bloodGodKills >= mapscript.bloodGodKillsGoal then
                    timer.Simple(5, function()
                        CompletedBloodGod()
                    end)
				end
			end)
		end)
	end)
end

--Runs special logic when the blood god easter egg is finished
function CompletedBloodGod()
    net.Start("RunSound")
        net.WriteString("misc/evilgiggle.ogg")
        net.WriteInt(130, 8)
    net.Broadcast()

    net.Start("RunCoward")
    net.Broadcast()

    --Probably wanna spawn some enemy
end

--This function teleports the player to the given pos with the given angle after a possible delay, and plays HUD and sound effects on the client
function SpecialTeleport(ply, pos, ang, delay)
	ply:GodEnable()
    ply:Lock()
    local oldPriority = ply:GetTargetPriority()
    ply:SetTargetPriority(TARGET_PRIORITY_NONE)
	SetElectrify(ply, true)
	timer.Simple(delay or 0, function()
        net.Start("RunTeleportOverlay")
        net.Send(ply)
	end)

	timer.Simple(2 + (delay or 0), function() --Delay the teleport for a bit to play sound & HUD effect
		ply:SetNoDraw(true) --may also need to set their equipped weapons invisible
		--ply:Freeze(true)
		SetElectrify(ply, false)

        --Full length of the HUD effects should be 4 seconds
		timer.Simple(2 - 1.4, function()
			local effectData = EffectData()
			effectData:SetOrigin(pos)
			effectData:SetMagnitude(2)
			effectData:SetEntity(nil)
			util.Effect("lightning_prespawn", effectData)

            timer.Simple(1.4, function()
                ply:SetPos(pos)
                ply:SetEyeAngles(ang)
        
				effectData = EffectData()
				effectData:SetStart(ply:GetPos() + Vector(0, 0, 1000))
				effectData:SetOrigin(ply:GetPos())
				effectData:SetMagnitude(0.75)
				util.Effect("lightning_strike", effectData)

				ply:SetNoDraw(false)
				ply:GodDisable()
                ply:UnLock()
                ply:SetTargetPriority(oldPriority)
                --Alternative idea to changing the collision group, we could also just kill the zombies in a box around it
				timer.Simple(1, function() --We don't want the player spawning inside a zombie and not being able to move
					ply:SetCollisionGroup(COLLISION_GROUP_NONE)
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
end

--Used by the dors leading to the ZapZombies buttons, zaps players for :GetMaxHealth() - 1 when used while electrified
function ZapPlayer(ent, ply)
    if !powerSwitchUsed then
        ent:EmitSound("ambient/energy/zap" .. math.random(9) .. ".wav")
        local insta = DamageInfo()
        insta:SetAttacker(ent)
        insta:SetDamageType(DMG_SHOCK) --Need to find an acceptable damage type, old was DMG_BLAST_SURFACE
        insta:SetDamage(ply:GetMaxHealth() - 1)
        ply:TakeDamageInfo(insta)
    end
end

function StartGeneratorHumm()
    if !generatorSoundEmitter then
        generatorSoundEmitter = ents.Create("nz_script_prop")
        generatorSoundEmitter:SetPos(4761, 4497.5, -73.0)
        --generatorSoundEmitter:SetModel() --can I create an ent with no model?
        generatorSoundEmitter:Spawn()
    end
    
    if !timer.Exists("GeneratorHumm2") then
        generatorSoundEmitter:EmitSound("nz/effects/generator2_start.wav", 130)
        timer.Simple(1.25, function() --generator2_start plays for 2.8 seconds
            timer.Create("GeneratorHumm2", 1.5, 0, function()
                generatorSoundEmitter:EmitSound("nz/effects/generator2_humm.wav", 130)
            end)
        end)
    end
end

function StopGeneratorHumm()
    if generatorSoundEmitter then
        timer.Simple(timer.TimeLeft("GeneratorHumm2"), function()
            generatorSoundEmitter:EmitSound("nz/effects/generator2_shutdown.wav", 130)
        end)
        timer.Remove("GeneratorHumm2")
    end
end

--[[    Mapscript functions    ]]

function mapscript.OnGameBegin()
    --Reset pick-up-able objects
    gascans:Reset()
    battery:Reset()
    key:Reset()

    for k, v in pairs(player.GetAll()) do
        v:ChatPrint("Building power offline, resorting to backup generators...")
    end

    --Spawns the initial set of batteries
    local throwawayTab = GenerateRandomSet(#batteries, #batteries / 2)
    for k, v in pairs(batteries) do
        if throwawayTab[k] then
            local ent = ents.Create("nz_script_prop")
			ent:SetModel("models/zworld_equipment/zpile.mdl")
			ent:SetPos(v.pos)
			ent:SetAngles(v.ang)
			ent:Spawn()
            battery:RegisterEntity(ent)

            v.spawned = true
            v.ent = ent
            ent.charge = math.random(25, 80)

            ent:SetNWString("NZRequiredItem", "battery")
            ent:SetNWString("NZHasText", "Press E to add the battery to your flashlight.")
        end
    end

    --Disables flashlights on all players
    timer.Simple(0, function()
        for k, v in pairs(player.GetAll()) do
            mapscript.flashlightStatuses[v] = false
            v:AllowFlashlight(false)
        end
    end )

    --Creates spooky noises to play from radios
    timer.Create("RadioSounds", math.random(20, 50), 0, function()
        local sounds = {"numbers", "numbers2", "numbers3", "static", "static1", "static2", "whispers"}
		local soundToPlay = "radio sounds/" .. sounds[math.random(#sounds)] .. ".ogg"
		for k, v in pairs(radiosByID) do
			ents.GetMapCreatedEntity(v):EmitSound(soundToPlay, 90)
		end
    end)

    --The ent blocking passage after the long hallways
    local wallBlock = ents.Create("prop_physics")
    wallBlock:SetModel("models/hunter/plates/plate3x3.mdl")
    wallBlock:SetPos(Vector(-3600.7, 6482.8, 120.5))
    wallBlock:SetAngles(Angle(90, 90, 180))
    wallBlock:SetMaterial("models/props_combine/com_shield001a")
    wallBlock:Spawn()
    wallBlock:GetPhysicsObject():EnableMotion(false)
    wallBlock:StartLoopingSound("ambient/machines/combine_shield_loop3.wav")
    --timer.Create("CombineWallEmitSound", delay, repetitions, func)

    --The combine console that enables the map-spawned consoles to remove the above ent blocking passage
    mapscript.onLockdown = true
    local comConsole = ents.Create("nz_script_prop")
    comConsole:SetModel("models/props_combine/combine_interface001.mdl")
    comConsole:SetPos(Vector(-7224.5, 2712.6, -0.2))
    comConsole:SetAngles(Angle(-0.0, 90.0, -0.0))
    comConsole:SetNWString("NZText", "Power must be on")
    comConsole:Spawn()
    comConsole.OnUsed = function()
        if mapscript.onLockdown then
            comConsole:EmitSound("buttons/combine_button1.wav")
            mapscript.onLockdown = false
            comConsole:SetNWString("NZText", "")
            for k, v in ipairs(mapscript.consoleButtons) do
                ents.GetMapCreatedEntity(v):SetNWString("NZText", "Press E to further rescind building system lockdown")
            end
        end
    end
    mapscript.CombineConsole = comConsole

    --All the map-created entities that need to be locked/called/whatever
    --Lock & apply text to the basement elevator
    local elDoor1 = ents.GetMapCreatedEntity("1825")
    elDoor1:Fire("Lock")
    elDoor1:SetNWString("NZText", "You must power the generator before calling the elevator")
    local elDoor2 = ents.GetMapCreatedEntity("1826")
    elDoor2:Fire("Lock")
    elDoor2:SetNWString("NZText", "You must power the generator before calling the elevator")
    local elButton = ents.GetMapCreatedEntity("2304")
    elButton:Fire("Lock")
    elButton:SetNWString("NZText", "You must power the generator before calling the elevator")
    --Lock the bunker elevator
    --ents.GetMapCreatedEntity("1907"):Fire("Use") --Inside elevator button
    ents.GetMapCreatedEntity("1907"):Fire("Lock")
    ents.GetMapCreatedEntity("1488"):Fire("Lock") --Main floor elevator button
    ents.GetMapCreatedEntity("1493"):Fire("Lock") --Elevator ent
    ents.GetMapCreatedEntity("1478"):SetPos(Vector(-2394, 1280, 64)) --Left door (closed position: Vector(-2394, 1280, 64))
    ents.GetMapCreatedEntity("1477"):SetPos(Vector(-2341, 1280, 64)) --Right door (closed position: Vector(-2341, 1280, 64))
    --Open the jail door in front of power generator room
    ents.GetMapCreatedEntity("2778"):Fire("Use")
    --Locks the door the padlock is "attached" to
    ents.GetMapCreatedEntity("1567"):Fire("Lock")
    --Sets some flavor text for the destructable wall
    ents.GetMapCreatedEntity("1563"):SetNWString("NZText", "This part of the wall looks oddly destructable...")
    --Door to the power room, that doesn't seem to want to lock via door buy settings
    ents.GetMapCreatedEntity("1746"):Fire("Lock")
    --Electrify and lock the 2 doors leading to the ZapZombies buttons
    --[[local doors = {"1564"}
    for k, v in pairs(doors) do
        local lock = ents.GetMapCreatedEntity(v)
        lock:Fire("Lock")
        lock.OnUsed = ZapPlayer
        SetElectrify(lock, true, 2)
    end]]

    --Creates the padlock required to unlock to access power & zap rooms
    local padlock = ents.Create("prop_physics")
    padlock:SetPos(Vector(-1066.5, 2811.75, 38.9))
    padlock:SetAngles(Angle(0, 180, 0))
    padlock:SetModel("models/props_wasteland/prison_padlock001a.mdl")
    padlock:SetNWString("NZText", "Locked, find a key")
    padlock:SetNWString("NZRequiredItem", "key")
    padlock:SetNWString("NZHasText", "Press E to unlock the padlock")
    padlock:Spawn()
    padlock:Activate()
    padlock:GetPhysicsObject():EnableMotion(false)
    padlock.OnUsed = function(ent, ply)
        if ply:HasCarryItem("key") then
            ply:RemoveCarryItem("key")
            --Play unlock sound
            timer.Simple(0, function() --Length of the sound
                padlock:SetModel("models/props_wasteland/prison_padlock001b.mdl")
                padlock:GetPhysicsObject():EnableMotion(true)
                padlock:GetPhysicsObject():ApplyForceCenter(Vector(0, 0, 0))
                padlock:SetCollisionGroup(COLLISION_GROUP_WORLD)
                padlock:SetNWString("NZText", "")

                local door = ents.GetMapCreatedEntity("1567")
                door:Fire("Unlock")
                door:Fire("Use")
                --door:Fire("Lock")
                door.OnUsed = function(but, ply)
                    timer.Simple(0, function()
                        but:Fire("Lock")
                    end)
                end

                nzDoors:OpenLinkedDoors("Padlock")
            end)
        end
    end

    --Sets up the blood god easter egg zap buttons
	mapscript.bloodGodKills = 0
	local switchOn = false
	local killSwitch = ents.GetMapCreatedEntity("1650")
	killSwitch.OnUsed = function(but, ply)
        if !nzElec:IsOn() or switchOn then
			return false
		end
        
		but:EmitSound("buttons/button24.wav")
        switchOn = true
        ZapZombies(Vector(11, 3540, 64), Vector(-304.5, 3888, 64), ply)
        timer.Simple(10, function() switchOn = false end)
	end

    --Sets up the special functionality for the levers in the basement
    local sparkLever = ents.GetMapCreatedEntity("1921")
    SetElectrify(sparkLever, true)
	sparkLever.OnUsed = function(but, ply)
		if !sparkFlipped then
			sparkFlipped = true
		else
			sparkFlipped = false
        end

        local throwawayTab = {1, 3, 4} --Have to do this stupid work-around since these are hl2 sounds and there's no teleport2.wav
        timer.Simple(1, function()
            net.Start("RunSound")
                net.WriteString("ambient/machines/teleport" .. throwawayTab[math.random(#throwawayTab)] .. ".wav")
            net.Broadcast()
        end)
	end
    local nonSparkLever = ents.GetMapCreatedEntity("1920")
    SetElectrify(nonSparkLever, true)
	nonSparkLever.OnUsed = function(but, ply)
		if !nonSparkFlipped then
			nonSparkFlipped = true
		else
			nonSparkFlipped = false
        end
        
		local throwawayTab = {1, 3, 4}
        timer.Simple(1, function()
            net.Start("RunSound")
                net.WriteString("ambient/machines/teleport" .. throwawayTab[math.random(#throwawayTab)] .. ".wav")
            net.Broadcast()
        end)
	end

    --Randomizes the teleport possibilities when the generator switch is flipped, both unflipped remains the same always
	local neitherFlippedOption = table.Copy(possibleTeleports[1])
    local bothFlippedOption = table.Copy(possibleTeleports[4])
	local nonSparkFlippedOption = table.Copy(possibleTeleports[3])
	local sparkFlippedOption = table.Copy(possibleTeleports[2])

	--The generator power switch that teleports the player
    newPowerSwitch = ents.GetMapCreatedEntity("2767")
    mapscript.NewPowerSwitch = newPowerSwitch
    newPowerSwitch.OnUsed = function(button, ply)
        if newPowerSwitch.powerSwitchDelay or !ply then return end

        if !powerSwitchUsed then
            powerSwitchUsed = true
        end

        newPowerSwitch.powerSwitchDelay = true
        SetElectrify(button, true, 0.5)
        Electrify(ply)
        timer.Simple(30, function() newPowerSwitch.powerSwitchDelay = false SetElectrify(button, false) end)

		if nzElec:IsOn() then
            button:EmitSound("ambient/energy/zap" .. math.random(9) .. ".wav")

            local insta = DamageInfo()
            insta:SetAttacker(button)
            insta:SetDamageType(DMG_SHOCK)
            insta:SetDamage(ply:GetMaxHealth() - 1)
            ply:TakeDamageInfo(insta)

            timer.Simple(4, function()
                ents.GetMapCreatedEntity("2767"):Fire("Use")
            end)
        else
            timer.Simple(1, function()
                --[[for k, v in pairs(player.GetAll()) do
                    v:ChatPrint("Building power enabled, disabling backup generators...")
                end
                nzElec:Activate()]]
                StartGeneratorHumm()
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
            teleportAgain = sparkFlippedOption[randomValue].post
        elseif !sparkFlipped and nonSparkFlipped then
            randomValue = math.random(#nonSparkFlippedOption)
            SpecialTeleport(ply, nonSparkFlippedOption[randomValue].pos, nonSparkFlippedOption[randomValue].ang, 1)
            teleportAgain = nonSparkFlippedOption[randomValue].post
        else
            randomValue = math.random(#bothFlippedOption)
            SpecialTeleport(ply, bothFlippedOption[randomValue].pos, bothFlippedOption[randomValue].ang, 1)
            teleportAgain = bothFlippedOption[randomValue].post
        end
        
        if teleportAgain then
            teleportTimers = teleportTimers or {}
            teleportTimers[ply:SteamID()] = math.random(45, 75)
            net.Start("StartTeleportTimer")
                net.WriteInt(teleportTimers[ply:SteamID()], 16)
            net.Send(ply)

            timer.Create(ply:SteamID() .. "TeleportTimer", 1, 0, function()
                if !IsValid(ply) or !teleportTimers[ply:SteamID()] then 
                    timer.Remove(ply:SteamID() .. "TeleportTimer")
                end
                if teleportTimers[ply:SteamID()] == 0 or !ply:GetNotDowned() then
                    timer.Remove(ply:SteamID() .. "TeleportTimer")
                    SpecialTeleport(ply, spawnTeleport.pos, spawnTeleport.ang)
                    net.Start("UpdateTeleportTimer")
                        net.WriteInt(0, 16)
                    net.Send(ply)
                end

                teleportTimers[ply:SteamID()] = teleportTimers[ply:SteamID()] - 1
                net.Start("UpdateTeleportTimer")
                    net.WriteInt(teleportTimers[ply:SteamID()], 16)
                net.Send(ply)
            end)
        end
        return true
	end

    --Creates the elevator generator
    local gasLevel, generatorPowered = 0, false
    local gen = ents.Create("nz_script_prop")
    gen:SetPos(Vector(-2723, 1790, 27.5))
    gen:SetAngles(Angle(0, -90, 0))
    gen:SetModel("models/props_wasteland/laundry_washer003.mdl")
    gen:SetNWString("NZText", "You must fill this generator with gasoline to power it")
    gen:SetNWString("NZRequiredItem", "gascan")
    gen:SetNWString("NZHasText", "Press E to fuel this generator with gasoline")
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

            ply:RemoveCarryItem("gascan")
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

                    elDoor1:Fire("Unlock")
                    elDoor2:Fire("Unlock")
                    elDoor1:SetNWString("NZText", "")
                    elDoor2:SetNWString("NZText", "")
                    elButton:SetNWString("NZText", "")

                    --After the 9 second generator_start sound has played
                    timer.Simple(9, function()
                        elButton:Fire("Unlock")
                        elButton:Fire("Use")
                        elButton:SetNWString("NZText", "The elevator is being called up")
                        nzDoors:OpenLinkedDoors("d1")

                        gen:EmitSound("nz/effects/generator_humm.ogg")
                        timer.Create("GeneratorHumm", 3, 0, function()
                            if not gen then return end
                            gen:EmitSound("nz/effects/generator_humm.ogg")
                        end)
                    end)
                else
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

    --Sets up the map-spawned consoles to disable the combine wall after the long corridors
    mapscript.consoleButtons = {"1455", "2056", "1359", pressed = 0}
    for k, v in ipairs(mapscript.consoleButtons) do --Doesn't loop through .pressed as it's not indexed numerically
        local console = ents.GetMapCreatedEntity(v)
        console:SetNWString("NZText", "Currently in system lockdown")
        mapscript.consoleButtons[v] = false
        console.OnUsed = function()
            if !mapscript.onLockdown and !mapscript.consoleButtons[v] then
                mapscript.consoleButtons[v] = true
                mapscript.consoleButtons.pressed = mapscript.consoleButtons.pressed + 1
                console:SetNWString("NZText", "")
                console:EmitSound("buttons/button4.wav")
                if mapscript.consoleButtons.pressed == 3 then
                    timer.Simple(1, function()
                        local throwawayTab = {1, 3, 4}
                        net.Start("RunSound")
                            net.WriteString("ambient/machines/teleport" .. throwawayTab[math.random(#throwawayTab)] .. ".wav")
                        net.Broadcast()
                        wallBlock:Remove()
                    end)
                end
            end
        end
    end

    --Reset chalk messages, just in case we're playing again after the EE step that changes them
    net.Start("ResetChalkMessages")
    net.Broadcast()

    --Reset possible battery levels after a new game
    for k, v in pairs(player.GetAll()) do
        mapscript.batteryLevels[v:SteamID()] = 0
    end

	--Timer for checking battery levels
	timer.Create("BatteryChecks", 2, 0, function()
		for k, v in pairs(player.GetAll()) do
			if v:Alive() and mapscript.batteryLevels[v:SteamID()] then
				if mapscript.batteryLevels[v:SteamID()] == 0 then
					v:Flashlight(false) --turns off the flashlight
                    v:AllowFlashlight(false) --prevents the flashlight from changing states
                    v:RemoveCarryItem("battery")
				end
                if v:FlashlightIsOn() then
					mapscript.batteryLevels[v:SteamID()] = math.Approach(mapscript.batteryLevels[v:SteamID()], 0, -1)--[[math.Clamp(mapscript.batteryLevels[v:SteamID()] - 1, 0, 100)]]
					net.Start("SendBatteryLevel")
						net.WriteInt(mapscript.batteryLevels[v:SteamID()], 16)
					net.Send(v)
				end
			end
		end
	end)
end

function mapscript.OnRoundStart()
	--Redundant flashlight-setting, for when players join mid-game
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
            notSpawned[#notSpawned + 1] = {v, k}
        end
    end
    for k, v in pairs(player.GetAll()) do
        mapscript.batteryLevels[v:SteamID()] = mapscript.batteryLevels[v:SteamID()] or 0
    end
    
    newBat = notSpawned[math.random(#notSpawned)]
    local ent = ents.Create("nz_script_prop")
    ent:SetModel("models/zworld_equipment/zpile.mdl")
    ent:SetPos(newBat[1].pos)
    ent:SetAngles(newBat[1].ang)
    ent:Spawn()
    battery:RegisterEntity(ent)
    batteries[newBat[2]].ent = ent
    batteries[newBat[2]].spawned = true
    ent.charge = math.random(25, 80)
    ent:SetNWString("NZRequiredItem", "battery")
    ent:SetNWString("NZHasText", "Press E to add the battery to your flashlight.")

    --Redundantly remove the text, if a player joins in after the step as been completed
    if mapscript.bloodGodKills >= mapscript.bloodGodKillsGoal then
        net.Start("RunCoward")
        net.Broadcast()
    end
end

function mapscript.ElectricityOn()
    if !postFirstActivation then
        for k, v in pairs(player.GetAll()) do
            v:ChatPrint("Building power enabled, disabling backup generators...")
        end

        local colorEditor = ents.FindByClass("edit_color")[1]
        local contrastScale = 0.5 --This is the value it's set to in the config, we scale this value up here
        timer.Create("RemoveGrayscale", 0.5, 10, function()
            contrastScale = contrastScale + 0.05
            colorEditor:SetContrast(contrastScale)
        end)

        --ents.GetMapCreatedEntity("2767"):Fire("Use")
        mapscript.CombineConsole:SetNWString("NZText", "Press E to begin rescinding building system lockdown")

		timer.Simple(5, function()
            local fakeSwitch, fakeLever = ents.Create("nz_script_prop"), ents.Create("nz_script_prop")
            --Move the power lever and replace it with a fake one

            --ents.FindByClass("power_box")[1]:SetPos()
		end)
	end
	postFirstActivation = true
end

function mapscript.OnGameEnd()
    powerSwitch = ents.FindByClass("power_box")[1]
    if powerSwitch and IsValid(powerSwitch) then 
        powerSwitch:Remove()
    end

    ents.FindByClass("edit_color")[1]:SetContrast(0.5)
end

--[[	Any hooks    ]]

--This is used to check if players enter/leave areas zombies can't travel through, and will need to respawn
hook.Add("Think", "CNavAreaChecking", function()
    if nzRound:GetState() == ROUND_CREATE then
        return
    end
    mapscript.area1 = mapscript.area1 or 0
    mapscript.area2 = mapscript.area2 or 0
    mapscript.area3 = mapscript.area3 or 0
    mapscript.area4 = mapscript.area4 or 0

    local area1, area2, area3, area4 = 0, 0, 0, 0
    for k, v in pairs(player.GetAll()) do
        if v:Alive() then
            for _, tab in pairs(areasByVector[1]) do
                if v:GetPos():WithinAABox(tab.pos1, tab.pos2) then
                    area1 = area1 + 1
                end
            end

            for _, tab in pairs(areasByVector[2]) do
                if v:GetPos():WithinAABox(tab.pos1, tab.pos2) then
                    area2 = area2 + 1
                end
            end

            for _, tab in pairs(areasByVector[3]) do
                if v:GetPos():WithinAABox(tab.pos1, tab.pos2) then
                    area3 = area3 + 1
                end
            end

            for _, tab in pairs(areasByVector[4]) do
                if v:GetPos():WithinAABox(tab.pos1, tab.pos2) then
                    area4 = area4 + 1
                end
            end
        end
    end

    --Really ugly, as 4 big-ass if statements
    --I should call update() on the one spawner ent to force the change immediately, but it's done every 4 seconds anyway
    if area1 != mapscript.area1 then
        print("Player count mismatch in area 1, old value: " .. mapscript.area1 .. ", new value: " .. area1)
        mapscript.area1 = area1
        if area1 < 1 then
            for k, v in pairs(allZombieSpawns[1]) do
                v.disabled = true
            end
            CleanupZombies(1)
        else
            print("Enabling zombie spawns in area1")
            for k, v in pairs(allZombieSpawns[1]) do
                v.disabled = false
            end
        end
    end
    if area2 != mapscript.area2 then
        print("Player count mismatch in area 2, old value: " .. mapscript.area2 .. ", new value: " .. area2)
        mapscript.area2 = area2
        if area2 < 1 then
            for k, v in pairs(allZombieSpawns[2]) do
                v.disabled = true
            end
            CleanupZombies(2)
        else
            print("Enabling zombie spawns in area2")
            for k, v in pairs(allZombieSpawns[2]) do
                v.disabled = false
            end
        end
    end
    if area3 != mapscript.area3 then
        print("Player count mismatch in area 3, old value: " .. mapscript.area3 .. ", new value: " .. area3)
        mapscript.area3 = area3
        if area3 < 1 then
            for k, v in pairs(allZombieSpawns[3]) do
                v.disabled = true
            end
            CleanupZombies(3)
        else
            print("Enabling zombie spawns in area3")
            for k, v in pairs(allZombieSpawns[3]) do
                v.disabled = false
            end
        end
    end
    if area4 != mapscript.area4 then
        print("Player count mismatch in area 4, old value: " .. mapscript.area4 .. ", new value: " .. area4)
        mapscript.area4 = area4
        if area4 < 1 then
            for k, v in pairs(allZombieSpawns[4]) do
                v.disabled = true
            end
            CleanupZombies(4)
        else
            print("Enabling zombie spawns in area4")
            for k, v in pairs(allZombieSpawns[4]) do
                v.disabled = false
            end
        end
    end
end)

hook.Add("OnZombieSpawned", "AssignSpawnID", function(zom, spawner)
    zom.spawnZone = spawner.spawnZone
end)

hook.Add("PlayerUse", "PreventPull", function(ply, button)
    if button == mapscript.NewPowerSwitch and button.powerSwitchDelay then
        return false
    end
end)

--[[    Overwritten Functions    ]]

--Overwrites default function, enables the "disabling" of spawns, used when players enter a different area
function Spawner:UpdateWeights()
	local plys = player.GetAllTargetable()
	for _, spawn in pairs(self.tSpawns) do
		-- reset
        spawn:SetSpawnWeight(0)
        if !spawn.disabled then
            local weight = math.huge
            for _, ply in pairs(plys) do
                local dist = spawn:GetPos():DistToSqr(ply:GetPos())
                if dist < weight then
                    weight = dist
                end
            end
            spawn:SetSpawnWeight(100000000 / weight)
        end
	end
end

--Overwrites default function, fixes spawning issues related to spawn weights when close to areas with disabled spawns
function Spawner:GetAverageWeight()
    local sum = 0
    local count = 0
    for _, spawn in pairs(self.tSpawns) do
        if !spawn.disabled then
            sum = sum + spawn:GetSpawnWeight()
            count = count + 1
        end
	end
	return ((sum / count) * 0.5) + 1500
end

return mapscript

--[[
Test Effects:
Useful EE function:
	nzNotifications:PlaySound("")
	nzRound:Freeze(true) --Prevents switching and spawning

    Some notes:
    Config work:
    - Some walls, barricades, and props can be jumped over/on top of, need to finish placing wall blocks
    - Color editor needs to grayscale

    Script work:
    - CleanupZombies works incorrectly if you leave & re-enter the same area ID (no it's not? Don't know why it didn't work before)
    - Sound should play when unlocking padlock
    - Sound should play when picking up extra batteries
    - Should have players turn on the generator BEFORE turning on power, they find the keys in the teleport room, but the combine console is disabled because power's off
        - Generator humm? 
    - Combine doorway should emit a sound on loop: ambient/machines/combine_shield_loop3.wav
    - Lightning effect may not work properly on MAP-SPAWNED entities, potential work-around: just use the ent's position and don't set an ent, or recreate the ent but set it invisible

    Nav work:
    - Zombies get stuck in "shower"-like area
    - Large groups of zombies getting consistently stuck in doorways
        - Might be worth it to force zombie nocollide?
        - Zombies specifically get stuck in zap rooms

    Theory work:
    - Need more EE shit for after the long poison hallways
        - The ZapZombies buttons could be unlocked with some interactable by the Widow's Wine half of the map
            - It should also have steps that build up to it
            - This forces the ZapZombies step to be the FINAL step before the Boss spawn
    - There's too much back-and-forth
    - Basement levers should have some sort of hint
        - Argument: it takes too long to guess-and-check
    - Spawning a boss
        - Could spawn in the far end of the map, and moves through it, creating no-enter zones as he moves through it (forcing players towards the widow's wine area)
        - ent:SetSequence() - Sets an animation on a model
        - Needs to be a threat, somehow, that players should want to get rid of
    - Laby feedback:
        - The levers in the basement should hint that they're effecting the teleporting
        - Didn't realize the zap room was what killed zombies, or what he needed to do (zap room could include some wall text)
        - There should be a kill box in the vents area where you can fall into water
        - Hard to distinguish between hallways (landmarks to identify hallways/rooms by)
        - Suggests an RE boss
        - Wall hint at the end of the poison hallway, he got stuck

    My feelings against giving too many hints:
        Alot of the earliest easter egg events/triggers were really secretive and not hand-hold-y, and that's the feeling I'm trying to emulate. I want the players to struggle
        and really have to try and figure out what the fuck to do.
]]