local meta = FindMetaTable("Entity")

function meta:IsDoor()
	if not IsValid(self) then return false end
	local class = self:GetClass()

	if class == "func_door" or
		class == "func_door_rotating" or
		class == "prop_door_rotating" or
		class == "prop_dynamic" then
		return true
	end
	return false
end

function meta:IsBuyableProp()
	if not IsValid(self) then return false end
	local class = self:GetClass()

	if class == "prop_buys" then
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
	//Delay opening the door by a second to stop the door from accidentally opening then closing forever.
	//timer.Simple(1, function() 
		if self:IsDoor() then
			self.Locked = false
			self:Fire("unlock", "", 0)
			self:Fire("open", "", 0)
			self:Fire("lock", "", 0)
			self:SetKeyValue("wait",-1)
		elseif self:IsBuyableProp() then
			self.Locked = false
			self:BlockUnlock()
		end
	//end)
end

function meta:DoorLock()
	if self:IsDoor() then
		self.Locked = true
		self:Fire("close", "", 0)
		self:Fire("lock", "", 0)
	elseif self:IsBuyableProp() then
		self:BlockLock()
	end
end