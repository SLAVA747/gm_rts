AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

function ENT:Initialize()
	self:PhysicsInitSphere( 5, "default" )
	self.rotation = AngleRand():Forward()
	self:GetPhysicsObject():SetDamping(0,0)
	local time = 5
	self:Ignite( time, 0.1 )
end

function ENT:PhysicsUpdate()
	self:GetPhysicsObject():ApplyTorqueCenter( self.rotation*50 )
end

function ENT:PhysicsCollide( colData, collider )
	local vel = self:GetVelocity():Length()

	util.BlastDamage( self, self, self:GetPos(), 30, vel/30 )
	if (vel > 100) then
		local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
		util.Effect( "cball_explode", effectdata )
	end
	if ( vel > 200) then
		local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
		util.Effect( "HelicopterMegaBomb", effectdata )
		local other = colData.HitEntity
		local otherhealth = other:GetNWFloat("health", 0)
		if (otherhealth != 0) then
			local newHealth = otherhealth-vel/20
			other:SetNWFloat("health", newHealth)
			if (other:GetNWFloat("health", 1) <= 0) then
				MW_Die(other)
			else
				if (other:GetClass() == "ent_melon_wall") then
					if (newHealth < 100) then
						constraint.RemoveConstraints( other, "Weld" )
					end
				end
			end
		end
	end
	timer.Simple( 1, function()
		if (self:IsValid()) then
			util.BlastDamage( self, self, self:GetPos(), 70, 30 )
			local effectdata = EffectData()
			effectdata:SetOrigin( self:GetPos() )
			util.Effect( "Explosion", effectdata )
			self:Remove()
		end
	end	)
end