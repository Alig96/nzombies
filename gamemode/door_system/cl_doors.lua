nz.Doors.Data = {}
nz.Doors.Data.EaDI = {}
nz.Doors.Data.LinkFlags = {}
nz.Doors.Data.OpenedLinks = {}
nz.Doors.Data.BuyableBlocks = {}

net.Receive( "nz_Doors_Sync", function( length )
	print("Door Sync Received!")
	nz.Doors.Data = net.ReadTable()
	PrintTable(nz.Doors.Data)
end )