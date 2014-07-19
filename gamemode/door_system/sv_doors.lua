nz.Doors.Data = {}
nz.Doors.Data.EaDI = {}
nz.Doors.Data.LinkFlags = {}
nz.Doors.Data.OpenedLinks = {}
nz.Doors.Data.BuyableBlocks = {}

function nz.Doors.Functions.CreateLink( doorID, flagsStr )
	//Remove all traces of the old table if it exists
	nz.Doors.Functions.RemoveLink( doorID )
	//Ensure the string is lower case
	flagsStr = string.lower(flagsStr)
	local door = nz.Doors.Functions.doorIndexToEnt(doorID)
	//Translate the flags string into a table
	local ex = string.Explode( ",", flagsStr )
	local flagsTbl = {}
	if door:IsValid() and door:IsDoor() then
		for k,v in pairs(ex) do
			local ex2 = string.Explode( "=", v )
			flagsTbl[ex2[1]] = ex2[2]
		end
		//Assign the flags to the door
		for k,v in pairs(flagsTbl) do
			door[k] = tonumber(v)
			
		end
		//Save the data into a convenient table for lua refresh
		door.Data = flagsStr
	else
		print("error not a door")
	end
		
	//Set the Door Data
	nz.Doors.Data.LinkFlags[doorID] = flagsTbl
	nz.Doors.Data.EaDI[nz.Doors.Functions.doorToEntIndex(doorID)] = doorID
	
	nz.Doors.Functions.SyncClients()
	
end

function nz.Doors.Functions.CreateLinkOld( doorID, flagsStr )
	//Remove all traces of the old table if it exists
	nz.Doors.Functions.RemoveLink( doorID )
	//Ensure the string is lower case
	flagsStr = string.lower(flagsStr)
	local door = nz.Doors.Functions.doorIndexToEnt(doorID + game.MaxPlayers())
	//Translate the flags string into a table
	local ex = string.Explode( ",", flagsStr )
	local flagsTbl = {}
	if door:IsValid() and door:IsDoor() then
		for k,v in pairs(ex) do
			local ex2 = string.Explode( "=", v )
			flagsTbl[ex2[1]] = ex2[2]
		end
		//Assign the flags to the door
		for k,v in pairs(flagsTbl) do
			door[k] = tonumber(v)
			
		end
		//Save the data into a convenient table for lua refresh
		door.Data = flagsStr
	else
		print("error not a door")
	end
		
	//Set the Door Data
	nz.Doors.Data.LinkFlags[doorID] = flagsTbl
	nz.Doors.Data.EaDI[nz.Doors.Functions.doorToEntIndex(doorID)] = doorID
	
	nz.Doors.Functions.SyncClients()
	
end

function nz.Doors.Functions.RemoveLink( doorID )
	local door = nz.Doors.Functions.doorIndexToEnt(doorID)
	if door.Data != nil then
		//Translate the flags string into a table
		local ex = string.Explode( ",", door.Data )
		local flagsTbl = {}
		if door:IsValid() and door:IsDoor() then
			for k,v in pairs(ex) do
				local ex2 = string.Explode( "=", v )
				flagsTbl[ex2[1]] = ex2[2]
			end
			//Assign the flags to the door
			for k,v in pairs(flagsTbl) do
				door[k] = nil
				
			end
			//Save the data into a convenient table for lua refresh
			door.Data = nil
		else
			print("error not a door")
		end
			
		//Set the Door Data
		nz.Doors.Data.LinkFlags[doorID] = nil
		nz.Doors.Data.EaDI[nz.Doors.Functions.doorToEntIndex(doorID)] = nil
		
		nz.Doors.Functions.SyncClients()
	end
end

function nz.Doors.Functions.CreateLinkSpec( ent, flagsStr )
	if flagsStr != "" then
		nz.Doors.Functions.RemoveLinkSpec( ent )
		local flagsTbl = {}
		//Ensure the string is lower case
		flagsStr = string.lower(flagsStr)
		//Translate the flags string into a table
		local ex = string.Explode( ",", flagsStr )
		
		if ent:IsValid() then
			for k,v in pairs(ex) do
				local ex2 = string.Explode( "=", v )
				flagsTbl[ex2[1]] = ex2[2]
			end
			//Assign the flags to the door
			for k,v in pairs(flagsTbl) do
				ent[k] = tonumber(v)
			end
			//Save the data into a convenient table for lua refresh
			ent.Data = flagsStr
		else
			print("error not a door")
		end
		//Set the Door Data
		nz.Doors.Data.BuyableBlocks[ent] = flagsTbl
		nz.Doors.Functions.SyncClients()
	end
end

function nz.Doors.Functions.RemoveLinkSpec( ent )
	local door = ent
	if door.Data != nil then
		//Translate the flags string into a table
		local ex = string.Explode( ",", door.Data )
		local flagsTbl = {}
		if door:IsValid() and door:IsDoor() then
			for k,v in pairs(ex) do
				local ex2 = string.Explode( "=", v )
				flagsTbl[ex2[1]] = ex2[2]
			end
			//Assign the flags to the door
			for k,v in pairs(flagsTbl) do
				door[k] = nil
				
			end
			//Save the data into a convenient table for lua refresh
			door.Data = nil
		else
			print("error not a door")
		end
			
		//Set the Door Data
		nz.Doors.Data.BuyableBlocks[door] = nil
		
		nz.Doors.Functions.SyncClients()
	end
end

//Client Side Syncing
util.AddNetworkString( "nz_Doors_Sync" )

function nz.Doors.Functions.SyncClients()
	net.Start( "nz_Doors_Sync" )
		net.WriteTable( nz.Doors.Data )
	net.Broadcast()
end

