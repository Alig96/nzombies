local function DrawItemCarryHud()

	local scale = (ScrW()/1920 + 1)/2
	local ply = LocalPlayer()
	surface.SetDrawColor(255,255,255)
	local num = 0
	for k,v in pairs(ply:GetCarryItems()) do
		local item = nzItemCarry.Items[v]
		if item and item.icon then
			surface.SetMaterial(item.icon)
			surface.DrawTexturedRect(ScrW() - 400*scale - num*32*scale, ScrH() - 90*scale, 30*scale, 30*scale)
			num = num + 1
		end
	end
	--[[local num = LocalPlayer():GetAmmoCount("nz_grenade")
	local numspecial = LocalPlayer():GetAmmoCount("nz_specialgrenade")
	local scale = (ScrW()/1920 + 1)/2

	--print(num)
	if num > 0 then
		surface.SetMaterial(grenade_icon)
		surface.SetDrawColor(255,255,255)
		for i = num, 1, -1 do
			--print(i)
			surface.DrawTexturedRect(ScrW() - 250*scale - i*10*scale, ScrH() - 90*scale, 30*scale, 30*scale)
		end
	end
	if numspecial > 0 then
		surface.SetMaterial(grenade_icon)
		surface.SetDrawColor(255,100,100)
		for i = numspecial, 1, -1 do
			--print(i)
			surface.DrawTexturedRect(ScrW() - 300*scale - i*10*scale, ScrH() - 90*scale, 30*scale, 30*scale)
		end
	end
	--surface.DrawTexturedRect(ScrW()/2, ScrH()/2, 100, 100)]]
end

local itemnotif = itemnotif or {}

net.Receive( "nzItemCarryPlayersNotif", function()
	local ply = net.ReadEntity()
	local id = net.ReadString()
	
	if itemnotif[id] then
		itemnotif[id].time = CurTime() + 5
		if IsValid(itemnotif[id].avatar) then
			if IsValid(ply) then
				itemnotif[id].avatar:SetPlayer(ply)
			else
				itemnotif[id].avatar:Remove()
				itemnotif[id].avatar = nil
			end
		else
			if IsValid(ply) then
				itemnotif[id].avatar = vgui.Create("AvatarImage")
				itemnotif[id].avatar:SetSize( 32, 32 )
				itemnotif[id].avatar:SetPos( 0, 0 )
				itemnotif[id].avatar:SetPlayer( ply, 32 )
			end
		end
	else
		local item = nzItemCarry.Items[id]
		local avatar
		if IsValid(ply) then
			avatar = vgui.Create("AvatarImage")
			avatar:SetSize( 32, 32 )
			avatar:SetPos( 0, 0 )
			avatar:SetPlayer( ply, 32 )
		end
		if item then --and item.notif then
			itemnotif[id] = {
				avatar = avatar,
				time = CurTime() + 5,
			}
		end
	end
	
	surface.PlaySound("ambient/levels/caves/dist_grub3.wav")
end)

local function DrawItemCarryNotifications()
	--local scale = (ScrW()/1920 + 1)/2
	surface.SetDrawColor(255,255,255)
	local num = 0
	for k,v in pairs(itemnotif) do
		local item = nzItemCarry.Items[k]
		if item and item.icon then
			local avatar = v.avatar
			local time = v.time
			surface.SetMaterial(item.icon)
			if time < CurTime() then
				local fade = (1-(CurTime()-time))*255
				surface.SetDrawColor(255,255,255, fade)
				if fade <= 0 then
					itemnotif[k] = nil
					if IsValid(avatar) then
						avatar:Remove()
					end
				end
			end
			
			local x = ScrW() - 96 - num*35
			surface.DrawTexturedRect(x, 32, 64, 64)
			if IsValid(avatar) then
				avatar:SetPos(x + 32, 75)
			end
			num = num + 1
		end
	end
end

hook.Add("HUDPaint", "nzItemCarryHUD", DrawItemCarryHud )
hook.Add("HUDPaint", "nzItemCarryNotifications", DrawItemCarryNotifications )
