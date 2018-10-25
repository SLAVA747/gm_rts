AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.

include("shared.lua")

function MW_Defaults( ent )
	--print("MW_Defaults")
	--ent:NextThink(CurTime() + 0.1)
	ent.maxHP = 20
	ent.HP = 1
	ent:SetNWFloat( "health", 1 )
	ent.speed = 100
	ent.range = 250
	ent.spread = 5
	ent.damageDeal = 4
	ent.buildingDamageMultiplier = 1
	ent.canMove = true
	ent.canBeSelected = true
	ent.sphereRadius = 0
	ent.careForFriendlyFire = true
	ent.careForWalls = true
	ent.targetPos = ent:GetPos()
	local z = Vector(0,0,0)
	ent.rallyPoints = {z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z}

	ent.targetable = true

	ent.minRange = 0
	
	ent.population = 1

	ent.chasing = false
	
	ent.value = 0
	
	ent.damage = 0
	
	ent.fired = false
	ent.gotHit = false
	
	ent.changeAngles = true
	ent.changeModel = true

	ent.spawned = false
	
	ent.shotOffset = Vector(0,0,0)
	ent.modelString = "models/props_junk/watermelon01.mdl"
	ent.materialString = "models/debug/debugwhite"
	
	ent.deathSound = "phx/eggcrack.wav"
	ent.shotSound = "weapons/alyx_gun/alyx_gun_fire6.wav"
	
	ent.tracer = "AR2Tracer"
	ent.onFire = false
	
	ent.deathEffect = "cball_explode"
	
	ent:SetNWInt("mw_melonTeam", 0)
	ent.mw_melonTeam = 0
	ent.canShoot = true
	
	ent.slowThinkTimer = 2

	ent.lastPosition = Vector(0,0,0)
	ent.stuck = 0
	
	ent.Angles = Angle(0,0,0)
	ent:SetMaterial( "Models/effects/comball_sphere" )
	
	ent:SetColor( mw_melonTeam )

	ent.damping = 1.5
	ent.angularDamping = -1
	
	ent.nextSlowThink = 0

	--Bot variables-
	ent.holdGroundPosition = ent:GetPos()
	ent.chaseStance = false
	ent.maxChaseDistance = 800
	ent.barrier = nil
	----------------
end

function ENT:Ini( teamnumber )
	self:SetNWInt("mw_melonTeam", teamnumber)
	self:MelonSetColor( teamnumber )
	self.nextSlowThink = CurTime()+1
	MW_UpdatePopulation(self.population, teamnumber)

	if (teamnumber == 0) then
		self.chaseStance = true
	end
end

function ENT:MelonSetColor( teamnumber )
	local unit_colors  = {Color(255,50,50,255),Color(50,50,255,255),Color(255,200,50,255),Color(30,200,30,255),Color(100,0,80,255),Color(100,255,255,255),Color(255,120,0,255),Color(255,100,150,255)}
	local newColor
	if (teamnumber == 0) then
		newColor = Color(50,50,50,255)
	else
		newColor = unit_colors[teamnumber]
	end
	self:SetColor(newColor)
	self:ModifyColor()
end

function ENT:ModifyColor()
end

function MW_Setup( ent )
	--print("MW_Setup")
	ent.targetEntity = nil
	ent.followEntity = nil
	ent.forcedTargetEntity = nil
	ent:SetNWEntity( "targetEntity", ent.targetEntity )
	ent:SetNWEntity( "followEntity", ent.followEntity )
	ent:SetNWBool("moving", false)
	
	ent.moving = false
	ent.damage = 0

	ent.moveForce = Vector(0,0,0)

	if (ent.changeModel) then
		ent:SetModel( ent.modelString )
	end
	
	if (ent.sphereRadius == 0) then
		ent:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
		ent:SetSolid( SOLID_VPHYSICS )
	else
		ent:PhysicsInitSphere( ent.sphereRadius, "slime" )
	end

	ent.phys = ent:GetPhysicsObject()

	if (ent.moveType == 0) then
		local weld = constraint.Weld( ent, game.GetWorld(), 0, 0, 0, true , false )
		canMove = false
		ent.phys:EnableMotion(false)
	end
	
	if (IsValid(ent.phys)) then
		ent.phys:Wake()
		if (ent.angularDamping == -1) then
			ent.angularDamping = ent.damping
		end
		ent.phys:SetDamping(ent.damping,ent.angularDamping)
	end
	
	if (ent.changeAngles) then
		ent:SetAngles( ent:GetAngles()+ent.Angles )
	end

	ent:SetNWEntity( "targetEntity", ent.targetEntity )

	if (cvars.Number("mw_admin_spawn_time") == 1 and ent.mw_spawntime ~= nil) then
		timer.Simple( ent.mw_spawntime-CurTime(), function()
			if (IsValid(ent)) then	
				MW_Spawn(ent)
			end
		end)
	else
		MW_Spawn(ent)
	end
