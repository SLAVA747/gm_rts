AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

function ENT:Initialize()
	self:PhysicsInitSphere( 5, "default" )
	self:Ignite( 1.8, 0.1 )
	timer.Simple( 1.8, function()
		if (self:IsValid()) then
			util.BlastDamage( self, self, self:GetPos(), 100, 30 )
			local effectdata = EffectData()
			effectdata:SetOrigin( self:GetPos() )
			util.Effect( "Explosion", effectdata )
			self:Remove()
		end
	end	)
end