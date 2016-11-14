-- Setup round module
nzTraps = nzTraps or AddNZModule("Traps")
nzLogic = nzLogic or AddNZModule("Logic")

nzTraps.Registry = nzTraps.Registry or {}
nzLogic.Registry = nzLogic.Registry or {}

local function register (tbl, name, classname)
	tbl[name] = classname
end

function nzTraps:Register(name, classname)
	register(self.Registry, name, classname)
end

function nzLogic:Register(name, classname)
	register(self.Registry, name, classname)
end

function nzTraps:GetAll()
	return self.Registry
end

function nzLogic:GetAll()
	return self.Registry
end