end

function MW_Spawn(ent)
	if (SERVER) then
		
		ent:SetMoveType( ent.moveType )   -- after all, gmod is a physics
		
		ent:SetMaterial(ent.materialString)
		--print("Angles: "..tostring(ent.Angles))
		ent.spawned = true

		ent.HP = ent.maxHP
		--print("modelString: "..ent.modelString)
		ent:SetNWFloat( "maxhealth", ent.maxHP )
		ent:SetNWFloat( "health", ent.HP )

		local baseSize
		if (ent.sphereRadius != 0) then
			baseSize = ent.sphereRadius
		else
			local mins = ent.phys:GetAABB()
			baseSize = (-mins.x-mins.y)/2
		end
		ent:SetNWFloat( "baseSize", baseSize+5 )

		hook.Run("MelonWarsEntitySpawned", ent)
	end
end

function ENT:Welded( ent, parent )
	--script a ejecutar si se spawnea weldeada
	local weld = constraint.Weld( ent, parent, 0, 0, 0, true , false )
	ent.canMove = false
	ent.materialString = "models/shiny"

	ent.parent = parent

	ent.phys:SetDamping(0,0)

	--Resta su poblacion para luego sumar la nueva
	MW_UpdatePopulation(-ent.population, mw_melonTeam)
	ent.population = math.ceil(ent.population/2)
	MW_UpdatePopulation(ent.population, mw_melonTeam)
end

function ENT:Think()
	if (!self.phys:IsAsleep()) then
		if (self.moving == false and self.canMove) then
			local tr = util.QuickTrace( self:GetPos(), self:GetPos()+Vector(0,0,-self.sphereRadius+15), self )
			if (tr.Entity ~= nil) then
				//self.phys:SetDamping(self.damping*5,self.damping*5)
				local stoppingForce = self.phys:GetMass()*-self:GetVelocity()*0.5
				stoppingForce.z = 0
				self.phys:ApplyForceCenter(stoppingForce)
				if (self:GetVelocity():LengthSqr() < 800) then
					self.phys:Sleep()
				end
			end
		else
			self.phys:SetDamping(self.damping,self.damping)
		end
	end
	if (self.spawned) then
		self:Update(self)
	end
	if (!self.canMove and self:GetClass() != "ent_melon_unit_transport") then
		if (self:GetMoveType() != MOVETYPE_NONE ) then
			local const = constraint.FindConstraints( self, "Weld" )
			table.Add(const, constraint.FindConstraints( self, "Axis" ))
			if (table.Count(const) == 0) then
				self.damage = 5
			end
		end
	end
end

