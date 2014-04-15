bnpvbWJpZXM.Rounds = {}
bnpvbWJpZXM.Rounds.CurrentState = ROUND_INIT
bnpvbWJpZXM.Rounds.CurrentRound = 0
bnpvbWJpZXM.Rounds.CurrentZombies = 0
bnpvbWJpZXM.Rounds.ZombiesSpawned = 0
bnpvbWJpZXM.Rounds.Curve = {}
bnpvbWJpZXM.Rounds.Curve.SpawnRate = {}
bnpvbWJpZXM.Rounds.Curve.Health = {}
bnpvbWJpZXM.Rounds.Curve.Speed = {}
bnpvbWJpZXM.Rounds.Functions = {}
bnpvbWJpZXM.Rounds.Effects = {}
bnpvbWJpZXM.Rounds.Effects["dp"] = false
bnpvbWJpZXM.Rounds.ZedSpawns = {}
bnpvbWJpZXM.Rounds.PlayerSpawns = {}
bnpvbWJpZXM.Rounds.Doors = {}
bnpvbWJpZXM.Rounds.Blocks = {}
bnpvbWJpZXM.Rounds.ElecButt = {}
bnpvbWJpZXM.Rounds.Elec = false 
bnpvbWJpZXM.Rounds.RandomBoxSpawns = {}
bnpvbWJpZXM.Rounds.allowedPlayers = {}
bnpvbWJpZXM.Rounds.PerkMachines = {}

bnpvbWJpZXM.Rounds.BuyableBlocks = {}

bnpvbWJpZXM.Rounds.OpenedLinks = {}

bnpvbWJpZXM.Rounds.EasterEggs = {}
bnpvbWJpZXM.Rounds.EggCount = 0

local plyColours = {}


function bnpvbWJpZXM.Rounds.Functions.GenerateCurve()
	for i=1, 100 do
		bnpvbWJpZXM.Rounds.Curve.SpawnRate[i-1] = math.Round(bnpvbWJpZXM.Config.BaseDifficultySpawnRateCurve*math.pow(i-1,bnpvbWJpZXM.Config.DifficultySpawnRateCurve))
		bnpvbWJpZXM.Rounds.Curve.Health[i-1] = math.Round(bnpvbWJpZXM.Config.BaseDifficultyHealthCurve*math.pow(i-1,bnpvbWJpZXM.Config.DifficultyHealthCurve))
		bnpvbWJpZXM.Rounds.Curve.Speed[i-1] = math.Round(bnpvbWJpZXM.Config.BaseDifficultySpeedCurve*math.pow(i-1,bnpvbWJpZXM.Config.DifficultySpeedCurve))
	end
end
local ready = {}
function bnpvbWJpZXM.Rounds.Functions.CheckPrerequisites()		
	if #player.GetAll() >= 1 then
		local count = 0
		for k,v in pairs(player.GetAll()) do
			if v.Ready == 1 and v:IsValid() and v:Alive() then
				count = count + 1
			end
		end
		if count / #player.GetAll() < bnpvbWJpZXM.Config.ReadyupPerc then
			return false
		end
	else
		return false
	end
	if #bnpvbWJpZXM.Rounds.ZedSpawns == 0 then
		for k,v in pairs(player.GetAll()) do
			if v.Ready == 1 then
				v.Ready = 0
				v:PrintMessage( HUD_PRINTTALK, "You have been set to un-ready since the map does have any zombie spawns placed." )
			end
		end
		return false
	end
	
	if !weapons.Get(bnpvbWJpZXM.Config.BaseStartingWeapon) then
		for k,v in pairs(player.GetAll()) do
			if v.Ready == 1 then
				v.Ready = 0
				v:PrintMessage( HUD_PRINTTALK, "You have been set to un-ready since the server owner has not set the starting weapon to a valid weapon." )
				v:PrintMessage( HUD_PRINTTALK, "Please change bnpvbWJpZXM.Config.BaseStartingWeapon in the gamemode's config.lua" )
			end
		end
		return false
	end
	
	if game.SinglePlayer() then
		for k,v in pairs(player.GetAll()) do
			if v.Ready == 1 then
				v.Ready = 0
				v:PrintMessage( HUD_PRINTTALK, "You have been set to un-ready the game is being run in Single Player." )
				v:PrintMessage( HUD_PRINTTALK, "Please start this gamemode in multiplayer. Even if you're playing alone." )
			end
		end
		return false
	end
	
	return true
end

