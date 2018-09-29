AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

function ENT:Initialize()
	--print("Started Initialize")

	PropDefaults ( self )

	self.moveType = MOVETYPE_VPHYSICS
	self.maxHP = 100
	
	self.modelString = "models/hunter/blocks/cube05x105x05.mdl"
	self.materialString = "phoenix_storms/dome"
	
	self.deathSound = "ambient/explosions/explode_9.wav"
	self.deathEffect = "Explosion"

	--print("Finished changing stats")
	PropSetup ( self )
	
	--print("Finished Initialize")
	self:SetCollisionGroup(COLLISION_GROUP_DISSOLVING)
end

function ENT:PropDeathEffect ( ent )
	MW_PropDefaultDeathEffect ( ent )
end