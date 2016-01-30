AddCSLuaFile()

ENT.Base = "nz_zombiebase"
ENT.PrintName = "Hellhound"
ENT.Category = "Brainz"
ENT.Author = "Lolle"

ENT.Models = { "models/player/slow/amberlyn/re5/dog/slow.mdl" } --Temp model

function ENT:SpecialInit()
    if SERVER then
        self:SetRunSpeed( nz.Curves.Data.Speed[nz.Rounds.Data.CurrentRound] * 1.5 )
        self:SetHealth( nz.Curves.Data.Health[nz.Rounds.Data.CurrentRound] * 1.5 )
    end
end
