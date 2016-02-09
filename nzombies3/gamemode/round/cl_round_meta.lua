function Round:GetState() return self.State end
function Round:SetState( state ) self.State = state end

function Round:GetNumber() return self.Number or 0 end
function Round:SetNumber( num ) self.Number = num end

function Round:InState( state )
	return Round:GetState() == state
end

function Round:InProgress()
	return Round:GetState() == ROUND_PREP or Round:GetState() == ROUND_PROG
end

local function receiveRoundState()

	local old = Round:GetState()
	new = net.ReadUInt( 3 )

	Round:SetState( new )

	if old != new then
		Round:StateChange( old, new )
	end

end
net.Receive( "nzRoundState", receiveRoundState )


local function receiveRoundNumber()

    Round:SetNumber( net.ReadUInt( 16 ) )

end
net.Receive( "nzRoundNumber", receiveRoundnumber )


local function receivePlayerReadyState()

    net.ReadEntity():SetReady( net.ReadBool() )

end
net.Receive( "nzPlayerReadyState", receivePlayerReadyState )

local function receivePlayerPlayingState()

    net.ReadEntity():SetPlaying( net.ReadBool() )

end
net.Receive( "nzPlayerPlayingState", receivePlayerPlayingState )
