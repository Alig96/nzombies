nz.Tools.Functions.CreateTool("navladder", {
	displayname = "Nav Ladder Generation Tool",
	desc = "LMB: Add Ladder at Cursor to Navmesh, Use console command 'nav_save' to save changes",
	condition = function(wep, ply)
		return nz.Tools.Advanced
	end,

	PrimaryAttack = function(wep, ply, tr, data)
		ply:ConCommand( "nav_build_ladder" )
	end,

	SecondaryAttack = function(wep, ply, tr, data)
	end,
	Reload = function(wep, ply, tr, data)
	end,
	OnEquip = function(wep, ply, data)
		if wep.Owner:IsListenServerHost() and GetConVar("sv_cheats"):GetBool() then
			RunConsoleCommand("nav_edit", 1)
		end
	end,
	OnHolster = function(wep, ply, data)
		if SERVER and wep.Owner:IsListenServerHost() and GetConVar("sv_cheats"):GetBool() then
			RunConsoleCommand("nav_edit", 0)
		end
	end
}, {
	displayname = "Nav Ladder Generation Tool",
	desc = "LMB: Create Nav Ladder at Cursor, Use console command 'nav_save' to save changes",
	icon = "icon16/table_relationship.png",
	weight = 50,
	condition = function(wep, ply)
		return nz.Tools.Advanced
	end,
	interface = function(frame, data)
		local panel = vgui.Create("DPanel", frame)
		panel:SetSize(frame:GetSize())

		local textw = vgui.Create("DLabel", panel)
		textw:SetText("You need to be in a listen/local server to be")
		textw:SetFont("Trebuchet18")
		textw:SetTextColor( Color(150, 50, 50) )
		textw:SizeToContents()
		textw:SetPos(0, 80)
		textw:CenterHorizontal()

		local textw2 = vgui.Create("DLabel", panel)
		textw2:SetText("able to see the Navmeshes!")
		textw2:SetFont("Trebuchet18")
		textw2:SetTextColor( Color(150, 50, 50) )
		textw2:SizeToContents()
		textw2:SetPos(0, 90)
		textw2:CenterHorizontal()

		local textw3 = vgui.Create("DLabel", panel)
		textw3:SetText("The tool can still be used blindly")
		textw3:SetFont("Trebuchet18")
		textw3:SetTextColor( Color(50, 50, 50) )
		textw3:SizeToContents()
		textw3:SetPos(0, 100)
		textw3:CenterHorizontal()

		local text = vgui.Create("DLabel", panel)
		text:SetText("Use nav_save to save changes into the map's .nav")
		text:SetFont("Trebuchet18")
		text:SetTextColor( Color(50, 50, 50) )
		text:SizeToContents()
		text:SetPos(0, 140)
		text:CenterHorizontal()

		local text2 = vgui.Create("DLabel", panel)
		text2:SetText("This requires sv_cheats 1!")
		text2:SetFont("Trebuchet18")
		text2:SetTextColor( Color(150, 50, 50) )
		text2:SizeToContents()
		text2:SetPos(0, 150)
		text2:CenterHorizontal()

		return panel
	end,
	//defaultdata = {}
})
