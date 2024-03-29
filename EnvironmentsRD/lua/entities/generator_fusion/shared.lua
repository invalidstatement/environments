ENT.Type 		= "anim"
ENT.Base 		= "base_env_entity"
ENT.PrintName 	= "Fusion Reactor"

list.Set( "LSEntOverlayText" , "generator_fusion", {HasOOO = true, num = 2, resnames = {"water"}, genresnames={"energy"}} )

if(SERVER)then
	
	local T = {} --Create a empty Table
	
	T.Power = function(Device,ply,Data)
		Device:SetActive( nil, ply )
	end
	
	ENT.Panel=T --Set our panel functions to the table.
	
else 
	function ENT:PanelFunc(um,e,entID)
	
		e.Functions={}
		
		e.DevicePanel = [[
		@<Button>Toggle Power</Button><N>PowerButton</N><Func>Power</Func>
		]]

		e.Functions.Power = function()
			RunConsoleCommand( "envsendpcommand",entID,"Power")
		end
	end
end