function chatCommand( ply, text, public )
    if (string.sub(text, 1, 6) == "/ready") then
		PrintMessage( HUD_PRINTTALK, ply:Nick().." is ready!" )
         ply.Ready = 1
         return false
	elseif (string.sub(text, 1, 8) == "/unready") then
		PrintMessage( HUD_PRINTTALK, ply:Nick().." is no longer ready!" )
		ply.Ready = 0
        return false
	elseif (string.sub(text, 1, 7) == "/create") then
		if ply:IsSuperAdmin() then
			bnpvbWJpZXM.Rounds.Functions.CreateMode()
		end
        return false 
	elseif (string.sub(text, 1, 7) == "/save") then
		if ply:IsSuperAdmin() then
			bnpvbWJpZXM.Rounds.Functions.SaveConfig()
		end
        return false 
	elseif (string.sub(text, 1, 14) == "/forcegenerate") then	
		if ply:IsSuperAdmin() then
			local ent = ents.Create("info_player_start")
			ent:SetPos(ply:GetPos())
			ent:Spawn()
			RunConsoleCommand("nav_generate")
		end
		return false 
	elseif (string.sub(text, 1, 9) == "/generate") then	
		if ply:IsSuperAdmin() then
			RunConsoleCommand("nav_generate")
		end
		return false 
    end
end
hook.Add( "PlayerSay", "chatCommand", chatCommand )

function bnpvbWJpZXM.Rounds.Functions.SaveConfig()
	local main = {}
	
	local wall_buys = {}
	for k,v in pairs(ents.FindByClass("wall_buy")) do
		table.insert(wall_buys, {
		pos = v:GetPos(),
		wep = v.WeaponGive,
		price = v.Price,
		angle = v:GetAngles( ),
		})
	end
	local zed_spawns = {}
	for k,v in pairs(ents.FindByClass("zed_spawns")) do
		table.insert(zed_spawns, {
		pos = v:GetPos(),
		link = v.Link
		})
	end
	local player_spawns = {}
	for k,v in pairs(ents.FindByClass("player_spawns")) do
		table.insert(player_spawns, {
		pos = v:GetPos(),
		})
	end
	local door_setup = {}
	for k,v in pairs(bnpvbWJpZXM.Rounds.Doors) do
		door_setup[k] = {
		flags = v,
		}
	end
	local block_spawns = {}
	for k,v in pairs(bnpvbWJpZXM.Rounds.Blocks) do
		table.insert(block_spawns, {
		pos = v:GetPos(),
		angle = v:GetAngles( ),
		model = v:GetModel(),
		})
	end
	local elec_spawn = {}
	for k,v in pairs(bnpvbWJpZXM.Rounds.ElecButt) do
		table.insert(elec_spawn, {
		pos = v:GetPos(),
		angle = v:GetAngles( ),
		model = v:GetModel(),
		})
	end
	//Changed to allow for the physgun changes to apply to the save
	local randombox_spawn = {}
	for k,v in pairs(ents.FindByClass("random_box_spawns")) do
		table.insert(randombox_spawn, {
		pos = v:GetPos(),
		angle = v:GetAngles(),
		})
	end
	local perk_machinespawns = {}
	for k,v in pairs(ents.FindByClass("perk_machine")) do
		table.insert(perk_machinespawns, {
		pos = v:GetPos(),
		angle = v:GetAngles( ),
		id = v:GetPerkID(),
		})
	end
	// End Change ////////////////////////////////
	local buyableblock_spawns = {}
	for k,v in pairs(bnpvbWJpZXM.Rounds.BuyableBlocks) do
		table.insert(buyableblock_spawns, {
		pos = v:GetPos(),
		angle = v:GetAngles( ),
		model = v:GetModel(),
		})
	end
	local eggs = {}
	for k,v in pairs(ents.FindByClass("easter_egg")) do
		table.insert(eggs, {
		pos = v:GetPos(),
		angle = v:GetAngles( ),
		model = v:GetModel(),
		})
	end
	main["WallBuys"] = wall_buys
	main["ZedSpawns"] = zed_spawns
	main["PlayerSpawns"] = player_spawns
	main["DoorSetup"] = door_setup
	main["BlockSpawns"] = block_spawns
	main["BuyableBlockSpawns"] = buyableblock_spawns
	main["ElecSpawns"] = elec_spawn
	main["RandomBoxSpawns"] = randombox_spawn
	main["PerkMachineSpawns"] = perk_machinespawns
	main["EasterEggs"] = eggs
	file.Write( "nz_"..game.GetMap( ).."_"..os.date("%M_%H_%j")..".txt", util.TableToJSON( main ) )
	PrintMessage( HUD_PRINTTALK, "[NZ] Saved to garrysmod/data/".."nz_"..game.GetMap( ).."_"..os.date("%M_%H_%j")..".txt" )
	PrintMessage( HUD_PRINTTALK, "[NZ] Rename the config to nz_"..game.GetMap( )..".txt and place in garrysmod/data/nz/" )
