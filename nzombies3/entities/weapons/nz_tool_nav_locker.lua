SWEP.PrintName	= "Nav Locker Tool"
SWEP.Author		= "Zet0r"
SWEP.Slot		= 0
SWEP.SlotPos	= 11
SWEP.Base 		= "nz_tool_base"

SWEP.Ent1			= nil

function SWEP:OnPrimaryAttack(tr)
	local pos = tr.HitPos
	if tr.HitWorld then
		if !IsValid(self.Ent1) then self.Owner:ChatPrint("You need to mark a door first to link an area.") return end
		local navarea = navmesh.GetNearestNavArea(pos)
		
		
		
		nz.Nav.Data[navarea:GetID()] = {
			prev = navarea:GetAttributes(),
			locked = true,
			link = self.Ent1.link
		}
		//Purely to visualize, resets when game begins or shuts down
		navarea:SetAttributes(NAV_MESH_STOP)
		
		self.Owner:ChatPrint("Navmesh ["..navarea:GetID().."] locked to door "..self.Ent1:GetClass().."["..self.Ent1:EntIndex().."]!")
		self.Ent1:SetMaterial( "" )
		self.Ent1 = nil
	return end
	
	local ent = tr.Entity
	if !IsNavApplicable(ent) then 
		self.Owner:ChatPrint("Only buyable props, doors, and buyable buttons with LINKS can be linked to navareas.")
	return end
	
	if IsValid(self.Ent1) and self.Ent1 != ent then 
		self.Ent1:SetMaterial( "" )
	end
	
	self.Ent1 = ent
	ent:SetMaterial( "hunter/myplastic.vtf" )
	
	return true
end

function IsNavApplicable(ent)
	// All classes that can be linked with navigation
	if (ent:IsDoor() or ent:IsBuyableProp() or ent:IsButton()) and ent.link then
		return true
	else
		return false
	end
end

function SWEP:OnReload(tr)
	self.Ent1:SetMaterial( "" )
	self.Ent1 = nil
end

function SWEP:Think()
end

function SWEP:OnSecondaryAttack(tr)
	if(!tr.HitPos)then return false end
	local pos = tr.HitPos
	local navarea = navmesh.GetNearestNavArea(pos)
	local navid = navarea:GetID()
	
	if nz.Nav.Data[navid] then
		navarea:SetAttributes(nz.Nav.Data[navid].prev)
		self.Owner:ChatPrint("Navmesh ["..navid.."] unlocked!")
		nz.Nav.Data[navid] = nil
	return end
	
	nz.Nav.Data[navid] = {
		prev = navarea:GetAttributes(),
		locked = true,
		link = nil
	}
	
	navarea:SetAttributes(NAV_MESH_AVOID)
	self.Owner:ChatPrint("Navmesh ["..navid.."] locked!")
	
	if(CLIENT)then return true end
	
	return true
end

function SWEP:Deploy()
	if SERVER then
		if self.Owner:IsListenServerHost() and GetConVar("sv_cheats"):GetBool() then
			RunConsoleCommand("nav_edit", 1)
		else
			self.Owner:ChatPrint("You need to be hosting a singleplayer/local server with sv_cheats set to 1 to visualize the Navmeshes.")
		end
	end
end

function SWEP:Holster()
	if SERVER and self.Owner:IsListenServerHost() and GetConVar("sv_cheats"):GetBool() then
		RunConsoleCommand("nav_edit", 0)
	end
	return true
end