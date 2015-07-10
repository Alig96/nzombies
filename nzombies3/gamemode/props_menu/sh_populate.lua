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

PropMenuAddCat("Scenery")
PropMenuAddModel("Scenery", "models/props_borealis/bluebarrel001.mdl")

PropMenuAddCat("Dicks")
PropMenuAddModel("Dicks", "models/props_c17/fence03a.mdl")