end

util.AddNetworkString( "bnpvbWJpZXM_Round_Sync" )
util.AddNetworkString( "bnpvbWJpZXM_Doors_Sync" )

function bnpvbWJpZXM.Rounds.Functions.SyncClients()
	net.Start( "bnpvbWJpZXM_Round_Sync" )
		net.WriteString( bnpvbWJpZXM.Rounds.CurrentState )
		net.WriteString( bnpvbWJpZXM.Rounds.CurrentRound )
		net.WriteTable( plyColours )
		net.WriteTable( bnpvbWJpZXM.Rounds.allowedPlayers )
	net.Broadcast()
	
	net.Start( "bnpvbWJpZXM_Doors_Sync" )
		net.WriteTable( bnpvbWJpZXM.Rounds.Doors )
	net.Broadcast()
	
	net.Start( "bnpvbWJpZXM_Elec_Sync" )
	net.Broadcast()
end

function bnpvbWJpZXM.Rounds.Functions.PrepareRound()
	bnpvbWJpZXM.Rounds.CurrentState = ROUND_PREP
	bnpvbWJpZXM.Rounds.Functions.SyncClients()
	bnpvbWJpZXM.Rounds.CurrentRound = bnpvbWJpZXM.Rounds.CurrentRound + 1
	bnpvbWJpZXM.Rounds.CurrentZombies = bnpvbWJpZXM.Rounds.Curve.SpawnRate[bnpvbWJpZXM.Rounds.CurrentRound]
	PrintMessage( HUD_PRINTTALK, "ROUND: "..bnpvbWJpZXM.Rounds.CurrentRound.." preparing" )
	//wait 15 seconds or something
	//Spawn all dead players
	if (!bnpvbWJpZXM.Config.Hardcore) then
		for k,v in pairs(player.GetAll()) do
			if ((bnpvbWJpZXM.Config.AllowDropins or bnpvbWJpZXM.Rounds.allowedPlayers[v] != nil) and !v:Alive()) then
				if (bnpvbWJpZXM.Rounds.allowedPlayers[v]==nil) then
					bnpvbWJpZXM.Rounds.allowedPlayers[v] = true
					v:SetPoints(bnpvbWJpZXM.Config.BaseStartingPoints + (bnpvbWJpZXM.Rounds.CurrentRound*bnpvbWJpZXM.Config.PerRoundPoints))
					plyColours[v] = Color(math.random(0,255), math.random(0,255), math.random(0,255), 255)
				end
				v:UnSpectate()
				v:Spawn()
				v:Give(bnpvbWJpZXM.Config.BaseStartingWeapon)
				v:SetAmmo(bnpvbWJpZXM.Config.BaseStartingAmmoAmount, weapons.Get(bnpvbWJpZXM.Config.BaseStartingWeapon).Primary.Ammo)
				v:SetPos(bnpvbWJpZXM.Rounds.PlayerSpawns[k][1] + Vector(0,0,20))
			end
		end
	end
	timer.Simple(bnpvbWJpZXM.Config.PrepareTime, function() bnpvbWJpZXM.Rounds.Functions.StartRound() end)
	local function checkVer()
		http.Fetch( "https://raw.githubusercontent.com/Alig96/nzombies/master/version.txt",
			function( body, len, headers, code )
				if tonumber(file.Read( "gamemodes/nzombies/version.txt", "GAME" )) < tonumber(body) then
					print("Your version of nZombies is outdated. Please update via Github.")
				end
			end,
			function( error )
				print("Version Check Failed!")
			end
		)
	end
	checkVer()

end

function bnpvbWJpZXM.Rounds.Functions.StartRound()
	bnpvbWJpZXM.Rounds.CurrentState = ROUND_PROG
	bnpvbWJpZXM.Rounds.Functions.SyncClients()
	bnpvbWJpZXM.Rounds.ZombiesSpawned = 0
	PrintMessage( HUD_PRINTTALK, "ROUND: "..bnpvbWJpZXM.Rounds.CurrentRound.." started" )
	
	//Start Spawning Zombies
end

