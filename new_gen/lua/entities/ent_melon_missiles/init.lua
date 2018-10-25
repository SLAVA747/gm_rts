AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

function ENT:Initialize()

	--print("Started Initialize")

	MW_Defaults ( self )

	--print("Changing stats")

	self.modelString = "models/xqm/rails/trackball_1.mdl"
	self.moveType = MOVETYPE_VPHYSICS
	self.speed = 80
	self.spread = 10
	self.damageDeal = 1
	self.maxHP = 40
	self.range = 350
	self.minRange = 50

	self.sphereRadius = 15
	
	self.careForWalls = true
	
	self.nextShot = CurTime()+2
	self.fireDelay = 2.5

	self.shotOffset = Vector(0,0,10)
	
	self.population = 3
	
	self.shotSound = "weapons/ar2/ar2_altfire.wav"
	self.tracer = "AR2Tracer"
	
	self.slowThinkTimer = 1
	
	--print("Finished changing stats")
	
	MW_Setup ( self )
	
	--print("Finished Initialize")
end

function ENT:ModifyColor()
	self:SetColor(Color(self:GetColor().r/1.5, self:GetColor().g/1.5, self:GetColor().b/1.5, 255))
end

function ENT:SlowThink ( ent )
	MW_UnitDefaultThink ( ent )
end

function ENT:Shoot ( ent )
	if (ent.nextShot < CurTime()) then
		sound.Play( ent.shotSound, ent:GetPos() )
		if (IsValid(ent.targetEntity)) then
		
			local targetPos = ent.targetEntity:GetPos()
			if (ent.targetEntity:GetVar("shotOffset") ~= nil) then
				targetPos = targetPos+ent.targetEntity:GetVar("shotOffset")
			end
			
			local bullet = ents.Create( "ent_melonbullet_missile" )
			if ( !IsValid( bullet ) ) then return end -- Check whether we successfully made an entity, if not - bail
			bullet:SetPos( ent:GetPos() + Vector(0,0,10) )
			bullet:SetNWInt("mw_melonTeam",self.mw_melonTeam)
			bullet:Spawn()
			bullet:SetNWEntity("target", ent.targetEntity)
			ent.fired = true
			ent.nextShot = CurTime()+ent.fireDelay
		end
	end
end

function ENT:DeathEffect ( ent )
	MW_DefaultDeathEffect ( ent )
end