AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

function ENT:Initialize()
	--print("Started Initialize")

	self:SetPos(self:GetPos()+Vector(0,0,-5))
	
	MW_Defaults ( self )

	--print("Changing stats")
	
	self.modelString = "models/hunter/tubes/circle2x2.mdl"
	self.materialString = "phoenix_storms/future_vents"
	self.moveType = MOVETYPE_NONE
	self.Angles = Angle(0,0,0)
	self:SetPos(self:GetPos()+Vector(0,0,0))
	self.canMove = false
	self.canShoot = false
	self.maxHP = 100
	
	self.active = true
	
	self.slowThinkTimer = 0.1
	
	self.population = 0
	
	self.deathSound = "ambient/explosions/explode_9.wav"
	self.deathEffect = "Explosion"

	self.melons = {}
	--print("Finished changing stats")
	MW_Setup ( self )
	
	--print("Finished Initialize")
end

function ENT:SlowThink(ent)
	local foundEnts = ents.FindInSphere( ent:GetPos()+Vector(0,0,0), 45 )
	local newFoundEnts = ents.FindInSphere( ent:GetPos()+Vector(0,0,60), 45 ) 
	table.Add(foundEnts, newFoundEnts)
	newFoundEnts = ents.FindInSphere( ent:GetPos()+Vector(0,0,120), 45 ) 
	table.Add(foundEnts, newFoundEnts)
	newFoundEnts = ents.FindInSphere( ent:GetPos()+Vector(0,0,180), 45 ) 
	table.Add(foundEnts, newFoundEnts)
	for k, v in pairs( foundEnts ) do
		if (v.Base == "ent_melon_base") then
			if (v.canMove) then
				print(v)
				local phys = v:GetPhysicsObject()
				if (IsValid(phys)) then
					phys:SetVelocity(Vector(0,0,150))
				end
			end
		end
	end
end

function ENT:Shoot ( ent )
	--MW_DefaultShoot ( ent )
end

function ENT:DeathEffect ( ent )
	MW_DefaultDeathEffect ( ent )
end