function bnpvbWJpZXM.Rounds.Functions.EndRound()
	bnpvbWJpZXM.Rounds.CurrentState = ROUND_GO
	bnpvbWJpZXM.Rounds.Functions.SyncClients()
	bnpvbWJpZXM.Rounds.ZombiesSpawned = 0
	PrintMessage( HUD_PRINTTALK, "GAME OVER!" )
	PrintMessage( HUD_PRINTTALK, "Restarting in 10 seconds!" )
	timer.Simple(10, function()
		PrintMessage( HUD_PRINTTALK, "GAME READY!" )
		bnpvbWJpZXM.Rounds.CurrentState = ROUND_INIT
		bnpvbWJpZXM.Rounds.Functions.SyncClients()
		bnpvbWJpZXM.Rounds.CurrentRound = 0
		bnpvbWJpZXM.Rounds.CurrentZombies = 0
		bnpvbWJpZXM.Rounds.ZombiesSpawned = 0
		bnpvbWJpZXM.Rounds.Elec = false 
		for k,v in pairs(player.GetAll()) do
			v.Ready = 0
			v:SetPoints(0)
			v:Spawn()
			v:SendLua('RunConsoleCommand("stopsound")')
		end
		for k,v in pairs(ents.FindByClass("easter_egg")) do
			v.Used = false
		end
		for k,v in pairs(bnpvbWJpZXM.Config.ValidEnemies) do
			for k2,v2 in pairs(ents.FindByClass(v)) do
				v2:Remove()
			end
		end
		for k,v in pairs(ents.GetAll()) do
			if v:IsDoor() then
				v:DoorUnlock()
			end
			if v:GetClass() == "button_elec" then
				v.On = false
			end
		end
		for k,v in pairs(ents.FindByClass("random_box")) do
			v:Remove()
		end
		if bnpvbWJpZXM.Config.AllowServerPasswordLocking then
			print("Server unlocked for the new round!")
			RunConsoleCommand("sv_password", "" )
		end
		RunConsoleCommand("hostname", bnpvbWJpZXM.Config.ServerName)
	end)
	//Start Spawning Zombies
end

function bnpvbWJpZXM.Rounds.Functions.CreateMode()
	if bnpvbWJpZXM.Rounds.CurrentState == ROUND_INIT then
		PrintMessage( HUD_PRINTTALK, "The mode has been set to creative mode!" )
		bnpvbWJpZXM.Rounds.CurrentState = ROUND_CREATE
		bnpvbWJpZXM.Rounds.CurrentZombies = 0
		bnpvbWJpZXM.Rounds.Functions.SyncClients()
	elseif bnpvbWJpZXM.Rounds.CurrentState == ROUND_CREATE then
		PrintMessage( HUD_PRINTTALK, "The mode has been set to play mode!" )
		bnpvbWJpZXM.Rounds.CurrentState = ROUND_INIT
		bnpvbWJpZXM.Rounds.CurrentZombies = 0
		for k,v in pairs(player.GetAll()) do
			v:StripWeapon("weapon_physgun")
			v:StripWeapon("gmod_tool_wepbuy")
			v:StripWeapon("gmod_tool_playerspawns")
			v:StripWeapon("gmod_tool_zedspawns")
			v:StripWeapon("gmod_tool_doors")
			v:StripWeapon("gmod_tool_block")
			v:StripWeapon("gmod_tool_elec")
			v:StripWeapon("gmod_tool_randomboxspawns")
			v:StripWeapon("gmod_tool_perkmachinespawns")
			v:StripWeapon("gmod_tool_buyabledebris")
			v:StripWeapon("gmod_tool_ee")
		end
		bnpvbWJpZXM.Rounds.Functions.SyncClients()
	else
		return
	end
end

function conv.GetRoundState()
	return bnpvbWJpZXM.Rounds.CurrentState
end

