local meta = FindMetaTable("Entity")
AccessorFunc( meta, "bLocked", "Locked", FORCE_BOOL )
function meta:IsLocked() return self:GetLocked() end

Doors.MapDoors = {}
Doors.PropDoors = {}
Doors.OpenedLinks = {}

local validdoors = {
	["func_door"] = true,
	["func_door_rotating"] = true,
	["prop_door_rotating"] = true,
	["prop_dynamic"] = true,
}

function meta:IsDoor()
	if not IsValid(self) then return false end
	local class = self:GetClass()

	return validdoors[class] or false
end

function meta:IsButton()
	if not IsValid(self) then return false end
	local class = self:GetClass()

	if class == "func_button" or (CLIENT and class == "class C_BaseEntity") then
		return true
	end
	return false
end

function meta:IsBuyableProp()
	if not IsValid(self) then return false end
	return self:GetClass() == "prop_buys"
end

function meta:IsBuyableMapEntity()
	return self:IsDoor() or self:IsButton() or self:IsBuyableProp()
end

function meta:DoorIndex()
	if SERVER then
		return self:CreatedByMap() and self:MapCreationID() or nil
	else
		-- Check the ED table
		return Doors.MapCreationIndexTable[self:EntIndex()] or 0
	end
end

function meta:GetDoorData()
	if self:IsBuyableProp() then
		return Doors.PropDoors[self:EntIndex()]
	else
		return Doors.MapDoors[self:DoorIndex()]
	end
end

function meta:SetDoorData( tbl )
	if self:IsBuyableProp() then
		Doors.PropDoors[self:EntIndex()] = tbl
	else
		Doors.MapDoors[self:DoorIndex()] = tbl
	end
end