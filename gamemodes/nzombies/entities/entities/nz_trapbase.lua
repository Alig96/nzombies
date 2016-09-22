-- Vurrently no trap specfic behaviour but this might change in the future.
-- So use this baseclass if you are creating a custom trap.

AddCSLuaFile( )

ENT.Type = "anim"
ENT.Base = "nz_activatable"

ENT.PrintName = "nz_trapbase"

DEFINE_BASECLASS("nz_activatable")

-- IMPLEMENT ME
function ENT:OnActivation() end

function ENT:OnDeactivation() end

function ENT:OnReady() end
