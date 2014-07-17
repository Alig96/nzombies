nz.Interface = {}
//Doors//
function nz.Interface.DoorProps( ent )
	local name = "Add New Door"
	local valz = {}
	valz["Row1"] = 0
	valz["Row2"] = 1
	valz["Row3"] = 1000
	valz["Row4"] = 0
	//Check if the ent has flags already
	if ent:doorIndex() != 0 then
		local data = nz.Doors.Data.LinkFlags[ent:doorIndex()]
		if data.link != nil then
			valz["Row1"] = 1
			valz["Row2"] = data.link
		end
		valz["Row3"] = data.price
		valz["Row4"] = data.elec
		name = "Modifying Door Flag"
	elseif nz.Doors.Data.BuyableBlocks[ent] != nil then
		local data = nz.Doors.Data.BuyableBlocks[ent]
		if data.link != nil then
			valz["Row1"] = 1
			valz["Row2"] = data.link
		end
		valz["Row3"] = data.price
		valz["Row4"] = data.elec
		name = "Modifying Door Flag"
	end
	local DermaPanel = vgui.Create( "DFrame" )
	DermaPanel:SetPos( 100, 100 )
	DermaPanel:SetSize( 300, 180 )
	DermaPanel:SetTitle( name )
	DermaPanel:SetVisible( true )
	DermaPanel:SetDraggable( true )
	DermaPanel:ShowCloseButton( true )
	DermaPanel:MakePopup()
	DermaPanel:Center()
	
	local DProperties = vgui.Create( "DProperties", DermaPanel )
	DProperties:SetSize( 280, 180 )
	DProperties:SetPos( 10, 30 )
	
	local Row1 = DProperties:CreateRow( "Door Settings", "Enable Flag?" )
	Row1:Setup( "Boolean" )
	Row1:SetValue( valz["Row1"] )
	Row1.DataChanged = function( _, val ) valz["Row1"] = val end
	local Row2 = DProperties:CreateRow( "Door Settings", "Flag" )
	Row2:Setup( "Integer" )
	Row2:SetValue( valz["Row2"] )
	Row2.DataChanged = function( _, val ) valz["Row2"] = val end
	local Row3 = DProperties:CreateRow( "Door Settings", "Price" )
	Row3:Setup( "Integer" )
	Row3:SetValue( valz["Row3"] )
	Row3.DataChanged = function( _, val ) valz["Row3"] = val end
	local Row4 = DProperties:CreateRow( "Door Settings", "Requires Electricity?" )
	Row4:Setup( "Boolean" )
	Row4:SetValue( valz["Row4"] )
	Row4.DataChanged = function( _, val ) valz["Row4"] = val end
	
	local DermaButton = vgui.Create( "DButton" )
	DermaButton:SetParent( DermaPanel )
	DermaButton:SetText( "Submit" )
	DermaButton:SetPos( 10, 140 )
	DermaButton:SetSize( 280, 30 )
	DermaButton.DoClick = function()
		local function compileString(price, elec, flag)
			local str = "price="..price..",elec="..elec
			if flag != false then
				str = str..",link="..flag
			end
			return str
		end
		local flag = false
		if valz["Row1"] == 1 then
			flag = valz["Row2"]
		end
		DermaPanel:SetTitle( "Modifying Door Flag" )
		net.Start( "nz_int_doors" )
			net.WriteEntity(ent)
			net.WriteString(compileString(valz["Row3"], valz["Row4"], flag))
		net.SendToServer( )
		
		print(compileString(valz["Row3"], valz["Row4"], flag))
	end

	
end

net.Receive( "nz_int_doors", function( len )
	nz.Interface.DoorProps( net.ReadEntity() )
end )
//End Doors//

