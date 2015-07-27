//

function nz.PropsMenu.Functions.AddNewCategory( text, tooltip )
	if tooltip == nil then
		tooltip = true
	end
	nz.PropsMenu.Data.Categorys[text] = tooltip
end

function nz.PropsMenu.Functions.AddNewModel( cat, model )
	table.insert(nz.PropsMenu.Data.Models, {cat, model})
end

//QuickFunctions

PropMenuAddCat = nz.PropsMenu.Functions.AddNewCategory
PropMenuAddModel = nz.PropsMenu.Functions.AddNewModel

//Use
PropMenuAddCat("Gates")
PropMenuAddModel("Gates", "models/props_c17/fence03a.mdl")
PropMenuAddModel("Gates", "models/props_c17/fence02b.mdl")
PropMenuAddModel("Gates", "models/props_c17/fence01b.mdl")
PropMenuAddModel("Gates", "models/props_c17/gate_door01a.mdl")
PropMenuAddModel("Gates", "models/props_c17/gate_door02a.mdl")
PropMenuAddModel("Gates", "models/props_building_details/Storefront_Template001a_Bars.mdl")
PropMenuAddModel("Gates", "models/props_borealis/borealis_door001a.mdl")
PropMenuAddModel("Gates", "models/props_wasteland/interior_fence001g.mdl")
PropMenuAddModel("Gates", "models/props_wasteland/interior_fence002d.mdl")
PropMenuAddModel("Gates", "models/props_wasteland/wood_fence01a.mdl")
PropMenuAddModel("Gates", "models/props_lab/blastdoor001a.mdl")
PropMenuAddModel("Gates", "models/props_lab/blastdoor001b.mdl")
PropMenuAddModel("Gates", "models/props_lab/blastdoor001c.mdl")
PropMenuAddModel("Gates", "models/props_wasteland/wood_fence02a.mdl")
PropMenuAddModel("Gates", "models/props_wasteland/prison_celldoor001b.mdl")
PropMenuAddModel("Gates", "models/props_interiors/ElevatorShaft_Door01a.mdl")

PropMenuAddCat("Scenery")
PropMenuAddModel("Scenery", "models/props_borealis/bluebarrel001.mdl")
PropMenuAddModel("Scenery", "models/props_interiors/Furniture_shelf01a.mdl")
PropMenuAddModel("Scenery", "models/props_junk/TrashDumpster02.mdl")
PropMenuAddModel("Scenery", "models/props_interiors/VendingMachineSoda01a.mdl")
PropMenuAddModel("Scenery", "models/props_wasteland/laundry_dryer001.mdl")
PropMenuAddModel("Scenery", "models/props_wasteland/laundry_dryer002.mdl")
PropMenuAddModel("Scenery", "models/props_wasteland/kitchen_stove002a.mdl")
PropMenuAddModel("Scenery", "models/props_wasteland/controlroom_storagecloset001b.mdl")
PropMenuAddModel("Scenery", "models/props_wasteland/medbridge_post01.mdl")