function ENT:Update( ent )
	----[[
	if (cvars.Bool("mw_admin_playing") ) then
		if (CurTime() > ent.nextSlowThink) then
			ent.nextSlowThink = CurTime()+ent.slowThinkTimer
			ent:SlowThink( ent )
		end

		--Aplicar daño
		if (ent.damage > 0) then
			ent.gotHit = true
			ent.HP = ent.HP-ent.damage
			ent:SetNWFloat( "health", ent.HP )
			ent.damage = 0
			if (ent.HP <= 0) then
				MW_Die( ent )
			end
		end

		ent:SetNWEntity( "targetEntity", ent.targetEntity )
		ent:SetNWEntity( "followEntity", ent.followEntity )
		
		local entPos = ent:GetPos()
		local followEntityPos = Vector(0,0,0)
		if (IsValid(ent.followEntity)) then
			followEntityPos = ent.followEntity:GetPos()
		end
		local targetEntityPos = Vector(0,0,0)
		if (IsValid(ent.targetEntity)) then
			targetEntityPos = ent.targetEntity:GetPos()
		end

		if (ent.canMove) then
			if (ent.followEntity ~= ent) then
				if (IsValid(ent.followEntity)) then
					if ((followEntityPos-entPos):LengthSqr() > ent.range*ent.range) then
						ent.targetPos = followEntityPos+(entPos-followEntityPos):GetNormalized()*ent.range*0.5
						ent.moving = true
					end
				end
			else
				if (ent.chasing) then
					if (IsValid(ent.targetEntity)) then
						if ((targetEntityPos-entPos):LengthSqr() > ent.range*ent.range) then
							ent.targetPos = targetEntityPos+(entPos-targetEntityPos):GetNormalized()*ent.range*0.9
							ent.moving = true
						end
					end
				end
			end
			
			local phys = ent.phys
			
			if (IsValid(phys)) then
				---------------------------------------------------------------------------Movimiento
				if (ent.moving) then
					--if (ent.chaseStance == false or ent.targetEntity == nil) then
					local moveVector = (ent.targetPos-entPos):GetNormalized()*ent.speed-ent:GetVelocity()*0.5
					force = Vector(moveVector.x, moveVector.y, 0)
					// OLD MOVEMENT, MOVE IN THINK. NEW MOVEMENT IN PHYSICS UPDATE
					//phys:ApplyForceCenter (force*phys:GetMass())
					// new:
					ent.phys:Wake()
					ent.moveForce = force*0.5
					--end
				end

				if (ent.moving) then
					local distanceToLastPosition = (ent.lastPosition-entPos):LengthSqr()

					if (ent.lastPosition != Vector(0,0,0) and distanceToLastPosition > 500000) then --Stop moving if distance from lastposition is ridiculous (teleported)
						ent:FinishMovement()
						ent.lastPosition = Vector(0,0,0)
					elseif (distanceToLastPosition < (ent.speed/2)*(ent.speed/2))then
						ent.stuck = ent.stuck+1
					else
						ent.lastPosition = entPos
						ent.stuck = 0
					end

					if (ent.stuck%8 == 7) then
						if (ent.stuck > 40) then
							if (!ent.chaseStance) then
								ent.targetEntity = nil
								ent:FinishMovement()
								ent.stuck = 0
							end
						else
							if (!ent.chaseStance || (ent.chaseStance && !IsValid(ent.targetEntity))) then
								ent:Unstuck()
							end
						end
					end
				end
			end

			local flattenedTargetPos = Vector(ent.targetPos.x, ent.targetPos.y, entPos.z)
			if ((flattenedTargetPos-entPos):LengthSqr() < 50*50) then
				ent:FinishMovement()
			end

			ent:SetNWBool("moving", ent.moving)
			ent:NextThink(CurTime() + 0.1)
			return true
		end
	end
	--]]--
end

function ENT:Unstuck()
	local phys = self.phys
	phys:ApplyForceCenter (Vector(0,0,self.speed*2.5)*phys:GetMass())
end

function ENT:OnFinishMovement()

end

function ENT:FinishMovement ()
	if (self.rallyPoints[1] == Vector(0,0,0)) then
		self.moving = false
		self.stuck = 0
	else
		self.targetPos = self.rallyPoints[1]
		self:SetNWVector("targetPos", self.rallyPoints[1])
		self.moving = true
		for i=1, 30 do
			self.rallyPoints[i] = self.rallyPoints[i+1]
		end
		self.rallyPoints[30] = Vector(0,0,0)
	end
	self:OnFinishMovement()
end

function ENT:RemoveRallyPoints ()
	for i=1, 30 do
		self.rallyPoints[i] = Vector(0,0,0)
	end
end

function ENT:SameTeam(ent)
	local myTeam = self:GetNWInt("mw_melonTeam", 0)
	local otherTeam = ent:GetNWInt("mw_melonTeam", 0)
	if (myTeam == otherTeam) then
		return true
	end
	if (myTeam == 0 or otherTeam == 0) then
		return false
	end
	return teamgrid[myTeam][otherTeam];