//Wep Buy//
function nz.Interface.WepBuyProps( vec, angle )
	local valz = {}
	valz["Row1"] = "weapon_class"
	valz["Row2"] = 500

	local DermaPanel = vgui.Create( "DFrame" )
	DermaPanel:SetPos( 100, 100 )
	DermaPanel:SetSize( 300, 180 )
	DermaPanel:SetTitle( "Add New Weapon" )
	DermaPanel:SetVisible( true )
	DermaPanel:SetDraggable( true )
	DermaPanel:ShowCloseButton( true )
	DermaPanel:MakePopup()
	DermaPanel:Center()
	
	local DProperties = vgui.Create( "DProperties", DermaPanel )
	DProperties:SetSize( 280, 180 )
	DProperties:SetPos( 10, 30 )
	
	local Row1 = DProperties:CreateRow( "Weapon Settings", "Weapon Class" )
	Row1:Setup( "Generic" )
	Row1:SetValue( valz["Row1"] )
	Row1.DataChanged = function( _, val ) valz["Row1"] = val end
	local Row2 = DProperties:CreateRow( "Weapon Settings", "Price" )
	Row2:Setup( "Integer" )
	Row2:SetValue( valz["Row2"] )
	Row2.DataChanged = function( _, val ) valz["Row2"] = val end

	local DermaButton = vgui.Create( "DButton" )
	DermaButton:SetParent( DermaPanel )
	DermaButton:SetText( "Submit" )
	DermaButton:SetPos( 10, 140 )
	DermaButton:SetSize( 280, 30 )
	DermaButton.DoClick = function()
		
		//Check the weapon class is fine first
		if weapons.Get( valz["Row1"] ) != nil then
			net.Start( "nz_int_wepbuy" )
				net.WriteVector( vec )
				net.WriteAngle( ang )
				net.WriteString( valz["Row1"] )
				net.WriteString( tostring(valz["Row2"]) )
			net.SendToServer( )
			
			DermaPanel:Close()
		end
		
	end

	
end

net.Receive( "nz_int_wepbuy", function( len )
	nz.Interface.WepBuyProps( net.ReadVector(), net.ReadAngle() )
end )
//End Wep buy//

//Map Config//
function nz.Interface.MapConfig( maps )

	local DermaPanel = vgui.Create( "DFrame" )
	DermaPanel:SetPos( 100, 100 )
	DermaPanel:SetSize( 300, 180 )
	DermaPanel:SetTitle( "Load a config" )
	DermaPanel:SetVisible( true )
	DermaPanel:SetDraggable( true )
	DermaPanel:ShowCloseButton( true )
	DermaPanel:MakePopup()
	DermaPanel:Center()
	
	local DermaListView = vgui.Create("DListView")
	DermaListView:SetParent(DermaPanel)
	DermaListView:SetPos(10, 30)
	DermaListView:SetSize(280, 100)
	DermaListView:SetMultiSelect(false)
	DermaListView:AddColumn("Name")
	//Populate
	for k,v in pairs(maps) do
		DermaListView:AddLine(v)
	end
	
	local DermaButton = vgui.Create( "DButton" )
	DermaButton:SetParent( DermaPanel )
	DermaButton:SetText( "Submit" )
	DermaButton:SetPos( 10, 140 )
	DermaButton:SetSize( 280, 30 )
	DermaButton.DoClick = function()
		if DermaListView:GetSelectedLine() != nil then
			local str = DermaListView:GetLine(DermaListView:GetSelectedLine()):GetValue(1)
			if str != nil then
				net.Start( "nz_int_mapconfig" )
					net.WriteString(str)
				net.SendToServer( )
				DermaPanel:Close()
			end
		end
	end

	
end

net.Receive( "nz_int_mapconfig", function( len )
	nz.Interface.MapConfig( net.ReadTable() )
end )
//End Map Config//


