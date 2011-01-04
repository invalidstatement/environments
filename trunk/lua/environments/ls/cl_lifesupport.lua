------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------

SRP.suit = {}
SRP.suit.air = 0
SRP.suit.coolant = 0
SRP.suit.energy = 0
SRP.suit.o2per = 0

//Create the VGUI
topbar = vgui.Create( "LS Debug Bar" )
topbar:SetVisible( true )

local function LSUpdate(msg) --recieves life support update packet
	local hash = {}
	hash.air = msg:ReadShort() --Get air left in suit
	hash.coolant = msg:ReadShort() --Get coolant left in suit
	hash.energy = msg:ReadShort() --Get energy left in suit
	SRP.suit = hash
	SRP.suit.temperature = msg:ReadShort() --Get energy left in suit
	SRP.suit.o2per = msg:ReadShort()
	SRP.suit.temp = msg:ReadShort()
end
usermessage.Hook( "LSUpdate", LSUpdate )