end

function ENT:Align( reference, target, multiplier )

	local cross = reference:Cross(target)
	local torque = cross*multiplier

	self:ApplyTorque(torque)

	return cross:LengthSqr()
end

function ENT:StopAngularVelocity( percent )
	self.phys:AddAngleVelocity( -self.phys:GetAngleVelocity()*percent )
end

function ENT:ApplyTorque( torque )

	local forceOffset = torque:Angle():Right()
	local forceDirection = torque:Cross(forceOffset)

	self.phys:ApplyForceOffset( forceDirection, self:GetPos()+forceOffset )
	self.phys:ApplyForceOffset( -forceDirection, self:GetPos()-forceOffset )
end

function MW_UnitDefaultThink( ent )
	if (!util.IsInWorld( ent:GetPos() )) then ent:Remove() end
	if (ent.canShoot) then
		local pos = ent:GetPos()
		if (ent.targetEntity == nil or ent.targetEntity.Base == "ent_melon_prop_base" or ent.targetEntity:GetNWInt("propHP",-1) ~= -1) then
			----------------------------------------------------------------------Buscar target
			local foundEnts = ents.FindInSphere(pos, ent.range )
			for k, v in RandomPairs( foundEnts ) do
				if (v.Base == "ent_melon_base") then --si es una sandía
					if (v:GetNWInt("mw_melonTeam", 0) ~= ent:GetNWInt("mw_melonTeam", 0)) then -- si tienen distinto equipo
						if (v.targetable) then -- si es targeteable
							if (!ent:SameTeam(v)) then -- si no es un aliado
								local tr = util.TraceLine( {
								start = pos,
								endpos = v:GetPos()+v:GetVar("shotOffset",Vector(0,0,0)),
								filter = function( foundEnt )
									if ( foundEnt:GetClass() == "prop_physics") then--si hay un prop en el medio
										return true
									end
									if (ent.careForFriendlyFire) then --No dispara si hay un compañero en el camino
										if ( foundEnt.Base == "ent_melon_base" ) then
											if (foundEnt:GetNWInt("mw_melonTeam", -1) == ent:GetNWInt("mw_melonTeam", 0) and foundEnt ~= ent) then
												return true
											end
										end
									end
								end
								})
								if (tostring(tr.Entity) == '[NULL Entity]') then
								----------------------------------------------------------Encontró target
									ent.targetEntity = v
								end
							end
						end
					end
				end
			end
			-------------------------------------------------Si aun asi no encontró target
			if (ent.targetEntity == nil) then
				for k, v in RandomPairs( foundEnts ) do
					if (v:GetNWInt("mw_melonTeam", ent:GetNWInt("mw_melonTeam", 0)) ~= ent:GetNWInt("mw_melonTeam", 0) and !string.StartWith( v:GetClass(), "ent_melonbullet_" ) and !ent:SameTeam(v)) then --si es de otro equipo
						if (ent.chaseStance) then
							if (v:GetClass() == "ent_melon_wall") then
								if (ent.stuck > 15) then
									if (IsValid(ent.barrier)) then
										ent.targetEntity = ent.barrier
									else
										ent.targetEntity = v
									end
								end
							else
								ent.targetEntity = v
							end
						else
							ent.targetEntity = v
						end
					end
				end
			end
		end 

		if (ent.targetEntity ~= nil) then
			----------------------------------------------------------------------Perder target
			----------------------------------------porque no existe
			if (!IsValid(ent.targetEntity)) then
				ent.stuck = 0
				return ent:LoseTarget()
			----------------------------------------por que esta en el 0,0,0
			elseif (ent.targetEntity:GetPos() == Vector(0,0,0)) then
				return ent:LoseTarget()
			end
			----------------------------------------porque es intargeteable
			if (not ent.targetable) then
				return ent:LoseTarget()
			end
			----------------------------------------porque es el mismo
			if (ent.targetEntity == ent or ent.forcedTargetEntity == ent) then
				return ent:LoseTarget()
			end
			----------------------------------------porque es un aliado
			if (ent:SameTeam(ent.targetEntity) or ent:SameTeam(ent.targetEntity)) then
				return ent:LoseTarget()
			end
			----------------------------------------porque está lejos (o muy cerca)
			local targetDist = ent.targetEntity:GetPos():Distance(pos)
			if (IsValid(ent.targetEntity) and (targetDist > ent.range or targetDist < ent.minRange)) then
				if (ent.chaseStance) then
					if (not ent.chasing) then
						ent.holdGroundPosition = ent:GetPos()
						ent.chasing = true
					end
					local tepos = ent.targetEntity:GetPos()
					ent:SetVar("targetPos", tepos)
					ent:SetNWVector("targetPos", tepos)
					ent:SetVar("moving", true)
					ent:SetVar("followEntity", ent)
					ent:SetNWEntity("followEntity", ent)
					if ((tepos-ent.holdGroundPosition):LengthSqr() > ent.maxChaseDistance*ent.maxChaseDistance) then
						ent:LoseTarget()
					end
				else
					ent:LoseTarget()
				end
				return false
			end
			
			----------------------------------------------objetivo forzado
			if (IsValid(ent.forcedTargetEntity)) then
				ent.targetEntity = ent.forcedTargetEntity
			else
				ent.forcedTargetEntity = nil
			end
			
			local tr = util.TraceLine( {
				start = pos,
				endpos = ent.targetEntity:GetPos()+ent.targetEntity:GetVar("shotOffset", Vector(0,0,0)),
				--filter = function( foundEntity ) if (( (foundEntity:GetClass() == "ent_melon_wall" and foundEntity:GetNWInt("mw_melonTeam", 0) == ent:GetNWInt("mw_melonTeam", 1)) or (foundEntity:GetClass() == "prop_physics" and foundEntity:GetNWInt("mw_melonTeam", 0) == ent:GetNWInt("mw_melonTeam", 1)) ) and foundEntity ~= ent.targetEntity ) then return true end end
				filter = function( foundEntity ) if (foundEntity.Base ~= "ent_melon_base" and foundEntity:GetNWInt("mw_melonTeam", 0) == ent:GetNWInt("mw_melonTeam", 1) or foundEntity:GetClass() == "prop_physics" and foundEntity ~= ent.targetEntity) then return true end end
				})
			----------------------------------------por que hay algo en el medio

			if (ent.careForWalls) then
				--print(ent)
				if (tostring(tr.Entity) ~= '[NULL Entity]') then
					return ent:LoseTarget()
				end
			end
			
			if (tostring(tr.Entity) == "Entity [0][worldspawn]") then
				return ent:LoseTarget()
			end
		end
		
		if (ent.targetEntity ~= nil) then
			local distance = ent.targetEntity:GetPos():Distance(ent:GetPos())
			if (distance < ent.range and distance > ent.minRange) then
				if (ent.targetEntity:GetNWInt("mw_melonTeam", 0) ~= ent:GetNWInt("mw_melonTeam", 0)) then
					ent:Shoot( ent )
				end
			end
		end
	end
