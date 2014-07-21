//HUD

function GM:HUDDrawTargetID()

	local tr = util.GetPlayerTrace( LocalPlayer() )
	local trace = util.TraceLine( tr )
	if (!trace.Hit) then return end
	if (!trace.HitNonWorld) then return end

	local text = "ERROR"
	local font = "TargetID"

	if (trace.Entity:IsPlayer()) then
		text = trace.Entity:Nick()
	elseif (trace.Entity:GetClass() == "wall_buy") then
		text =  weapons.Get(trace.Entity:GetEntName()).PrintName.." Price: "..trace.Entity:GetPrice()
	elseif (trace.Entity:GetClass() == "perk_machine") then
		if !nz.Rounds.Elec then
			text = "You must turn the electricity on first!"
		else
			local id = trace.Entity:GetPerkID()
			text = "Press E to buy "..nz.Perks.Get(id).name.." for "..nz.Perks.Get(id).price.." points."
		end
	elseif (trace.Entity:IsDoor() and nz.Rounds.CurrentState != ROUND_INIT) then
		//Normal Doors
		if nz.Doors.Data.LinkFlags[trace.Entity:doorIndex()] != nil then
			if tonumber(nz.Doors.Data.LinkFlags[trace.Entity:doorIndex()].elec) == 1 and !nz.Rounds.Elec then
				text = "You must turn on the electricity first!"
			else
				text = "Press E to open for "..nz.Doors.Data.LinkFlags[trace.Entity:doorIndex()].price.." points."
			end
		elseif nz.Doors.Data.BuyableBlocks[trace.Entity:EntIndex()] != nil then
			//Buyable Blocks
			if tonumber(nz.Doors.Data.BuyableBlocks[trace.Entity:EntIndex()].elec) == 1 and nz.Rounds.Elec == false then
				text = "You must turn on the electricity first!"
			else
				text = "Press E to open for "..nz.Doors.Data.BuyableBlocks[trace.Entity:EntIndex()].price.." points."
			end
		else
			text = "You can't open this door."
		end
	else
		return
		--text = trace.Entity:GetClass()
	end

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
	draw.SimpleText( text, font, x+1, y+1, Color(0,0,0,120) )
	draw.SimpleText( text, font, x+2, y+2, Color(0,0,0,50) )
	draw.SimpleText( text, font, x, y, self:GetTeamColor( trace.Entity ) )

	if (trace.Entity:IsPlayer()) then
		y = y + h + 5

		local text = trace.Entity:Health() .. "%"
		local font = "TargetIDSmall"

		surface.SetFont( font )
		local w, h = surface.GetTextSize( text )
		local x =  MouseX  - w / 2

		draw.SimpleText( text, font, x+1, y+1, Color(0,0,0,120) )
		draw.SimpleText( text, font, x+2, y+2, Color(0,0,0,50) )
		draw.SimpleText( text, font, x, y, self:GetTeamColor( trace.Entity ) )
	end
end

concommand.Add( "PrintWeapons", function(player, command, arguments )
	for k,v in pairs( weapons.GetList() ) do 
		print( v.ClassName )
	end 
end )
