//

if SERVER then
	function nz.Interfaces.Functions.DoorPropsHandler( data )
		nz.Doors.Functions.CreateLink( data.ent, data.flags )
	end
end

if CLIENT then
	function nz.Interfaces.Functions.DoorProps( data )
		local ent = data.door
		local name = "Add New Door"
		local valz = {}
		valz["Row1"] = 0
		valz["Row2"] = 1
		valz["Row3"] = 1000
		valz["Row4"] = 0
		
		local door_data = nil
		
		//Check if the ent has flags already
		if ent:IsDoor() then
			door_data = nz.Doors.Data.LinkFlags[ent:doorIndex()]
		elseif ent:IsBuyableProp() then
			door_data = nz.Doors.Data.BuyableProps[ent:EntIndex()]
		end
		//If we do then;
		if door_data != nil then
			if door_data.link != nil then
				valz["Row1"] = 1
				valz["Row2"] = door_data.link
			end
			valz["Row3"] = door_data.price
			valz["Row4"] = door_data.elec
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
			local flagString = compileString(valz["Row3"], valz["Row4"], flag)
			print(flagString)
			
			//Send the data
			nz.Interfaces.Functions.SendRequests( "DoorProps", {flags = flagString, ent = ent} )
			
		end
	end

end