end

function ENT:LoseTarget()
	self.targetEntity = nil
	self:SetNWEntity("targetEntity", nil)
	self.forcedTargetEntity = nil
	self.nextSlowThink = CurTime()+0.5
	if (self.chaseStance) then
		self:SetVar("targetPos", self.holdGroundPosition)
		self:SetNWVector("targetPos", self.holdGroundPosition)
		self:SetVar("moving", true)
		self:SetVar("chasing", false)
		self:SetVar("followEntity", self)
		self:SetNWEntity("followEntity", self)
	end

	return false
end

function ENT:PhysicsCollide( colData, physObject )
	if (IsValid(colData.HitEntity)) then
		local other = colData.HitEntity
		local otherTargetPos = other:GetVar('targetPos')
		if ((otherTargetPos == self.targetPos and other:GetVar('moving', false) == false) or self.rallyPoints[1] == otherTargetPos) then
			self:FinishMovement()
		end
		if (other:GetClass() == "ent_melon_wall") then
			self.barrier = other
		end
	end
end

function MW_DefaultShoot( ent )
	local pos = ent:GetPos()+ent.shotOffset
	--------------------------------------------------------Disparar
	if (IsValid(ent.targetEntity)) then
		local targetPos = ent.targetEntity:GetPos()+ent.targetEntity:OBBCenter()
		if (ent.targetEntity:GetVar("shotOffset") ~= nil) then
			if (ent.targetEntity:GetVar("shotOffset") ~= Vector(0,0,0)) then
				targetPos = ent.targetEntity:GetPos()+ent.targetEntity:GetVar("shotOffset")
			end
		end
		local bullet = {}
		bullet.Num=1
		bullet.Src=pos
		bullet.Dir=targetPos-pos
		bullet.Spread=Vector(ent.spread,ent.spread,0)
		bullet.Tracer=1	
		bullet.TracerName=ent.tracer
		bullet.Force=2
		---------------------------------------------------------------------Esto va hacer que se aplique el daño le pegue o no
		if (ent.targetEntity.Base == "ent_melon_prop_base") then
			ent.targetEntity:SetNWFloat( "health", ent.targetEntity:GetNWFloat( "health", 1)-ent.damageDeal)
			if (ent.targetEntity:GetNWFloat( "health", 1) <= 0) then
				ent.targetEntity:MW_PropDefaultDeathEffect( ent.targetEntity )
			end
			bullet.Damage=0
		else			
			bullet.Damage=ent.damageDeal
		end
		
		bullet.Distance=ent.range*1.1
		ent.fired = true
		ent:FireBullets(bullet)
		local effectdata = EffectData()
		effectdata:SetScale(1)
		effectdata:SetAngles( (targetPos-pos):Angle()) 
		effectdata:SetOrigin( pos + (targetPos-pos):GetNormalized()*10 )
		util.Effect( "MuzzleEffect", effectdata )
		sound.Play( ent.shotSound, pos )
	end
