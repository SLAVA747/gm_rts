AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

function ENT:Initialize()

	--print("Started Initialize")
	
	MW_Defaults ( self )

	--print("Changing stats")

	self.modelString = "models/props_junk/watermelon01.mdl"
	self.moveType = MOVETYPE_VPHYSICS
	self.canMove = true

	self.sphereRadius = 7
	
	--print("Finished changing stats")
	
	MW_Setup ( self )
	--print("Finished Initialize")
end

function ENT:SlowThink ( ent )
	MW_UnitDefaultThink ( ent )
end

function ENT:Shoot ( ent )
	MW_DefaultShoot ( ent )
end

function ENT:DeathEffect ( ent )
	MW_DefaultDeathEffect ( ent )
end