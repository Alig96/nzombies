nz.Mapping.Mismatch = nz.Mapping.Mismatch or {}
nz.Mapping.MismatchData = nz.Mapping.MismatchData or {}

if SERVER then
	util.AddNetworkString("nzMappingMismatchData")
	util.AddNetworkString("nzMappingMismatchEnd")
	
	net.Receive("nzMappingMismatchData", function(len, ply)
		if !ply:IsSuperAdmin() then print(ply:Nick().." tried to correct map data. You need to be a super admin to do this.") return end
		local id = net.ReadString()
		local data = net.ReadTable()
		nz.Mapping.Mismatch[id].Correct(data)
	end)
	
else
	net.Receive("nzMappingMismatchData", function()
		local id = net.ReadString()
		local data = net.ReadTable()
		nz.Mapping.MismatchData[id] = data
	end)
	
	net.Receive("nzMappingMismatchEnd", function()
		OpenMismatchInterface()
	end)
	
	function OpenMismatchInterface()
		local frame = vgui.Create("DFrame")
		frame:SetSize(400, 500)
		frame:Center()
		frame:SetTitle("Config Loading Mismatch!")
		frame:MakePopup()
		
		local sheet = vgui.Create("DPropertySheet", frame)
		sheet:SetPos(5, 25)
		sheet:SetSize(390, 435)
		
		for k,v in pairs(nz.Mapping.MismatchData) do
			local panel = nz.Mapping.Mismatch[k].Interface(sheet)
			sheet:AddSheet(k, panel)
			print(k, panel)
		end
		
		local submit = vgui.Create("DButton", pnl)
		submit:SetText("Submit Changes")
		submit:SetSize(200, 30)
		submit:SetPos(90, 465)
		submit.DoClick = function()
			print(sheet:GetActiveTab())
		end
	end
end

function CreateMismatchCheck(id, sv_check, cl_interface, sv_correct)
	-- Create tables for storing it
	nz.Mapping.Mismatch[id] = nz.Mapping.Mismatch[id] or {}
	nz.Mapping.MismatchData[id] = nz.Mapping.MismatchData[id] or {}
	
	if SERVER then
		nz.Mapping.Mismatch[id].Check = sv_check
		nz.Mapping.Mismatch[id].Correct = sv_correct
	else
		nz.Mapping.Mismatch[id].Interface = cl_interface
	end
end

function nz.Mapping.Functions.CheckMismatch( loader )
	if !IsValid(loader) then return end
	
	for k,v in pairs(nz.Mapping.Mismatch) do
		local data = nz.Mapping.Mismatch[k].Check() -- Run the check function and save the data
		if #data > 0 then -- Empty tables don't get sent, no errors
			net.Start("nzMappingMismatchData")
				net.WriteString(k)
				net.WriteTable(data)
			net.Send(loader)
		end
	end
	
	net.Start("nzMappingMismatchEnd") -- Mark the end of all data so the client can compile it all
	net.Send(loader)
end

CreateMismatchCheck("Wall Buys", function()
	local tbl = {}
	for k,v in pairs(ents.FindByClass("wall_buys")) do
		if !weapons.Get(v:GetEntName()) then
			print("Wall Buy has non-existant weapon class: "..v:GetEntName().."!")
			tbl[v:GetEntName()] = true
		end
	end
	
	return tbl -- Return the data you want to send to the client

end, function(frame)

	local pnl = vgui.Create("DPanel", frame)
	pnl:SetPos(5, 5)
	pnl:SetSize(380, 425)
	
	local properties = vgui.Create("DProperties", pnl)
	properties:SetPos(0, 0)
	properties:SetSize(380, 420)
	
	for k,v in pairs(nz.Mapping.MismatchData["Wall Buys"]) do
		local choice = properties:CreateRow( "Missing Weapons", k )
		choice:Setup( "Combo", {} )
		choice:AddChoice( " Remove ...", "nz_removeweapon", true )
		nz.Mapping.MismatchData["Wall Buys"][k] = "nz_removeweapon"
		for k,v in pairs(weapons.GetList()) do
			choice:AddChoice(v.PrintName and v.PrintName != "" and v.PrintName or v.ClassName, v.ClassName, false)
		end
		choice.DataChanged = function(self, val)
			nz.Mapping.MismatchData["Wall Buys"][k] = val
		end
	end
	
	pnl.ReturnCorrectedData = function() -- Add the function to the returned panel so we can access it outside
		net.Start("nzMappingMismatchData")
			net.WriteString("Wall Buys")
			net.WriteTable(nz.Mapping.MismatchData["Wall Buys"])
		net.SendToServer()
		nz.Mapping.MismatchData["Wall Buys"] = nil -- Clear the data
	end
	
	return pnl -- Return it to add it the the sheets
	
end, function( data )
	for k,v in pairs(ents.FindByClass("wall_buys")) do
		local new = data[v:GetEntName()]
		if new then
			if new == "nz_removeweapon" then
				v:Remove()
			else
				v:SetEntName(new)
			end
		end
	end
	
	nz.Mapping.MismatchData["Wall Buys"] = nil -- Clear the data
end)

