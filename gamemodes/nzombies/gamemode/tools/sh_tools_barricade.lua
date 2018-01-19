nzTools:CreateTool("barricade", {
	displayname = "Barricade Creator",
	desc = "LMB: Place Barricade, RMB: Remove Barricade",
	condition = function(wep, ply)
		return true
	end,
	PrimaryAttack = function(wep, ply, tr, data)
		local ent = tr.Entity
		if IsValid(ent) and ent:GetClass() == "breakable_entry" then
			nzMapping:BreakEntry(ent:GetPos(), ent:GetAngles(), data.planks, data.jump, ply)
			ent:Remove()
		else
			nzMapping:BreakEntry(tr.HitPos + Vector(0,0,45), Angle(0,(tr.HitPos - ply:GetPos()):Angle()[2],0), data.planks, data.jump, ply)
		end
	end,
	SecondaryAttack = function(wep, ply, tr, data)
		if IsValid(tr.Entity) and tr.Entity:GetClass() == "breakable_entry" then
			tr.Entity:Remove()
		end
	end,
	Reload = function(wep, ply, tr, data)
		//Nothing
	end,
	OnEquip = function(wep, ply, data)

	end,
	OnHolster = function(wep, ply, data)

	end
}, {
	displayname = "Barricade Creator",
	desc = "LMB: Place Barricade, RMB: Remove Barricade",
	icon = "icon16/door.png",
	weight = 7,
	condition = function(wep, ply)
		return true
	end,
	interface = function(frame, data)
		local valz = {}
		valz["Row1"] = data.planks
		valz["Row2"] = data.jump

		local DProperties = vgui.Create( "DProperties", frame )
		DProperties:SetSize( 280, 180 )
		DProperties:SetPos( 10, 10 )
		
		function DProperties.CompileData()
			data.planks = valz["Row1"]
			data.jump = valz["Row2"]

			--PrintTable(data)
			
			return data
		end
		
		function DProperties.UpdateData(data) -- This function will be overwritten if opened via context menu
			nzTools:SendData(data, "barricade")
		end

		local Row1 = DProperties:CreateRow( "Barricade", "Has Planks?" )
		Row1:Setup( "Boolean" )
		Row1:SetValue( valz["Row1"] )
		Row1.DataChanged = function( _, val ) valz["Row1"] = val DProperties.UpdateData(DProperties.CompileData()) end
		local Row2 = DProperties:CreateRow( "Barricade", "Jump Animations?" )
		Row2:Setup( "Boolean" )
		Row2:SetValue( valz["Row2"] )
		Row2.DataChanged = function( _, val ) valz["Row2"] = val DProperties.UpdateData(DProperties.CompileData()) end

		return DProperties
	end,
	defaultdata = {
		planks = 1,
		jump = 0,
	}
})