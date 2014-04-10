AddCSLuaFile("shared.lua")
AddCSLuaFile("rounds/cl_round.lua")
AddCSLuaFile("points/sh_meta.lua")
AddCSLuaFile("config.lua")
include( "shared.lua" )
include( "config.lua" )

include( "rounds/sv_round.lua" )
include( "points/sh_meta.lua" )

function GM:PlayerSwitchFlashlight(ply, SwitchOn)
     return true
end

hook.Add("EntityTakeDamage", "dick", function( target, dmginfo )

    if ( target:IsPlayer() and dmginfo:GetAttacker():IsPlayer() ) then
		dmginfo:ScaleDamage( 0 )
    end
    
	return dmginfo
end)

hook.Add("PlayerInitialSpawn", "dick2", function( ply )
	if (conv.GetRoundState() == ROUND_PROG or conv.GetRoundState() == ROUND_PREP) then
		if bnpvbWJpZXM.Rounds.allowedPlayers[ply] == nil then
			timer.Simple(0, function() ply:Kill() end)
		end
	end
	
	timer.Simple(1, function() bnpvbWJpZXM.Rounds.Functions.SyncClients() end)
end)
 
 function GM:PlayerDeathThink( pl )

	if (  pl.NextSpawnTime && pl.NextSpawnTime > CurTime() ) then return end

	if ( pl:KeyPressed( IN_ATTACK ) || pl:KeyPressed( IN_ATTACK2 ) || pl:KeyPressed( IN_JUMP ) ) then

	if conv.GetRoundState() == ROUND_PROG or conv.GetRoundState() == ROUND_PREP or conv.GetRoundState() == ROUND_GO then
		pl:Spectate( OBS_MODE_IN_EYE )
		for k,v in pairs(player.GetAll()) do
			if v:Alive() and v != pl then
				pl:SpectateEntity( v )
			end
		end
		return false
	end
		pl:UnSpectate() 
		pl:Spawn()
	end

end

function SpawnEntities()
	if file.Exists( "nz/nz_"..game.GetMap( )..".txt", "DATA" ) then
		print("[NZ] MAP CONFIG FOUND!")
		local data = util.JSONToTable( file.Read( "nz/nz_"..game.GetMap( )..".txt", "DATA" ) )
		PrintTable(data)
		if data.BuyableBlockSpawns != nil then
			for k,v in pairs(data.BuyableBlockSpawns) do
				BuyableBlockSpawn(v.pos, v.angle, v.model)
			end
		end
		for k,v in pairs(data.WallBuys) do
			WeaponBuySpawn(v.pos,v.wep, v.price, v.angle)
		end
		for k,v in pairs(data.ZedSpawns) do
			if v.link == nil then
				ZedSpawn(v.pos, "0")
			else
				ZedSpawn(v.pos, v.link)
			end
		end
		for k,v in pairs(data.PlayerSpawns) do
			PlayerSpawn(v.pos)
		end
		for k,v in pairs(data.DoorSetup) do
			DoorSpawn(k, v.flags)
		end
		for k,v in pairs(data.BlockSpawns) do
			BlockSpawn(v.pos, v.angle, v.model)
		end
		for k,v in pairs(data.ElecSpawns) do
			ElecSpawn(v.pos, v.angle, v.model)
		end
		for k,v in pairs(data.RandomBoxSpawns) do
			RandomBoxSpawn(v.pos, v.angle)
		end
		if data.PerkMachineSpawns != nil then
			for k,v in pairs(data.PerkMachineSpawns) do
				PerkMachineSpawn(v.pos, v.angle, PerksColas[v.id])
			end
		end
	else
		print("[NZ] Warning: NO MAP CONFIG FOUND! Make a config in game using the /create command, then use /save to save it all!")
	end
end
hook.Add("InitPostEntity","SpawnTheProps",timer.Simple(1,SpawnEntities))

