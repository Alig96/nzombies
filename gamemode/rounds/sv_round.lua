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
		for k,v in pairs(player.GetAll()) do
			if v.Ready != 1 or !v:IsValid() or !v:Alive() then
				return false
			end
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
	local randombox_spawn = {}
	for k,v in pairs(bnpvbWJpZXM.Rounds.RandomBoxSpawns) do
		table.insert(randombox_spawn, {
		pos = v[1],
		angle = v[2],
		})
	end
	main["WallBuys"] = wall_buys
	main["ZedSpawns"] = zed_spawns
	main["PlayerSpawns"] = player_spawns
	main["DoorSetup"] = door_setup
	main["BlockSpawns"] = block_spawns
	main["ElecSpawns"] = elec_spawn
	main["RandomBoxSpawns"] = randombox_spawn
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
	net.Broadcast()
	
	net.Start( "bnpvbWJpZXM_Doors_Sync" )
		net.WriteTable( bnpvbWJpZXM.Rounds.Doors )
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
	for k,v in pairs(player.GetAll()) do
		if !v:Alive() and bnpvbWJpZXM.Rounds.allowedPlayers[v] != nil then
			v:UnSpectate() 
			v:Spawn()
			v:Give(bnpvbWJpZXM.Config.BaseStartingWeapon)
			v:GiveAmmo(bnpvbWJpZXM.Config.BaseStartingAmmoAmount, weapons.Get(bnpvbWJpZXM.Config.BaseStartingWeapon).Primary.Ammo)
			v:SetPos(bnpvbWJpZXM.Rounds.PlayerSpawns[k][1] + Vector(0,0,20))
		end
	end
	timer.Simple(10, function() bnpvbWJpZXM.Rounds.Functions.StartRound() end)
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
		end
		for k,v in pairs(ents.FindByClass("nut_zombie")) do
			v:Remove()
		end
		for k,v in pairs(ents.FindByClass("nut_slow_zombie")) do
			v:Remove()
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
			RunConsoleCommand("hostname", bnpvbWJpZXM.Config.ServerName)
		end
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
			v:StripWeapon("gmod_tool_wepbuy")
			v:StripWeapon("gmod_tool_playerspawns")
			v:StripWeapon("gmod_tool_zedspawns")
			v:StripWeapon("gmod_tool_doors")
			v:StripWeapon("gmod_tool_block")
			v:StripWeapon("gmod_tool_elec")
			v:StripWeapon("gmod_tool_randomboxspawns")
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
				v:Give("gmod_tool_wepbuy")
				v:Give("gmod_tool_playerspawns")
				v:Give("gmod_tool_zedspawns")
				v:Give("gmod_tool_doors")
				v:Give("gmod_tool_block")
				v:Give("gmod_tool_elec")
				v:Give("gmod_tool_randomboxspawns")
			end
			if v:IsSuperAdmin() then
				v:Give("gmod_tool_wepbuy")
				v:Give("gmod_tool_playerspawns")
				v:Give("gmod_tool_zedspawns")
				v:Give("gmod_tool_doors")
				v:Give("gmod_tool_block")
				v:Give("gmod_tool_elec")
				v:Give("gmod_tool_randomboxspawns")
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
					if ( IsValid( v ) and (v:GetClass() == "player" or v:GetClass() == "nut_zombie" or v:GetClass() == "nut_slow_zombie") ) then
						Blockers = Blockers + 1
					end
				end
				if Blockers == 0 then
					return true
				end
				return false
			end
			
			local position = table.Random(bnpvbWJpZXM.Rounds.ZedSpawns)[1]
			//local realPos = position + Vector(math.random(-256, 256), math.random(-256, 256), 75)
			if CheckIfSuitable(position) then
				local typ = "nut_zombie"
				if bnpvbWJpZXM.Rounds.CurrentRound > 4 then
					typ = "nut_zombie"
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
