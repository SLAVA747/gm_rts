AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

function ENT:Initialize()

	MW_Defaults ( self )

	self.modelString = "models/xqm/afterburner1.mdl"
	self.moveType = MOVETYPE_VPHYSICS
	self.canMove = true

	self.maxHP = 50
	self.speed = 50
	self.range = 250
	self.spread = 150
	self.damageDeal = 0.5
	self.shotSound = "weapons/shotgun/shotgun_dbl_fire.wav"

	self.buildingDamageMultiplier = 0.7
	
	self.shotOffset = Vector(0,0,5)

	self.angularDamping = 10

	//self:SetPos(self:GetPos()+Vector(0,0,12))
	
	self.nextShot = CurTime()+3

	self.population = 3
	
	MW_Setup ( self )

	construct.SetPhysProp( self:GetOwner() , self, 0, nil,  { GravityToggle = true, Material = "ice" } )
end

function ENT:ModifyColor()
	self:SetColor(Color(self:GetColor().r/1.5, self:GetColor().g/1.5, self:GetColor().b/1.5, 255))
end

function ENT:SlowThink ( ent )
	--local vel = ent.phys:GetVelocity()
	--ent.phys:SetAngles( ent.Angles )
	--ent.phys:SetVelocity(vel)
	MW_UnitDefaultThink ( ent )

end

function ENT:PhysicsUpdate()

	local inclination = self:Align(self:GetAngles():Up(), Vector(0,0,1), 3000)
	self.phys:ApplyForceCenter( Vector(0,0,inclination*100))

	self:DefaultPhysicsUpdate()
end

function ENT:Shoot ( ent, forceTargetPos )
	if (ent.nextShot < CurTime()) then
		local pos = ent:GetPos()+ent.shotOffset
		--------------------------------------------------------Disparar
		if (forceTargetPos != nil or IsValid(ent.targetEntity)) then
			local targetPos
			if (IsValid(ent.targetEntity)) then
				targetPos = ent.targetEntity:GetPos()+ent.targetEntity:OBBCenter()
				if (ent.targetEntity:GetVar("shotOffset") ~= nil) then
					if (ent.targetEntity:GetVar("shotOffset") ~= Vector(0,0,0)) then
						targetPos = ent.targetEntity:GetPos()+ent.targetEntity:GetVar("shotOffset")
					end
				end
			else
				targetPos = forceTargetPos
			end

			local baseDir = targetPos-pos
			local right = Vector(baseDir.y, -baseDir.x, 0)
			local axis = right:Cross(baseDir):GetNormalized()
			local bulletCount = 21
			local baseAngle = baseDir:Angle()
			for i=0, bulletCount do
				local rotatedDir = Angle(baseAngle.p, baseAngle.y, baseAngle.r)
				rotatedDir:RotateAroundAxis(axis, (i-math.Round(bulletCount/2))*self.spread/bulletCount)
				local dir = rotatedDir:Forward()
				local bullet = {}
				bullet.Num=1
				bullet.Src=pos
				bullet.Dir=dir
				bullet.Spread=Vector(0,0,0)
				bullet.Tracer=1	
				bullet.TracerName=ent.tracer
				bullet.Force=2

				bullet.Damage=ent.damageDeal
				
				bullet.Distance=ent.range*1.1

				ent.fired = true

				ent.nextShot = CurTime()+3.5

				bullet.Callback = function(attacker,tr,dmginfo)
					if tr.Entity:IsValid() then 
						if (not attacker:SameTeam(tr.Entity)) then
							tr.Entity:Ignite(2.5)
						end
						return
					end
				end
				ent:FireBullets(bullet)
				
				
			end
			local effectdata = EffectData()
					effectdata:SetScale(1)
					effectdata:SetAngles( (baseDir):Angle()) 
					effectdata:SetOrigin( pos + (baseDir):GetNormalized()*10 )
				util.Effect( "MuzzleEffect", effectdata )
			sound.Play( ent.shotSound, pos )
		end
	end
end

function ENT:DeathEffect ( ent )
	MW_DefaultDeathEffect ( ent )
end