function WeaponBuySpawn(position, gun, price, angle)
	if weapons.Get(gun) != nil then
		local ent1 = ents.Create("wall_buy") 
		ent1:SetAngles(angle)
		local pos = position
		pos.z = pos.z - ent1:OBBMaxs().z
		ent1:SetWeapon(gun, price)
		ent1:SetPos( pos )
		ent1:Spawn()
	else
		print("SKIPPED "..gun.. ". Are you sure you have it installed?")
	end
end

function ZedSpawn(position, link)
	local ent1 = ents.Create("zed_spawns") 
	local pos = position
	pos.z = pos.z - ent1:OBBMaxs().z
	ent1:SetPos( pos )
	ent1:Spawn()
	ent1.Link = link
	table.insert(bnpvbWJpZXM.Rounds.ZedSpawns, {position, ent1})
end

function PlayerSpawn(position)
	local ent1 = ents.Create("player_spawns") 
	local pos = position
	pos.z = pos.z - ent1:OBBMaxs().z
	ent1:SetPos( pos )
	ent1:Spawn()
	table.insert(bnpvbWJpZXM.Rounds.PlayerSpawns, {position, ent1})
end

function RandomBoxSpawn(position, angle)
	local gun = ents.Create( "random_box_spawns" )
	gun:SetPos( position )
	gun:SetAngles( angle )
	gun:Spawn()
	gun:SetSolid( SOLID_VPHYSICS )
	gun:SetMoveType( MOVETYPE_NONE )
	
	table.insert(bnpvbWJpZXM.Rounds.RandomBoxSpawns, {position, angle, gun})
end

function ElecSpawn(pos, ang)
	local ent1 = ents.Create( "button_elec" )
	ent1:SetPos( pos )
	ent1:SetAngles( ang )
	ent1:Spawn()
	if bnpvbWJpZXM.Rounds.ElecButt[1] != nil then
		bnpvbWJpZXM.Rounds.ElecButt[1]:Remove()
	end
	bnpvbWJpZXM.Rounds.ElecButt[1] = ent1
end

function DoorSpawn(entindex,flags)
	bnpvbWJpZXM.Rounds.Doors[tonumber(entindex)] = flags
end

function BlockSpawn(pos,ang,model)
	local block = ents.Create( "wall_block" )
	block:SetModel( model )
	block:SetPos( pos )
	block:SetAngles( ang )
	block:Spawn()
	block:SetSolid( SOLID_VPHYSICS )
	block:SetMoveType( MOVETYPE_NONE )
	table.insert(bnpvbWJpZXM.Rounds.Blocks, block )
end

function BuyableBlockSpawn(pos,ang,model)
	local block = ents.Create( "wall_block_buy" )
	block:SetModel( model )
	block:SetPos( pos )
	block:SetAngles( ang )
	block:Spawn()
	block:SetSolid( SOLID_VPHYSICS )
	block:SetMoveType( MOVETYPE_NONE )
	table.insert(bnpvbWJpZXM.Rounds.BuyableBlocks, block )
end

function PerkMachineSpawn(position, angle, data)
	local perk = ents.Create( "perk_machine" )
	perk:SetPos( position )
	perk:SetAngles( angle )
	perk:Spawn()
	perk:SetSolid( SOLID_VPHYSICS )
	perk:SetMoveType( MOVETYPE_NONE )
	perk:SetTheMachine(data)
	
	table.insert(bnpvbWJpZXM.Rounds.PerkMachines, {position, angle, data.ID, perk})
end

hook.Add( "nzombies_elec_active", "open_all_elec_doors", function()
	for k,v in pairs(ents.GetAll()) do
		if v:IsDoor() then
			if v.Elec != nil then
				if tonumber(v.Elec) == 1 then
					v:DoorUnlock(1)
				end
			end
		end
	end
end )

util.AddNetworkString( "bnpvbWJpZXM_Elec_Sync" )
hook.Add( "nzombies_elec_active", "activate_all_elec", function()
	bnpvbWJpZXM.Rounds.Elec = true
	net.Start( "bnpvbWJpZXM_Elec_Sync" )
	net.Broadcast()
end )
