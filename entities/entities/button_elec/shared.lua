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
		//self.On = false
	else
		self.PosePosition = 0
	end
end

function ENT:Use( activator )

	if ( !activator:IsPlayer() ) then return end
	if !nz.Rounds.Elec and (nz.Rounds.CurrentState == ROUND_PREP or nz.Rounds.CurrentState == ROUND_PROG) then
		//self.On = true
		hook.Call( "nz_elec_active" )
	end

end
	function ENT:Think()
		if SERVER then
			--print(self.On)
		else
			//self:UpdateLever()
		end
	end
if CLIENT then

	-- function ENT:UpdateLever()

		-- local TargetPos = 0.0;
		
		-- if ( self.On ) then TargetPos = 1.0; end
		
		-- self.PosePosition = math.Approach( self.PosePosition, TargetPos, FrameTime() * 5.0 )	
		
		-- self:SetPoseParameter( "switch", self.PosePosition )
		-- self:InvalidateBoneCache()

	-- end
	
	function ENT:Draw()
		self:DrawModel()
	end
end