//Zombie Links//
function nz.Interface.ZombieSpawnLinks( ent, link )
	local name = "Add New Zombie Link"
	local valz = {}
	valz["Row1"] = 0
	valz["Row2"] = 1
	//Check if the ent has flags already
	if link != 0 then
		valz["Row1"] = 1
		valz["Row2"] = link
		name = "Modifying Zombie Link"
	end
	
	local DermaPanel = vgui.Create( "DFrame" )
	DermaPanel:SetPos( 100, 100 )
	DermaPanel:SetSize( 300, 180 )
	DermaPanel:SetTitle( name )
	DermaPanel:SetVisible( true )
	DermaPanel:SetDraggable( true )
	DermaPanel:ShowCloseButton( true )
	DermaPanel:MakePopup()
	DermaPanel:Center()
	
	local DProperties = vgui.Create( "DProperties", DermaPanel )
	DProperties:SetSize( 280, 180 )
	DProperties:SetPos( 10, 30 )
	
	local Row1 = DProperties:CreateRow( "Zombie Spawn", "Enable Flag?" )
	Row1:Setup( "Boolean" )
	Row1:SetValue( valz["Row1"] )
	Row1.DataChanged = function( _, val ) valz["Row1"] = val end
	local Row2 = DProperties:CreateRow( "Zombie Spawn", "Flag" )
	Row2:Setup( "Integer" )
	Row2:SetValue( valz["Row2"] )
	Row2.DataChanged = function( _, val ) valz["Row2"] = val end
	
	local DermaButton = vgui.Create( "DButton" )
	DermaButton:SetParent( DermaPanel )
	DermaButton:SetText( "Submit" )
	DermaButton:SetPos( 10, 140 )
	DermaButton:SetSize( 280, 30 )
	DermaButton.DoClick = function()
		local str="nil"
		if valz["Row1"] == 0 then
			str="nil"
		else
			str=valz["Row2"]
		end
		net.Start("nz_int_zombiespawn")
			net.WriteEntity(ent)
			net.WriteString(str)
		net.SendToServer( )
	end
end

net.Receive( "nz_int_zombiespawn", function( len )
	nz.Interface.ZombieSpawnLinks( net.ReadEntity(), tonumber(net.ReadString()) )
end )
//End Zombie Links//

//////////////////////////////////////////////
//StartingWeps//
function nz.Interface.StartingWeps( cc, weps )
	local valz = {}
	valz["Row1"] = cc
	valz["Row2"] = weps[1]
	valz["Row3"] = weps[2]
	
	local DermaPanel = vgui.Create( "DFrame" )
	DermaPanel:SetPos( 100, 100 )
	DermaPanel:SetSize( 300, 180 )
	DermaPanel:SetTitle( "Modifying Starting Weapons" )
	DermaPanel:SetVisible( true )
	DermaPanel:SetDraggable( true )
	DermaPanel:ShowCloseButton( true )
	DermaPanel:MakePopup()
	DermaPanel:Center()
	
	local DProperties = vgui.Create( "DProperties", DermaPanel )
	DProperties:SetSize( 280, 180 )
	DProperties:SetPos( 10, 30 )
	
	local Row1 = DProperties:CreateRow( "Weapon Settings", "Use Config'd Weps" )
	Row1:Setup( "Boolean" )
	Row1:SetValue( valz["Row1"] )
	Row1.DataChanged = function( _, val ) valz["Row1"] = val end
	local Row2 = DProperties:CreateRow( "Weapon Settings", "Weapon Class 1" )
	Row2:Setup( "Generic" )
	Row2:SetValue( valz["Row2"] )
	Row2.DataChanged = function( _, val ) valz["Row2"] = val end
	local Row3 = DProperties:CreateRow( "Weapon Settings", "Weapon Class 2" )
	Row3:Setup( "Generic" )
	Row3:SetValue( valz["Row3"] )
	Row3.DataChanged = function( _, val ) valz["Row3"] = val end

	local DermaButton = vgui.Create( "DButton" )
	DermaButton:SetParent( DermaPanel )
	DermaButton:SetText( "Submit" )
	DermaButton:SetPos( 10, 140 )
	DermaButton:SetSize( 280, 30 )
	DermaButton.DoClick = function()
		
		//Check the weapon class is fine first
		if weapons.Get( valz["Row2"] ) != nil and weapons.Get( valz["Row3"] ) != nil then
			local vl = valz["Row1"]
			valz["Row1"] = nil
			valz = table.ClearKeys(valz)
			net.Start( "nz_int_startweps" )
				net.WriteString(vl)
				net.WriteTable( valz )
			net.SendToServer( )
			
			DermaPanel:Close()
		end
		
	end