end

function MW_DefaultDeathEffect( ent )
	local effectdata = EffectData()
	effectdata:SetOrigin( ent:GetPos() )
	util.Effect( ent.deathEffect, effectdata )
	sound.Play( ent.deathSound, ent:GetPos() )
	ent:Remove()
end

function MW_Die( ent )
	if (IsValid(ent)) then
		ent:DeathEffect ( ent )
	end
end

function ENT:MW_PropDefaultDeathEffect( ent )
	local effectdata = EffectData()
	effectdata:SetOrigin( ent:GetPos() )
	util.Effect( ent.deathEffect, effectdata )
	sound.Play( ent.deathSound, ent:GetPos() )
	ent:Remove()
end

function ENT:PhysicsUpdate()
	self:DefaultPhysicsUpdate ()
end

function ENT:DefaultPhysicsUpdate ()
	if (self.moving) then
		if (self:GetVelocity():LengthSqr() < self.speed*self.speed) then
			self.phys:ApplyForceCenter (self.moveForce*self.phys:GetMass())
		else
			local horizontalVelocity = Vector(self:GetVelocity().x, self:GetVelocity().y, 0)
			self.phys:ApplyForceCenter (-horizontalVelocity*0.02*self.phys:GetMass())
		end
	else
		self.moveForce = Vector(0,0,0)
	end
end

function ENT:OnTakeDamage( damage )
	
	if ((damage:GetAttacker():GetNWInt("mw_melonTeam", 0) ~= self:GetNWInt("mw_melonTeam", 0) or not damage:GetAttacker():GetVar('careForFriendlyFire')) and not damage:GetAttacker():IsPlayer()) then 
		local damageDone = 0
		
		if (self.canMove == true) then
			damageDone = damage:GetDamage()
		else
			local mul = damage:GetAttacker().buildingDamageMultiplier
			if (mul == nil) then
				mul = 1
			end
			damageDone = damage:GetDamage()*mul
		end
		
		if (damage:GetAttacker():GetNWInt("mw_melonTeam", 0) == self:GetNWInt("mw_melonTeam", 0)) then
			damageDone = damageDone/2
		end
		self.HP = self.HP - damageDone
		if (damageDone > 0) then
			self.gotHit = true
		end
		self:SetNWFloat( "health", self.HP )
		if (self.HP <= 0) then
			MW_Die (self)
		end
		self:_OnTakeDamage( damage )
	end
