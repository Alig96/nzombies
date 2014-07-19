nz.Doors.Functions = {}

local meta = FindMetaTable("Entity")

function meta:IsDoor()
	if not IsValid(self) then return false end
	local class = self:GetClass()

	if class == "func_door" or
		class == "func_door_rotating" or
		class == "wall_block_buy" or
		class == "prop_door_rotating" or
		class == "prop_dynamic" then
		return true
	end
	return false
end

function meta:doorIndex()
	if SERVER then
		return self:CreatedByMap() and self:MapCreationID() or nil
	else
		//Check the ED table
		return nz.Doors.Data.EaDI[self:EntIndex()] or 0
	end
end

function meta:DoorUnlock()
	if self:GetClass() == "wall_block_buy" then
		self:BlockUnlock()
		return
	end
	self.Locked = false
	self:Fire("unlock", "", 0)
	self:Fire("open", "", 0)
	self:Fire("lock", "", 0)
	self:SetKeyValue("wait",-1)
	
	return
end

function meta:DoorLock()
	if self:GetClass() == "wall_block_buy" then
		self:BlockLock()
		return
	end
	self.Locked = true
	self:Fire("close", "", 0)
	self:Fire("lock", "", 0)
	return
end


//Functions
function nz.Doors.Functions.doorToEntIndex(num)
	local ent = ents.GetMapCreatedEntity(num)

	return IsValid(ent) and ent:EntIndex() or nil
end

function nz.Doors.Functions.doorIndexToEnt(num)
	return ents.GetMapCreatedEntity(num) or NULL
end

if SERVER then
	//When a player uses a door
	hook.Add( "PlayerUse", "player_buydoors", function( ply, ent )
		if ent:IsDoor() then
			if ent.price != nil then
				if ply:CanAfford(ent.price) and ent.Locked == true then
					if (ent.elec == 0||(ent.elec == 1 and nz.Rounds.Elec)) then
						ply:TakePoints(ent.price)
						//Open the door and any other door with the same link
						ent:DoorUnlock()
						local link = ent.link
						//Check the link
						if link != nil then
							//Go through all the doors
							for k,v in pairs(ents.GetAll()) do
								if v:IsDoor() then
									if v.link != nil then
										if ent.link == v.link and ent != v then
											v:DoorUnlock()
										end
									end
								end
								nz.Doors.Data.OpenedLinks[ent.link] = true
							end
						end
					end
				end
			end
		end
	end )
end
