AddCSLuaFile( )

ENT.Type = "anim"
 
ENT.PrintName		= "button_elec"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""


function ENT:Initialize()
	if SERVER then
		self:SetModel( "models/MaxOfS2D/button_01.mdl" )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetUseType( ONOFF_USE )
		self.On = false
	else
		self.PosePosition = 0
	end
end

function ENT:Use( activator )

	if ( !activator:IsPlayer() ) then return end
	if !self.On and (conv.GetRoundState() == ROUND_PREP or conv.GetRoundState() == ROUND_PROG) then
		self.On = true
		PrintMessage( HUD_PRINTTALK, "[NZ] Electricity is now on!" )
		hook.Call( "nzombies_elec_active" )
	end

end
	function ENT:Think()
		if SERVER then
			--print(self.On)
		else
			self:UpdateLever()
		end
	end
if CLIENT then

	function ENT:UpdateLever()

		local TargetPos = 0.0;
		
		if ( self.On ) then TargetPos = 1.0; end
		
		self.PosePosition = math.Approach( self.PosePosition, TargetPos, FrameTime() * 5.0 )	
		
		self:SetPoseParameter( "switch", self.PosePosition )
		self:InvalidateBoneCache()

	end
	
	function ENT:Draw()
		self:DrawModel()
	end
	
	hook.Add( "PreDrawHalos", "button_elec_halos", function()
		halo.Add( ents.FindByClass( "button_elec" ), Color( 255, 0, 255 ), 0, 0, 0.1 )
	end )
end
