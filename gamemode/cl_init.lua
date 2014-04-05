include( "points/sh_meta.lua" )
include( "rounds/cl_round.lua" )
include( "shared.lua" )
include( "config.lua" )

ROUND_STATE = 0
ELEC = false
EditedDoors = {}
net.Receive( "bnpvbWJpZXM_Doors_Sync", function( length )
	EditedDoors = net.ReadTable()
end )


net.Receive( "bnpvbWJpZXM_Elec_Sync", function( length )
	ELEC = true
end )

surface.CreateFont( "RoundFont", {
	font = "Boycott",
	size = 64
	}
)
surface.CreateFont( "RoundFontSmall", {
	font = "Boycott",
	size = 38
	}
)

surface.CreateFont( "ScoreFont", {
	font = "Boycott",
	size = 28
	}
)

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
		if !ELEC then
			text = "You must turn the electric on first!"
		else
			local id = trace.Entity:GetPerkID()
			text = "Press E to buy "..PerksColas[id].Name.." for "..PerksColas[id].Price.." points."
		end
	elseif (trace.Entity:IsDoor() and ROUND_STATE != ROUND_INIT) then
		if EditedDoors[trace.Entity:DoorIndex()] != nil then
			if EditedDoors[trace.Entity:DoorIndex()] != 0 then
				if trace.Entity:GetClass() == "wall_block_buy" then
					if trace.Entity:GetLocked() or ROUND_STATE == ROUND_CREATE then
						text = "Press E to open for "..EditedDoors[trace.Entity:DoorIndex()].." points."
					else
						text = ""
					end
				else
					text = "Press E to open for "..EditedDoors[trace.Entity:DoorIndex()].." points."
				end
			else
				text = "This door is already open"
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