function bnpvbWJpZXM.Rounds.Functions.RoundHandler()
	if bnpvbWJpZXM.Rounds.CurrentState == ROUND_INIT then
		if bnpvbWJpZXM.Rounds.Functions.CheckPrerequisites() then
			table.Empty(plyColours)
			table.Empty(bnpvbWJpZXM.Rounds.allowedPlayers)
			table.Empty(bnpvbWJpZXM.Rounds.OpenedLinks)
			table.insert(bnpvbWJpZXM.Rounds.OpenedLinks, "0")
			bnpvbWJpZXM.Rounds.EggCount = 0
			if bnpvbWJpZXM.Config.AllowServerName then
				RunConsoleCommand("hostname", bnpvbWJpZXM.Config.ServerNameProg..bnpvbWJpZXM.Config.ServerName)
			end
			if bnpvbWJpZXM.Config.AllowServerPasswordLocking then
				local pword = util.Base64Encode( CurTime() )
				print("Server locked for round! Emergency Password is: "..pword)
				RunConsoleCommand("sv_password", pword )
			end
			for k,v in pairs(player.GetAll()) do
				if bnpvbWJpZXM.Rounds.PlayerSpawns != nil then
					if #bnpvbWJpZXM.Rounds.PlayerSpawns >= #player.GetAll() then
						v:SetPos(bnpvbWJpZXM.Rounds.PlayerSpawns[k][1] + Vector(0,0,20))
					else
						print("Not enough player spawns! Not forcing player spawns.")
					end
				end
				
				bnpvbWJpZXM.Rounds.allowedPlayers[v] = true
				v:SetPoints(bnpvbWJpZXM.Config.BaseStartingPoints)
				v:Give(bnpvbWJpZXM.Config.BaseStartingWeapon)
				v:GiveAmmo(bnpvbWJpZXM.Config.BaseStartingAmmoAmount, weapons.Get(bnpvbWJpZXM.Config.BaseStartingWeapon).Primary.Ammo)
				plyColours[v] = Color(math.random(0,255), math.random(0,255), math.random(0,255), 255)
				if bnpvbWJpZXM.Config.PlayerModels[1] != nil then
					if !bnpvbWJpZXM.Config.PlayerModelsSystem then
						v:SetModel(table.Random(bnpvbWJpZXM.Config.PlayerModels))
					else
						if bnpvbWJpZXM.Config.PlayerModels[k] != nil then
							v:SetModel(bnpvbWJpZXM.Config.PlayerModels[k])
						else
							//Fall back if there's not enough models
							v:SetModel(table.Random(bnpvbWJpZXM.Config.PlayerModels))
						end
					end
				end
			end
			
			if bnpvbWJpZXM.Rounds.RandomBoxSpawns[1] != nil then
				local rand = table.Random(bnpvbWJpZXM.Rounds.RandomBoxSpawns)
				local box = ents.Create( "random_box" )
				box:SetPos( rand[1] )
				box:SetAngles( rand[2] )
				box:Spawn()
				box:SetSolid( SOLID_VPHYSICS )
				box:SetMoveType( MOVETYPE_NONE )
			end
			
			for k,v in pairs(ents.GetAll()) do
				if v:IsDoor() then
					v:SetUseType( SIMPLE_USE )
					v:DoorLock()
					v:SetKeyValue("wait",-1)
				end
			end
			//Apply door settings
			for k,v in pairs(bnpvbWJpZXM.Rounds.Doors) do
				local door = ents.GetByIndex(k + game.MaxPlayers())
				local ex = string.Explode( ",", v )
				if door:IsDoor() then
					for k2,v2 in pairs(ex) do
						local ex2 = string.Explode( "=", v2 )
						if ex2[1] == "price" and ex2[2] == "0" then
							door:DoorUnlock(1)
						end
						if ex2[1] == "price" then
							door.Price = ex2[2]
						end
						if ex2[1] == "elec" then
							door.Elec = ex2[2]
						end
						if ex2[1] == "link" then
							door.Link = ex2[2]
						end
					end
				else
					print("error not a door")
				end
			end
			bnpvbWJpZXM.Rounds.Functions.PrepareRound()
		else
			return
		end
	elseif bnpvbWJpZXM.Rounds.CurrentState == ROUND_CREATE then
		for k,v in pairs(player.GetAll()) do
			if v.Ready == 1 then
				v.Ready = 0
				v:PrintMessage( HUD_PRINTTALK, "You have been set to un-ready since the game has been set to creative mode" )
				v:Give("weapon_physgun")
				v:Give("gmod_tool_wepbuy")
				v:Give("gmod_tool_playerspawns")
				v:Give("gmod_tool_zedspawns")
				v:Give("gmod_tool_doors")
				v:Give("gmod_tool_block")
				v:Give("gmod_tool_elec")
				v:Give("gmod_tool_randomboxspawns")
				v:Give("gmod_tool_perkmachinespawns")
				v:Give("gmod_tool_buyabledebris")
				v:Give("gmod_tool_ee")
			end
			if v:IsSuperAdmin() then
				v:Give("weapon_physgun")
				v:Give("gmod_tool_wepbuy")
				v:Give("gmod_tool_playerspawns")
				v:Give("gmod_tool_zedspawns")
				v:Give("gmod_tool_doors")
				v:Give("gmod_tool_block")
				v:Give("gmod_tool_elec")
				v:Give("gmod_tool_randomboxspawns")
				v:Give("gmod_tool_perkmachinespawns")
				v:Give("gmod_tool_buyabledebris")
				v:Give("gmod_tool_ee")
			end
		end
		return
	end
	
	local function checkAlive()
		//Check alive players!
		for k,v in pairs(player.GetAll()) do
			if v:Alive() then
				return true
			end
		end
		return false
	end
	
	if !checkAlive() and (conv.GetRoundState() == ROUND_PROG or conv.GetRoundState() == ROUND_PREP) then
		print("ending round!")
		bnpvbWJpZXM.Rounds.Functions.EndRound()
	end
	
	//Check the NPCs on the map.
	if bnpvbWJpZXM.Rounds.CurrentZombies <= 0 and bnpvbWJpZXM.Rounds.CurrentState == ROUND_PROG then
		bnpvbWJpZXM.Rounds.Functions.PrepareRound()
	end
