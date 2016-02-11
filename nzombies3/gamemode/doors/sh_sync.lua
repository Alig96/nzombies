if SERVER then
	util.AddNetworkString( "nzMapDoorCreation" )
	util.AddNetworkString( "nzPropDoorCreation" )
	util.AddNetworkString( "nzAllDoorsLocked" )
	util.AddNetworkString( "nzDoorOpened" )
	util.AddNetworkString( "nzClearDoorData" )

	function Doors:SendMapDoorCreation( door, flags, id, ply )
		if IsValid(door) then
			net.Start("nzMapDoorCreation")
				net.WriteBool(true)
				net.WriteEntity(door)
				net.WriteTable(flags or {})
				net.WriteInt(id or 0, 13)
			return ply and net.Send(ply) or net.Broadcast()
		end
	end
	
	function Doors:SendPropDoorCreation( ent, flags, ply )
		if IsValid(ent) then
			net.Start("nzPropDoorCreation")
				net.WriteBool(true)
				net.WriteEntity(ent)
				net.WriteTable(flags or {})
			return ply and net.Send(ply) or net.Broadcast()
		end
	end
	
	function Doors:SendMapDoorRemoval( door, ply )
		if IsValid(door) then
			net.Start("nzMapDoorCreation")
				net.WriteBool(false)
				net.WriteEntity(door)
			return ply and net.Send(ply) or net.Broadcast()
		end
	end
	
	function Doors:SendPropDoorRemoval( ent, ply )
		if IsValid(ent) then
			net.Start("nzPropDoorCreation")
				net.WriteBool(false)
				net.WriteEntity(ent)
			return ply and net.Send(ply) or net.Broadcast()
		end
	end
	
	function Doors:SendAllDoorsLocked( ply )
		net.Start("nzAllDoorsLocked")
		return ply and net.Send(ply) or net.Broadcast()
	end
	
	function Doors:SendDoorOpened( door, ply )
		net.Start("nzDoorOpened")
			net.WriteEntity(door)
		return ply and net.Send(ply) or net.Broadcast()
	end
	
	function Doors.SendSync( ply )
		-- Clear all data first
		if ply then
			net.Start("nzClearDoorData")
			net.Send(ply)
		else
			net.Start("nzClearDoorData")
			net.Broadcast()
		end
		
		-- Remove old doors
		for k,v in pairs(Doors.MapDoors) do
			Doors:SendMapDoorCreation( Doors:DoorIndexToEnt(k), v, k, ply )
		end
		for k,v in pairs(Doors.PropDoors) do
			Doors:SendPropDoorCreation( Entity(k), v, ply )
		end
	end
	
	FullSyncModules["Doors"] = Doors.SendSync

end

if CLIENT then
	Doors.MapCreationIndexTable = {}
	Doors.DisplayLinks = {}
	
	local function ReceiveMapDoorCreation()
		local bool = net.ReadBool()
		local ent = net.ReadEntity()
		-- True if door is created, false if removed
		if bool then
			local tbl = net.ReadTable()
			ent:SetDoorData(tbl)
			-- We store the map creation ID in a table so we can access it universally
			Doors.MapCreationIndexTable[ent:EntIndex()] = net.ReadInt(13)
			ent:SetLocked(true)
		else
			ent:SetDoorData(nil)
			Doors.MapCreationIndexTable[ent:EntIndex()] = nil
			ent:SetLocked(false)
		end
	end
	net.Receive("nzMapDoorCreation", ReceiveMapDoorCreation)
	
	local function ReceivePropDoorCreation()
		local bool = net.ReadBool()
		local ent = net.ReadEntity()
		-- True if door is created, false if removed
		if bool then
			local tbl = net.ReadTable()
			ent:SetDoorData(tbl)
			ent:SetLocked(true)
		else
			ent:SetDoorData(nil)
			ent:SetLocked(false)
		end
	end
	net.Receive("nzPropDoorCreation", ReceivePropDoorCreation)
	
	local function ReceiveAllDoorsLocked()
		for k,v in pairs(ents.GetAll()) do
			if (v:IsDoor() or v:IsBuyableProp()) or v:IsButton() and v:GetDoorData() then
				v:SetLocked(true)
			end
		end
	end
	net.Receive("nzAllDoorsLocked", ReceiveAllDoorsLocked)
	
	local function ReceiveDoorOpened()
		local door = net.ReadEntity()
		print(door)
		door:SetLocked(false)
	end
	net.Receive("nzDoorOpened", ReceiveDoorOpened)
	
	local function ClearAllDoorData()
		for k,v in pairs(ents.GetAll()) do
			if v:GetDoorData() then
				v:SetDoorData(nil)
			end
		end
		Doors.MapCreationIndexTable = {}
	end
	net.Receive("nzClearDoorData", ClearAllDoorData)
end