end

function ENT:_OnTakeDamage( damage )

end

function ENT:OnRemove()
	self:DefaultOnRemove()
end

function ENT:DefaultOnRemove()
	if (SERVER) then
		if (IsValid(self)) then
			MW_UpdatePopulation(-self.population, self:GetNWInt("mw_melonTeam", 0))
			if (!self.gotHit and CurTime()-self:GetCreationTime() < 30 and !self.fired) then
				if (mw_teamCredits[self:GetNWInt("mw_melonTeam", 0)] != nil) then
					mw_teamCredits[self:GetNWInt("mw_melonTeam", 0)] = mw_teamCredits[self:GetNWInt("mw_melonTeam", 0)]+self.value
				end
				for k, v in pairs( player.GetAll() ) do
					if (v:GetInfo("mw_team") == tostring(self:GetNWInt("mw_melonTeam", 0))) then
						if (self:GetNWInt("mw_melonTeam", 0) != 0) then
							net.Start("MW_TeamCredits")
								net.WriteInt(mw_teamCredits[self:GetNWInt("mw_melonTeam", 0)] ,16)
							net.Send(v)
							v:PrintMessage( HUD_PRINTTALK, "///// "..self.value.." Water Refunded" )
						end
					end
				end
			end
		end
	end
end

function MW_UpdatePopulation (ammount, teamID)
	--if (SERVER) then
	if (ammount != 0 && teamID != 0 && teamID != nil) then
		mw_teamUnits[teamID] = mw_teamUnits[teamID]+ammount
		local ownerPlayers = {}
		ownerPlayers = player.GetAll()
		local i = 0	--Parche horrible: cada vez que elimina a alguien de la lista, al remover a alguien mas busca un lugar antes, ya que la lista se acomodó para rellenar el espacio vacio
		for k, v in pairs( player.GetAll() ) do
			if (v:GetInfoNum("mw_team", 0) ~= teamID) then
				table.remove(ownerPlayers, k-i)
				i = i+1
			end
		end
		net.Start("mw_teamUnits")
			net.WriteInt(mw_teamUnits[teamID] ,16)
		net.Send(ownerPlayers)
	end
	--end
end

function ENT:BarrackInitialize ()
	self.moveType = MOVETYPE_NONE
	
	self.canMove = false
	self.canShoot = false
	
	self:SetNWBool("active", true)
	self.unitspawned = true
	self:SetNWInt("count", 0)

	self:SetNWFloat("overdrive", 0)
	
	self:SetNWBool("spawned", self.unitspawned)
	self.slowThinkTimer = 3

	self:SetVar('targetPos', self:GetPos()+Vector(150,0,0))
	self:SetNWVector('targetPos', self:GetPos()+Vector(150,0,0))
	
	self.deathSound = "ambient/explosions/explode_9.wav"
	self.deathEffect = "Explosion"

	self.melons = {}

	self.population = 5

	if (self.unit != nil) then
		self.slowThinkTimer = mw_units[self.unit].spawn_time*3
		self.unit_class = mw_units[self.unit].class
		self.unit_cost = mw_units[self.unit].cost
	end	

	self:SetNWFloat("slowThinkTimer", self.slowThinkTimer)
	self:SetNWFloat("nextSlowThink", CurTime())
end

local function EnoughPower(_team)
	local res = false
	if (_team > 0) then
		res = mw_teamUnits[_team] < cvars.Number("mw_admin_max_units")
	else
		res = true
	end
	return res
end