end

function bnpvbWJpZXM.Rounds.Functions.ZombieSpawner()
	if bnpvbWJpZXM.Rounds.ZombiesSpawned >= bnpvbWJpZXM.Rounds.CurrentZombies or bnpvbWJpZXM.Rounds.ZombiesSpawned >= bnpvbWJpZXM.Config.MaxZombiesSim then
		
	else
		if bnpvbWJpZXM.Rounds.CurrentState == ROUND_PROG then
			local function CheckIfSuitable(pos)
				local Ents = ents.FindInBox( pos + Vector( -16, -16, 0 ), pos + Vector( 16, 16, 64 ) )
				local Blockers = 0
				if Ents == nil then return true end
				for k, v in pairs( Ents ) do
					if ( IsValid( v ) and (v:GetClass() == "player" or table.HasValue(bnpvbWJpZXM.Config.ValidEnemies, v:GetClass())) ) then
						Blockers = Blockers + 1
					end
				end
				if Blockers == 0 then
					return true
				end
				return false
			end
			local valids = {}
			//make a table of valid spawns
			for k,v in pairs(bnpvbWJpZXM.Rounds.ZedSpawns) do
				if table.HasValue(bnpvbWJpZXM.Rounds.OpenedLinks, v[2].Link) then
					for k2,v2 in pairs(ents.FindInSphere(v[2]:GetPos(), 1000)) do
						if v2:IsPlayer() then
							table.insert(valids, v)
							break
						end
					end
				end
			end					

			local position = table.Random(valids)[1]
			//local realPos = position + Vector(math.random(-256, 256), math.random(-256, 256), 75)
			if CheckIfSuitable(position) then
				local typ = "nut_zombie"
				if bnpvbWJpZXM.Config.UseCustomEnemmies then
					for i = bnpvbWJpZXM.Rounds.CurrentRound, 0, -1 do 
						if bnpvbWJpZXM.Config.EnemyTypes[i] != nil then
							//http://snippets.luacode.org/snippets/Weighted_random_choice_104
							local function weighted_total(choices)
								local total = 0
								for choice, weight in pairs(choices) do
									total = total + weight
								end
								return total
							end
							local function weighted_random_choice( choices )
								local threshold = math.random(0, weighted_total(choices))
								local last_choice
								for choice, weight in pairs(choices) do
									threshold = threshold - weight
								if threshold <= 0 then return choice end
									last_choice = choice
								end
								return last_choice
							end

							typ = weighted_random_choice(bnpvbWJpZXM.Config.EnemyTypes[i])
						end
					end
				end
				local zombie = ents.Create(typ)
				zombie:SetPos(position)
				zombie:Spawn()
				zombie:Activate()
				bnpvbWJpZXM.Rounds.ZombiesSpawned = bnpvbWJpZXM.Rounds.ZombiesSpawned + 1
			end
		end
	end
end
timer.Create("bnpvbWJpZXM.Rounds.ZombieSpawner", 1, 0, bnpvbWJpZXM.Rounds.Functions.ZombieSpawner)

timer.Create("bnpvbWJpZXM.Rounds.handler", 1, 0, bnpvbWJpZXM.Rounds.Functions.RoundHandler)

hook.Add( "Initialize", "Some unique name", function()
	bnpvbWJpZXM.Rounds.Functions.GenerateCurve()
	PrintTable(bnpvbWJpZXM.Rounds.Curve)
end )
