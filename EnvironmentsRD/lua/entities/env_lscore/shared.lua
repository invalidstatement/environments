
ENT.Type = "anim"
ENT.Base = "base_env_entity"
ENT.PrintName = "LS Core"
ENT.Author = "CmdrMatthew"
ENT.Purpose = "To Test"
ENT.Instructions = "Eat up!" 
ENT.Category = "Environments"


list.Set( "LSEntOverlayText" , "env_lscore", {HasOOO = true, resnames ={ "oxygen", "energy", "water", "nitrogen"} } )

/*if CLIENT then
	function ENT:Draw()
	
	end
end*/