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
	
	self.damageDeal = 10

	self.sphereRadius = 7
	
	self.population = 2
	
	self.shotSound = "items/medshot4.wav"
	
	--print("Finished changing stats")
	
	MW_Setup ( self )
end

function ENT:ModifyColor()
	self:SetColor(Color(self:GetColor().r+120, self:GetColor().g+120, self:GetColor().b+120, 255))
end

function ENT:SlowThink ( ent )
	if (ent.HP < ent.maxHP) then
		ent.HP = ent.HP+1
		if (ent.HP > ent.maxHP) then
			ent.HP = ent.maxHP
		end
		ent:SetNWFloat( "health", ent.HP )
	end
	if (ent.canShoot) then
		local pos = ent:GetPos()
		if (ent.targetEntity == nil) then
			----------------------------------------------------------------------Buscar target
			local foundEnts = ents.FindInSphere(pos, ent.range )
			for k, v in RandomPairs( foundEnts ) do
				if (v.Base == "ent_melon_base") then
					if (v:GetNWInt("mw_melonTeam", 0) == ent:GetNWInt("mw_melonTeam", 0) or ent:SameTeam(v)) then
						if(v ~= ent) then
							if (v.spawned) then
								local tr = util.TraceLine( {
								start = pos,
								endpos = v:GetPos(),
								filter = function( foundEnt )
									if ( foundEnt:GetClass() == "prop_physics" ) then
										return true
									end
								end
								})
								if (tostring(tr.Entity) == '[NULL Entity]') then
								----------------------------------------------------------Encontró target
									if (v:GetVar("HP") < v:GetVar("maxHP")) then
										ent.targetEntity = v
									end
								end
							end
						end
					end
				end
			end
		end
		
		--if (IsValid(ent.forcedTargetEntity)) then
		--	ent.targetEntity = ent.forcedTargetEntity
		--else
		--	ent.forcedTargetEntity = nil
		--end
		
		if (ent.targetEntity ~= nil) then
			----------------------------------------------------------------------Perder target
			----------------------------------------por que no existe
			if (!IsValid(ent.targetEntity)) then
				ent.targetEntity = nil
				ent.nextSlowThink = CurTime()+0.1
				return false
			end
			----------------------------------------por que está lejos
			if (IsValid(ent.targetEntity) and ent.targetEntity:GetPos():Distance(pos) > ent.range) then
				ent.targetEntity = nil
				ent.nextSlowThink = CurTime()+0.1
				return false
			end
			----------------------------------------por que hay algo en el medio
			local tr = util.TraceLine( {
			start = pos,
			endpos = ent.targetEntity:GetPos(),
			filter = function( foundEntity ) if ( foundEntity:GetClass() == "prop_physics" and foundEntity ~= ent.targetEntity  and !string.StartWith( ent.targetEntity:GetClass(), "ent_melonbullet_" )) then return true end end
			})
			if (tostring(tr.Entity) ~= '[NULL Entity]') then
				ent.targetEntity = nil
				ent.nextSlowThink = CurTime()+0.1
				return false
			end
			ent:Shoot( ent )
		end
	end
end

function ENT:Shoot ( ent )
	--------------------------------------------------------Disparar
	if (ent.targetEntity == ent) then ent.targetEntity = nil end
	if (IsValid(ent.targetEntity)) then
		--print(self:SameTeam(ent))
		if (ent.targetEntity:GetNWInt("mw_melonTeam", 0) == ent:GetNWInt("mw_melonTeam", 0) or ent:SameTeam(ent.targetEntity)) then
			local pos = ent:GetPos()+ent.shotOffset
			local targetPos = ent.targetEntity:GetPos()
			if (ent.targetEntity:GetVar("shotOffset") ~= nil) then
				targetPos = targetPos+ent.targetEntity:GetVar("shotOffset")
			end
			//ent:FireBullets(bullet)
			local effectdata = EffectData()
			effectdata:SetOrigin( targetPos + Vector(0,0,10) )
			util.Effect( "inflator_magic", effectdata )
			util.Effect( "inflator_magic", effectdata )
			util.Effect( "inflator_magic", effectdata )
			util.Effect( "inflator_magic", effectdata )
			util.Effect( "inflator_magic", effectdata )
			effectdata:SetOrigin( pos + Vector(0,0,10) )
			util.Effect( "inflator_magic", effectdata )
			sound.Play( ent.shotSound, pos )
			local heal = ent.targetEntity:GetVar("HP")+math.min(ent.damageDeal, ent.targetEntity:GetVar("maxHP")-ent.targetEntity:GetVar("HP"))
			ent.targetEntity:SetVar("HP", heal)
			ent.targetEntity:SetNWFloat("health", heal)
			ent.fired = true
			if (ent.targetEntity:GetVar("HP") == ent.targetEntity:GetVar("maxHP")) then
				ent.targetEntity = nil
			end
		else
			ent.targetentity = nil
		end
	end
end

function ENT:DeathEffect ( ent )
	MW_DefaultDeathEffect ( ent )
end