end

net.Receive( "nz_int_startweps", function( len )
	nz.Interface.StartingWeps( net.ReadString(), net.ReadTable() )
end )
//End StartingWeps//

//Perk Machines//
function nz.Interface.Perks( )	
	local DermaPanel = vgui.Create( "DFrame" )
	DermaPanel:SetPos( 100, 100 )
	DermaPanel:SetSize( 300, 180 )
	DermaPanel:SetTitle( "Modifying Perk Machines" )
	DermaPanel:SetVisible( true )
	DermaPanel:SetDraggable( true )
	DermaPanel:ShowCloseButton( true )
	DermaPanel:MakePopup()
	DermaPanel:Center()
	
	local choices = vgui.Create( "DComboBox", DermaPanel )
	choices:SetPos( 10, 30 )
	choices:SetSize( 280, 30 )
	for k,v in pairs(PerksColas) do
		choices:AddChoice( v.ID )
	end
	choices.OnSelect = function( panel, index, value, data )
		local gun = LocalPlayer():GetActiveWeapon( )
		gun.SwitchModel = PerksColas[value].Model
		gun:ReleaseGhostEntity()
		net.Start( "nz_int_perks" )
			net.WriteString( value )
		net.SendToServer()
		DermaPanel:Close()
	end
end

net.Receive( "nz_int_perks", function( len )
	nz.Interface.Perks( )
end )
//End Perk Machines//



//Config Changer //
function nz.Interface.ConfigChange( tbl )
	local valz = table.Copy( tbl )
	local DermaPanel = vgui.Create( "DFrame" )
	DermaPanel:SetPos( 100, 100 )
	DermaPanel:SetSize( 400, 180 )
	DermaPanel:SetTitle( "Configure" )
	DermaPanel:SetVisible( true )
	DermaPanel:SetDraggable( true )
	DermaPanel:ShowCloseButton( true )
	DermaPanel:MakePopup()
	DermaPanel:Center()
	
	local DProperties = vgui.Create( "DProperties", DermaPanel )
	DProperties:SetSize( 380, 100 )
	DProperties:SetPos( 10, 30 )
	
	for k,v in pairs( tbl ) do
		local Row = DProperties:CreateRow( "Config Settings", k )
		Row:Setup( "Generic" )
		Row:SetValue( valz[k] )
		Row.DataChanged = function( _, val ) valz[k] = val end
	end
	
	//Submit Button
	
	local DermaButton = vgui.Create( "DButton" )
	DermaButton:SetParent( DermaPanel )
	DermaButton:SetText( "Submit" )
	DermaButton:SetPos( 10, 140 )
	DermaButton:SetSize( 380, 30 )
	DermaButton.DoClick = function()
		local function detectChanges(tbl1, tbl2)
			for k,v in pairs(tbl1) do
				if tbl2[k] == v then
					//Nothings Changed
					//No need to send the same value back, remove it
					tbl1[k] = "MARKED"
				//else
					//Change detected
				end
			end
			for k,v in pairs(tbl1) do
				if v == "MARKED" then
					tbl1[k] = nil
				end
				
			end
			return tbl1
		end
		net.Start( "nz_int_configchanger" )
			net.WriteTable(detectChanges(valz,tbl))
		net.SendToServer( )
		DermaPanel:Close()
	end

	
end

net.Receive( "nz_int_configchanger", function( len )
	nz.Interface.ConfigChange( net.ReadTable() )
end )
//End Config Changer //
