local _PLAYER = FindMetaTable("Player")
local meta = FindMetaTable("Entity")

function _PLAYER:GetPoints()
	return self:GetNWInt("points") or 0
end

function _PLAYER:HasPoints(amount)
	return self:GetPoints() >= amount
end

function _PLAYER:CanAfford(amount)
	return (self:GetPoints() - amount) >= 0
end

if (SERVER) then
	-- Sets the character's amount of currency to a specific value.
	function _PLAYER:SetPoints(amount)
		amount = math.Round(amount, 2)
		self:SetNWInt("points", amount)
	end

	-- Quick function to set the money to the current amount plus an amount specified.
	function _PLAYER:GivePoints(amount)
		if bnpvbWJpZXM.Rounds.Effects["dp"] == true then
		amount = amount * 2
		end
		self:SetPoints(self:GetPoints() + amount)
	end

	-- Takes away a certain amount by inverting the amount specified.
	function _PLAYER:TakePoints(amount)
		self:GivePoints(-amount)
	end
end

//Doors

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

function meta:DoorIndex()
	return self:EntIndex() - game.MaxPlayers()
end
					
function meta:DoorUnlock(open)
	self.Locked = false
	self:Fire("unlock", "", 0)
	self:Fire("open", "", 0)
	self:Fire("lock", "", 0)
	return
end

function meta:DoorLock()
	self.Locked = true
	self:Fire("close", "", 0)
	self:Fire("lock", "", 0)
	return
end

hook.Add( "PlayerUse", "player_buydoors", function( ply, ent )
	if ent:IsDoor() then
		if ent.Price != nil then
			if ply:CanAfford(ent.Price) and ent.Locked == true then
				ply:TakePoints(ent.Price)
				ent:DoorUnlock(1)
				if ent.Link != nil then
					for k,v in pairs(ents.GetAll()) do
						if v:IsDoor() then
							if v.Link != nil then
								if ent.Link == v.Link and ent != v then
									v:DoorUnlock(1)
								end
							end
						end
					end
				end
				
			end
		end
	end
end )