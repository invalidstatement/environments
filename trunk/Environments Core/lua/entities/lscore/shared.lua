
ENT.Type = "anim"
ENT.Base = "base_rd3_entity"
ENT.PrintName = "LS Core"
ENT.Author = "CmdrMatthew"
ENT.Purpose = "To Test"
ENT.Instructions = "Eat up!" 
ENT.Category = "Environments"

ENT.Spawnable = true
ENT.AdminSpawnable = true


list.Set( "LSEntOverlayText" , "lscore", {HasOOO = true, resnames ={ "oxygen", "energy", "water", "nitrogen"} } )

/*if CLIENT then
	function ENT:Draw()
	
	end
end*/