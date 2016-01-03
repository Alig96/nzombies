//Main Tables
nz.Nav = {}
nz.Nav.Functions = {}
nz.Nav.Data = {}

//Reset navmesh attributes so they don't accidentally save
function GM:ShutDown()
	for k,v in pairs(nz.Nav.Data) do
		navmesh.GetNavAreaByID(k):SetAttributes(v.prev)
	end
end