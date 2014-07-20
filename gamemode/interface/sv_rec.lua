nz.Interface = {}

//Door Interface
util.AddNetworkString( "nz_int_doors" )

//Server to client
function nz.Interface.ReqDoors( ply, door )
	net.Start( "nz_int_doors" )
		net.WriteEntity(door)
	net.Send( ply )
end

//Client to Server
net.Receive( "nz_int_doors", function( len )
	local door = net.ReadEntity()
	local flagStr = net.ReadString()
	if door:GetClass() == "wall_block_buy" then
		nz.Doors.Functions.CreateLinkSpec( door, flagStr )
	else
		nz.Doors.Functions.CreateLink( door:doorIndex(), flagStr )
	end
end )

// END DOOR //

//Weapon Buy Interface
util.AddNetworkString( "nz_int_wepbuy" )

//Server to client
function nz.Interface.ReqWepBuy( ply, vec, ang )
	net.Start( "nz_int_wepbuy" )
		net.WriteVector( vec )
		net.WriteAngle( ang )
	net.Send( ply )
end

//Client to Server
net.Receive( "nz_int_wepbuy", function( len )
	local vec = net.ReadVector()
	local ang = net.ReadAngle()
	local class = net.ReadString()
	local price = tonumber(net.ReadString())
	WeaponBuySpawn(vec, class, price, ang)
end )

// END Weapon Buy //

//Load Map Interface
util.AddNetworkString( "nz_int_mapconfig" )

//Server to client
function nz.Interface.ReqMapConfig( ply )
	local files = file.Find( "nz/nz_"..game.GetMap( ).."*", "DATA" )
	net.Start( "nz_int_mapconfig" )
		net.WriteTable(files)
	net.Send( ply )
end

//Client to Server
net.Receive( "nz_int_mapconfig", function( len )
	local selected = net.ReadString()
	local Sep = string.Explode(".", selected)
	nz.Mapping.Functions.LoadConfig( Sep[1] )
end )

// END Load Map Interface //

//Zombie Tool
util.AddNetworkString( "nz_int_zombiespawn" )

//Server to client
function nz.Interface.ReqZombieLink( ply, ent )
	net.Start( "nz_int_zombiespawn" )
		net.WriteEntity( ent )
		net.WriteString( ent.Link )
	net.Send( ply )
end

//Client to Server
net.Receive( "nz_int_zombiespawn", function( len )
	local spawn = net.ReadEntity()
	local link = net.ReadString()
	if link == "nil" then
		spawn.Link = 0
	else
		spawn.Link = link
	end
	print("Link Changed!")
end )

// END Zombie Tool //

//Starting weapons //
util.AddNetworkString( "nz_int_startweps" )

//Server to client
function nz.Interface.ReqStartingWeps( ply )
	//Redundant
	if true then return end
	net.Start( "nz_int_startweps" )
		net.WriteString(tostring(nz.Config.CustomConfigStartingWeps))
		net.WriteTable(nz.Config.BaseStartingWeapons)
	net.Send( ply )

end

//Client to Server
net.Receive( "nz_int_startweps", function( len )
	local bt = tobool(net.ReadString())
	local tbl = net.ReadTable()
	nz.Config.CustomConfigStartingWeps = bt
	nz.Config.BaseStartingWeapons = tbl
end )

// END Starting weapons //

//Perk Machines //
util.AddNetworkString( "nz_int_perks" )

//Server to client
function nz.Interface.ReqPerks( ply )
	
	net.Start( "nz_int_perks" )
	net.Send( ply )

end

//Client to Server
net.Receive( "nz_int_perks", function( len, client )
	local id = net.ReadString()
	local gun = client:GetWeapon("gmod_tool_perkmachinespawns")
	gun.PerkID = id
	gun.SwitchModel = nz.Perks.Get(id).model
	gun:ReleaseGhostEntity()
end )

// END Perk Machines //

// Config Changer //
util.AddNetworkString( "nz_int_configchanger" )

//Server to client
function nz.Interface.ReqConfigChange( ply )
	local ConfigChangerTbl = table.Copy(nz.Config)
	//Convert all tables to strings
	for k,v in pairs(ConfigChangerTbl) do
		if type(v) == "table" then
			ConfigChangerTbl[k] = util.TableToJSON(v)
		else
			ConfigChangerTbl[k] = tostring(v)
		end
	end
	net.Start( "nz_int_configchanger" )
		net.WriteTable( ConfigChangerTbl )
	net.Send( ply )

end

//Client to Server
net.Receive( "nz_int_configchanger", function( len, client )
	local tbl = net.ReadTable()
	//Parse
	for k,v in pairs(tbl) do
		if v == "true" then
			tbl[k] = true
		elseif v == "false" then
			tbl[k] = false
		else
			local char = string.sub(v, 1, 1)
			if char == "{" then
				//its a table
				tbl[k] = util.JSONToTable(v)
			elseif char == "0" or char == "1" or char == "2" or char == "3" or char == "4" or char == "5" or char == "6" or char == "7" or char == "8" or char == "9" then
				//it must be a number
				tbl[k] = tonumber(v)
			end
		end
	end
	//Apply settings
	local cunt = 0
	for k,v in pairs(tbl) do
		nz.Config[k] = v
		cunt = cunt + 1
	end
	print("Total of ".. cunt .. " config options changed by: ".. client:Nick())
	PrintTable(tbl)
end )

// END Config Changer //