CreateMismatchCheck("Perks", function()
	local tbl = {}
	for k,v in pairs(ents.FindByClass("perk_machine")) do
		if !nz.Perks.Functions.Get(v:GetPerkID()) then
			print("Perk with non-existant perk: "..v:GetPerkID().."!")
			tbl[v:GetPerkID()] = true
		end
	end
	
	return tbl -- Return the data you want to send to the client

end, function(frame)

	local pnl = vgui.Create("DPanel", frame)
	pnl:SetPos(5, 5)
	pnl:SetSize(380, 425)
	
	local properties = vgui.Create("DProperties", pnl)
	properties:SetPos(0, 0)
	properties:SetSize(380, 420)
	
	for k,v in pairs(nz.Mapping.MismatchData["Perks"]) do
		local choice = properties:CreateRow( "Invalid Perks", k )
		choice:Setup( "Combo", {} )
		choice:AddChoice( " Remove ...", "nz_removeperk", true )
		nz.Mapping.MismatchData["Perks"][k] = "nz_removeperk"
		for k,v in pairs(nz.Perks.Functions.GetList()) do
			choice:AddChoice(v.name or k, k, false)
		end
		choice.DataChanged = function(self, val)
			nz.Mapping.MismatchData["Perks"][k] = val
		end
	end
	
	pnl.ReturnCorrectedData = function() -- Add the function to the returned panel so we can access it outside
		net.Start("nzMappingMismatchData")
			net.WriteString("Perks")
			net.WriteTable(nz.Mapping.MismatchData["Perks"])
		net.SendToServer()
		nz.Mapping.MismatchData["Perks"] = nil -- Clear the data
	end
	
	return pnl -- Return it to add it the the sheets
	
end, function( data )
	for k,v in pairs(ents.FindByClass("perk_machine")) do
		local new = data[v:GetPerkID()]
		if new then
			if new == "nz_removeperk" then
				v:Remove()
			else
				v:SetPerkID(new)
				v:Update() -- Update model and perk values
			end
		end
	end
	
	nz.Mapping.MismatchData["Perks"] = nil -- Clear the data
end)

CreateMismatchCheck("Map Settings", function()
	local tbl = {}
	local settings = nz.Mapping.MapSettings
	
	if !weapons.Get(settings.startwep) then tbl["startwep"] = settings.startwep end
	-- Later add stuff like model packs, special round entity types etc.
	
	return tbl

end, function(frame)

	local pnl = vgui.Create("DPanel", frame)
	pnl:SetPos(5, 5)
	pnl:SetSize(380, 425)
	
	local properties = vgui.Create("DProperties", pnl)
	properties:SetPos(0, 0)
	properties:SetSize(380, 420)
	
	local tbl = nz.Mapping.MismatchData["Map Settings"]
	
	if tbl.startwep then
		local choice = properties:CreateRow( "Invalid Map Settings", "Start Weapon" )
		choice:Setup( "Combo", {} )
		for k,v in pairs(weapons.GetList()) do
			choice:AddChoice(v.PrintName and v.PrintName != "" and v.PrintName or v.ClassName, v.ClassName, false)
		end
		choice.DataChanged = function(self, val)
			nz.Mapping.MismatchData["Map Settings"]["startwep"] = val
		end
	end
	
	pnl.ReturnCorrectedData = function()
		net.Start("nzMappingMismatchData")
			net.WriteString("Map Settings")
			net.WriteTable(nz.Mapping.MismatchData["Map Settings"])
		net.SendToServer()
		nz.Mapping.MismatchData["Map Settings"] = nil
	end
	
	return pnl
	
end, function( data )
	
	if data.startwep then
		nz.Mapping.MapSettings.startwep = data.startwep
	end
	
	for k,v in pairs(player.GetAll()) do
		nz.Mapping.Functions.SendMapData(ply) -- Update the data to players
	end
	
	nz.Mapping.MismatchData["Map Settings"] = nil 
end)