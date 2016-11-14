nzTools:CreateTool("traps_logic", {
	displayname = "Traps, Buttons, Logic",
	desc = "LMB: Create Entity, RMB: Remove Entity",
	condition = function(wep, ply)
		return true
	end,
	PrimaryAttack = function(wep, ply, tr, data)
		local ent = ents.Create(data.classname)
		ent:SetPos(tr.HitPos)
		ent:Activate()
		ent:Spawn()
	end,
	SecondaryAttack = function(wep, ply, tr, data)
		if IsValid(tr.Entity) then
			tr.Entity:Remove()
		end
	end,
	Reload = function(wep, ply, tr, data)
	end,
	OnEquip = function(wep, ply, data)

	end,
	OnHolster = function(wep, ply, data)

	end
}, {
	displayname = "Traps, Buttons, Logic",
	desc = "LMB: Create Entity, RMB: Remove Entity",
	icon = "icon16/controller.png",
	weight = 15,
	condition = function(wep, ply)
		return nzTools.Advanced
	end,
	interface = function(frame, data, context)

		local cont = vgui.Create("DScrollPanel", frame)
		cont:Dock(FILL)

		function cont.CompileData()
			return data
		end

		function cont.UpdateData(data)
			nzTools:SendData(data, "traps_logic") -- Save the same data here
		end

		local function genSpawnList(tbl, parent)
			local list	= vgui.Create( "DIconLayout", parent )
			list:Dock(FILL)
			list:SetPos( 0, 0 )
			list:SetSpaceY( 5 )
			list:SetSpaceX( 5 )

			for name, classname in pairs(tbl) do
				local model = baseclass.Get(classname).SpawnIcon
				if model then
					local entityIcon = list:Add( "SpawnIcon" )
					entityIcon:SetSize( 60, 60 )
					entityIcon:SetModel(model)
					entityIcon:SetFont("DermaLarge")
					entityIcon:SetTextColor(Color(0, 0, 0))
					entityIcon:SetTooltip(name)
					entityIcon.DoClick = function()
						cont.UpdateData({classname = classname})
					end
					entityIcon.Paint = function(self)
						self.OverlayFade = math.Clamp( ( self.OverlayFade or 0 ) - RealFrameTime() * 640 * 2, 0, 255 )
						if data.classname == classname then
							surface.SetDrawColor(0,0,200)
							self:DrawOutlinedRect()
						end
					end
				end
			end

			return list
		end

		local traps = vgui.Create( "DCollapsibleCategory", cont )
		traps:SetExpanded( 1 )
		traps:SetLabel( "Traps" )
		traps:Dock(TOP)
		traps:SetHeight(200)

		local trapsScroll = vgui.Create( "DScrollPanel", traps )
		trapsScroll:Dock(FILL)

		genSpawnList(nzTraps:GetAll(), trapsScroll)


		local logic = vgui.Create( "DCollapsibleCategory", cont )
		logic:SetExpanded( 1 )
		logic:SetLabel( "Logic" )
		logic:Dock(TOP)
		logic:SetHeight(200)

		local logicScroll = vgui.Create( "DScrollPanel", logic )
		logicScroll:Dock(FILL)

		genSpawnList(nzLogic:GetAll(), logicScroll)

		return cont
	end,
	defaultdata = {
		model = "models/hunter/plates/plate2x2.mdl"
	},
})
