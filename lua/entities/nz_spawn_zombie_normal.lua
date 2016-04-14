ENT.Base = "nz_zombie_spawn"
ENT.PrintName = "nz_spawn_zombie_normal"

function ENT:OnRemove()
	if SERVER and table.HasValue(nz.Enemies.Data.RespawnableSpawnpoints, self) then
		table.RemoveByValue(nz.Enemies.Data.RespawnableSpawnpoints, self)
	end
end
