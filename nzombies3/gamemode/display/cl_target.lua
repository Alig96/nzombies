//

function nz.Display.Functions.GetTarget()
	local tr = util.GetPlayerTrace( LocalPlayer() )
	local trace = util.TraceLine( tr )
	if (!trace.Hit) then return end
	if (!trace.HitNonWorld) then return end
	
	return trace.Entity
end

function nz.Display.Functions.GetText( ent )
	
	local class = ent:GetClass()
	local text = ""
	
	if ent:IsPlayer() then
		text = ent:Nick()
	end
	
	if class == "wall_buys" then
		local wepclass = ent:GetEntName()
		local price = ent:GetPrice()
		local wep = weapons.Get(wepclass)
		local name = wep.PrintName
		local ammo_price = math.Round((price - (price % 10))/2)
		if !LocalPlayer():HasWeapon( wepclass ) then
			text = "Press E to buy " .. name .." for " .. price .. " points."
		else
			text = "Press E to buy " .. wep.Primary.Ammo .."  Ammo refill for " .. ammo_price .. " points." // In future give more ammo
		end
	end
	
	if class == "nut_zombie" then
		text = "Health: " .. ent:Health()
	end
	
	if class == "random_box" then
		if !ent:GetOpen() then
			text = "Press E to buy a random weapon for 950 points."
		end
	end
	
	if class == "random_box_windup" then
		if !ent:GetWinding() then
			local wepclass = ent:GetWepClass()
			local wep = weapons.Get(wepclass)
			local name = "UNKNOWN" 
			if wep != nil then 
				name = wep.PrintName 
			end
			if name == nil then name = wepclass end
			text = "Press E to take " .. name .. " from the box."
		end
	end
	
	if class == "perk_machine" then
		if !ent:IsOn() then
			text = "No Power."
		else
			local perkData = nz.Perks.Functions.Get(ent:GetPerkID())
			//Its on
			text = "Press E to buy " .. perkData.name .. " for " .. perkData.price .. " points."
			//Check if they already own it
			if LocalPlayer():HasPerk(ent:GetPerkID()) then
				text = "You already own this perk."
			end
		end
	end
	
	local door_data = nil
	
	if ent:IsDoor() then
		//Normal Doors
		door_data = nz.Doors.Data.LinkFlags[ent:doorIndex()]
	end
	
	if ent:IsBuyableProp() then
		//Prop Doors
		door_data = nz.Doors.Data.BuyableProps[ent:EntIndex()]
	end
	
	//If we have door data
	if door_data != nil then
		local price = door_data.price
		local req_elec = door_data.elec
		local link = door_data.link
		if req_elec == "1" and !IsElec() then
			text = "You must turn on the electricity first!"
		else
			if !nz.Doors.Data.OpenedLinks[link] == true then
				if price != "0" then
					text = "Press E to open for " .. price .. " points."
				end
			end
		end
	end
	
	//Create Only
	if nz.Rounds.Data.CurrentState == ROUND_CREATE then
		if class == "player_spawns" then
			text = "Player Spawn"
		end
		
		if class == "zed_spawns" then
			text = "Zombie Spawn"
		end
	end
	
	return text
end

function nz.Display.Functions.DrawTargetID( text )

	local font = "nz.display.hud.small"
	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )

	local MouseX, MouseY = gui.MousePos()

	if ( MouseX == 0 && MouseY == 0 ) then

		MouseX = ScrW() / 2
		MouseY = ScrH() / 2

	end

	local x = MouseX
	local y = MouseY

	x = x - w / 2
	y = y + 30

	-- The fonts internal drop shadow looks lousy with AA on
	draw.SimpleText( text, font, x+1, y+1, Color(255,255,255,255) )
end


function GM:HUDDrawTargetID()
	
	local ent = nz.Display.Functions.GetTarget()
	
	if ent != nil then
		nz.Display.Functions.DrawTargetID(nz.Display.Functions.GetText(ent))
	end
	
end