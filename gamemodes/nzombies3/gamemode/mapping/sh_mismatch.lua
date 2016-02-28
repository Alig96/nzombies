nz.Mapping.Mismatch = nz.Mapping.Mismatch or {}
nz.Mapping.MismatchData = nz.Mapping.MismatchData or {}

if SERVER then
	util.AddNetworkString("nzMappingMismatchData")
	util.AddNetworkString("nzMappingMismatchEnd")
	
	net.Receive("nzMappingMismatchData", function()
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
		sheet:SetSize(390, 465)
		
		for k,v in pairs(nz.Mapping.MismatchData) do
			local panel = nz.Mapping.Mismatch[k].Interface(sheet)
			sheet:AddSheet(k, panel, "icon16/cross.png")
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
		net.Start("nzMappingMismatchData")
			net.WriteString(k)
			net.WriteTable(data)
		net.Send(loader)
	end
	
	net.Start("nzMappingMismatchEnd")
	net.Send(loader)
end

CreateMismatchCheck("Wall Buys", function()
	local tbl = {}
	for k,v in pairs(ents.FindByClass("wall_buys")) do
		if !weapons.Get(v:GetEntName()) then
			print(v:GetEntName().." is missing!")
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
	
	local submit = vgui.Create("DButton", pnl)
	submit:SetText("Submit Changes")
	submit:SetSize(200, 30)
	submit:SetPos(90, 390)
	submit.DoClick = function()
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

CreateMismatchCheck("Wall Buys 2", function()
	local tbl = {}
	for k,v in pairs(ents.FindByClass("wall_buys")) do
		if !weapons.Get(v:GetEntName()) then
			print(v:GetEntName().." is missing!")
			tbl[v:GetEntName()] = true
		end
	end
	
	return tbl -- Return the data you want to send to the client

end, function(frame)

	local pnl = vgui.Create("DPanel", frame)
	pnl:SetPos(5, 5)
	pnl:SetSize(380, 455)
	
	local properties = vgui.Create("DProperties", pnl)
	properties:SetPos(0, 0)
	properties:SetSize(380, 440)
	
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
	
	local submit = vgui.Create("DButton", pnl)
	submit:SetText("Submit Changes")
	submit:SetSize(200, 30)
	submit:SetPos(90, 420)
	submit.DoClick = function()
		net.Start("nzMappingMismatchData")
			net.WriteString("Wall Buys")
			net.WriteTable(nz.Mapping.MismatchData["Wall Buys"])
		net.SendToServer()
		nz.Mapping.MismatchData["Wall Buys"] = nil -- Clear the data
	end
	
	return pnl
	
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