AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

function ENT:Initialize()

	--print("Started Initialize")

	MW_Defaults ( self )

	--print("Changing stats")

	self.modelString = "models/props_borealis/bluebarrel001.mdl"
	self.moveType = MOVETYPE_VPHYSICS
	self.speed = 60
	self.spread = 20
	self.damageDeal = 3
	self.maxHP = 75
	self.range = 500
	self.minRange = 200
	
	self:SetPos(self:GetPos()+Vector(0,0,18))
	
	--self.Angles = Angle(0,0,0)
	
	self.careForFriendlyFire = false
	self.careForWalls = false
	self.shotOffset = Vector(0,0,15)
	
	self.fireDelay = 8
	
	self.damping = 5
	
	self.population = 5
	
	self.nextShot = CurTime()+3
	
	self.shotSound = "weapons/ar2/npc_ar2_altfire.wav"
	self.tracer = "AR2Tracer"
	
	self.slowThinkTimer = 0.5
	
	--print("Finished changing stats")
	
	MW_Setup ( self )
	--print("Finished Initialize")
	construct.SetPhysProp( self:GetOwner() , self, 0, nil,  { GravityToggle = true, Material = "ice" } )
end

function ENT:ModifyColor()
	self:SetColor(Color(self:GetColor().r/1.8, self:GetColor().g/1.8, self:GetColor().b/1.8, 255))
end

function ENT:SlowThink ( ent )
	MW_UnitDefaultThink ( ent )
end

function ENT:PhysicsUpdate()

	local inclination = self:Align(self:GetAngles():Up(), Vector(0,0,1), 10000)
	self.phys:ApplyForceCenter( Vector(0,0,inclination*100))

	self:DefaultPhysicsUpdate()
end

function ENT:Shoot ( ent )

	if (ent:GetVelocity():Length() < 15 && ent.nextShot < CurTime()) then
		sound.Play( ent.shotSound, ent:GetPos() )
		if (IsValid(ent.targetEntity)) then
		
			local targetPos = ent.targetEntity:GetPos()
			if (ent.targetEntity:GetVar("shotOffset") ~= nil) then
				targetPos = targetPos+ent.targetEntity:GetVar("shotOffset")
			end
			
			local shootVector = (targetPos-ent:GetPos() + Vector(0, 0, 700) + Vector(math.random(-70,70),math.random(-70,70),math.random(-70,70)))*36
			--local shootVector = (targetPos-ent:GetPos() + Vector(0, 0, 700))*36
			local bullet = ents.Create( "ent_melonbullet_bomb" )
			if ( !IsValid( bullet ) ) then return end -- Check whether we successfully made an entity, if not - bail
			bullet:SetPos( ent:GetPos() + Vector(0,0,50) )
			bullet:SetNWInt("mw_melonTeam",self.mw_melonTeam)
			bullet:SetModel("models/props_phx/misc/smallcannonball.mdl")
			bullet:Spawn()
			bullet:SetSolid( SOLID_VPHYSICS )         -- Toolbox
			bullet:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
			bulletphys = bullet:GetPhysicsObject()
			bulletphys:ApplyForceCenter( shootVector )
			bulletphys:SetDamping(0.3,3)
			ent.fired = true
			ent.nextShot = CurTime()+ent.fireDelay
		end
	end
end

function ENT:DeathEffect ( ent )
	MW_DefaultDeathEffect ( ent )
end