function ENT:BarrackSlowThink()
	local ent = self

	if (self.spawned) then
		if (!self.unitspawned) then
			if (self:GetNWFloat("nextSlowThink") < CurTime()+self:GetNWFloat("overdrive", 0)) then
				if (EnoughPower(ent:GetNWInt("mw_melonTeam", 0))) then
					self:SetNWFloat("overdrive", 0)
					local newMarine = ents.Create( self.unit_class )
					if ( !IsValid( newMarine ) ) then return end -- Check whether we successfully made an entity, if not - bail
					newMarine:SetPos( ent:GetPos() + Vector(0,0,20) + ent.shotOffset)
					
					sound.Play( "ambient/misc/hammer1.wav", ent:GetPos(), 75, 100, 1 )
					
					mw_melonTeam = ent:GetNWInt("mw_melonTeam", 0)
					
					newMarine:Spawn()
					newMarine:SetNWInt("mw_melonTeam", ent:GetNWInt("mw_melonTeam", 0))
					newMarine:Ini(ent:GetNWInt("mw_melonTeam", 0))

					for i=1, 30 do
						newMarine.rallyPoints[i] = self.rallyPoints[i]
					end

					if (cvars.Bool("mw_admin_credit_cost")) then
						newMarine.value = self.unit_cost
					else
						newMarine.value = 0
					end

					if (ent.targetPos == ent:GetPos()) then
						newMarine:SetVar('targetPos', ent:GetPos()+Vector(100,0,0))
						newMarine:SetNWVector('targetPos', ent:GetPos()+Vector(100,0,0))
					else
						newMarine:SetVar('targetPos', ent.targetPos+Vector(0,0,1))
						newMarine:SetNWVector('targetPos', ent.targetPos+Vector(0,0,1))
					end
					newMarine:SetVar('moving', true)
				
					table.insert(ent.melons, newMarine)
					undo.Create("Melon Marine")
					 undo.AddEntity( newMarine )
					 undo.SetPlayer( ent:GetOwner())
					undo.Finish()

					if (self:GetNWBool("active", false)) then
						self.nextSlowThink = CurTime()+self.slowThinkTimer
						self:SetNWFloat("nextSlowThink", self.nextSlowThink)
					end
					self.unitspawned = true
					self:SetNWBool("spawned", self.unitspawned)
				end
			end
		end

		self:SetNWInt("count", 0)
		for k, v in pairs( ent.melons ) do
			if (IsValid(v)) then
				self:SetNWInt("count", self:GetNWInt("count", 0)+1)
			else
				table.remove(ent.melons, k)
			end
		end

		if (self:GetNWBool("active", false)) then
			if (self.unitspawned) then
				if (self:GetNWInt("count", 0) < self:GetNWInt("maxunits", 0) and EnoughPower(ent:GetNWInt("mw_melonTeam", 0))) then
					if (mw_teamCredits[ent:GetNWInt("mw_melonTeam", 0)] >= self.unit_cost or not cvars.Bool("mw_admin_credit_cost")) then
						-- Start Production
						--self:SetNWBool("spawned", false)
						------

						if (cvars.Bool("mw_admin_credit_cost")) then
							mw_teamCredits[self:GetNWInt("mw_melonTeam", 0)] = mw_teamCredits[self:GetNWInt("mw_melonTeam", 0)]-self.unit_cost
							for k, v in pairs( player.GetAll() ) do
								if (v:GetInfo("mw_team") == tostring(self:GetNWInt("mw_melonTeam", 0))) then
									net.Start("MW_TeamCredits")
										net.WriteInt(mw_teamCredits[self:GetNWInt("mw_melonTeam", 0)] ,16)
									net.Send(v)
								end
							end
						end

						self.nextSlowThink = CurTime()+self.slowThinkTimer
						self:SetNWFloat("nextSlowThink", self.nextSlowThink)
						self.unitspawned = false
						self:SetNWBool("spawned", self.unitspawned)
					end
				else
					self.unitspawned = true
					self:SetNWBool("spawned", self.unitspawned)
				end
			end
		--else
		--	self.nextSlowThink = CurTime()+1
		--	self:SetNWFloat("nextSlowThink", self.nextSlowThink)
		--	self.unitspawned = false
		--	self:SetNWBool("spawned", self.unitspawned)
		end
	end
end

function ENT:PlayHudSound(sndFile, volume, pitch, _team)
	local toAll = false
	if (_team == nil) then
		toAll = true
	end
	for k, v in pairs( player.GetAll() ) do
		if (toAll or v:GetInfoNum("mw_team", 0) == _team) then
			local snd = CreateSound( v, sndFile )
			snd:PlayEx( volume, pitch )
		end
	end
end