--pool network strings
util.AddNetworkString( "nzRoundNumber" )
util.AddNetworkString( "nzRoundState" )
util.AddNetworkString( "nzRoundSpecial" )
util.AddNetworkString( "nzPlayerReadyState" )
util.AddNetworkString( "nzPlayerPlayingState" )

function Round:GetZombiesKilled()
	return self.ZombiesKilled
end
function Round:SetZombiesKilled( num )
	self.ZombiesKilled = num
end

function Round:GetZombiesSpawned()
	return self.ZombiesSpawned
end
function Round:SetZombiesSpawned( num )
	self.ZombiesSpawned = num
end
function Round:IncrementZombiesSpawned()
	self:SetZombiesSpawned( self:GetZombiesSpawned() + 1 )
end

function Round:GetZombiesMax()
	return self.ZombiesMax
end
function Round:SetZombiesMax( num )
	self.ZombiesMax = num
end

function Round:GetZombieData()
	return self.ZombieData
end
function Round:SetZombieData( tbl )
	self.ZombieData = tbl
	self:SetSpecial(tbl.special or false)
end

function Round:InState( state )
	return self:GetState() == state
end

function Round:IsSpecial()
	return self.SpecialRound or false
end

function Round:SetSpecial( bool )
	self.SpecialRound = bool or false
end

function Round:InProgress()
	return self:GetState() == ROUND_PREP or self:GetState() == ROUND_PROG
end

function Round:SetState( state )

	self.RoundState = state

	self:SendState( state )

end

function Round:GetState()

	return self.RoundState

end

function Round:SetNumber( number )

	self.Number = number

	self:SendNumber( number )

end

function Round:IncrementNumber()

	self:SetNumber( self:GetNumber() + 1 )

end

function Round:GetNumber()

	return self.Number

end

function Round:SendNumber( number, ply )

	net.Start( "nzRoundNumber" )
		net.WriteUInt( number or 0, 16 )
	return ply and net.Send( ply ) or net.Broadcast()

end

function Round:SendState( state, ply )

	net.Start( "nzRoundState" )
		net.WriteUInt( state or ROUND_WAITING, 3 )
	return ply and net.Send( ply ) or net.Broadcast()

end

function Round:SendSpecialRound( bool, ply )

	net.Start( "nzRoundSpecial" )
		net.WriteBool( bool or false )
	return ply and net.Send( ply ) or net.Broadcast()

end

function Round:SendReadyState( ply, state, recieverPly )

	net.Start( "nzPlayerReadyState" )
		net.WriteEntity( ply )
		net.WriteBool( state )
	return recieverPly and net.Send( recieverPly ) or net.Broadcast()

end

function Round:SendPlayingState( ply, state, recieverPly )

	net.Start( "nzPlayerPlayingState" )
		net.WriteEntity( ply )
		net.WriteBool( state )
	return recieverPly and net.Send( recieverPly ) or net.Broadcast()

end

function Round:SetEndTime( time )

	SetGlobalFloat( "nzEndTime", time )

end

function Round:GetEndTime( time )

	GetGlobalFloat( "nzEndTime" )

end

function Round:SendSync( ply )

	self:SendState( self:GetState(), ply )
	self:SendNumber( self:GetNumber(), ply )
	self:SendSpecialRound( self:IsSpecial(), ply )

	for _, v in pairs( player.GetAll() ) do
		self:SendReadyState( v, v:GetReady(), ply )
	end

	self:SetEndTime( self:GetEndTime() )

end
