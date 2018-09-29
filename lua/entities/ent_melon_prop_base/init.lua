AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

function PropDefaults( ent )
	
	ent.maxHP = 20

	ent.shotOffset = Vector(0,0,0)
	ent.modelString = "models/props_junk/watermelon01.mdl"
	ent.materialString = "models/debug/debugwhite"

	ent.onFire = false
	
	ent.deathEffect = "cball_explode"
	
	ent.damage = 0
	
	ent.Angles = Angle(0,0,0)
		--print("Finished MW_Defaults")
end

function PropSetup( ent )
	
	if (SERVER) then
		ent:SetNWEntity( "targetEntity", ent.targetEntity )
		
		--print("modelString: "..ent.modelString)
		ent.HP = ent.maxHP
		ent:SetNWFloat( "maxhealth", ent.maxHP )
		ent:SetNWFloat( "health", ent.HP )

		--ent:SetModel( ent.modelString )
		
		ent:SetSolid( SOLID_VPHYSICS )         -- Toolbox
		
		ent:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
		
		if (ent.moveType == 0) then
			local weld = constraint.Weld( ent, game.GetWorld(), 0, 0, 0, true , false )
			canMove = false
		end
		
		ent.phys = ent:GetPhysicsObject()
		if (IsValid(ent.phys)) then
			ent.phys:Wake()
		end
		
		ent:SetMoveType( ent.moveType )   -- after all, gmod is a physics
		
		ent:SetMaterial(ent.materialString)
		--print("Angles: "..tostring(ent.Angles))
		if (ent.changeAngles) then
			ent:SetAngles( ent.Angles )
		end
	end
	
	local mw_melonTeam = ent:GetNWInt("mw_melonTeam", 0)
	print(mw_melonTeam)
	local newColor = Color(255,255,255,255)
	if (mw_melonTeam == 1) then
		newColor = Color(255,50,50,255)
	end
	if (mw_melonTeam == 2) then
		newColor = Color(50,50,255,255)
	end
	if (mw_melonTeam == 3) then
		newColor = Color(255,200,50,255)
	end
	if (mw_melonTeam == 4) then
		newColor = Color(30,200,30,255)
	end
	if (mw_melonTeam == 5) then
		newColor = Color(255,50,255,255)
	end
	if (mw_melonTeam == 6) then
		newColor = Color(0,230,230,255)
	end
	if (mw_melonTeam == 7) then
		newColor = Color(255,120,0,255)
	end
	if (mw_melonTeam == 8) then
		newColor = Color(10,30,70,255)
	end
		
	ent:SetColor(newColor)
end

function ENT:MW_PropDefaultDeathEffect( ent )
	local effectdata = EffectData()
	effectdata:SetOrigin( ent:GetPos() )
	util.Effect( ent.deathEffect, effectdata )
	sound.Play( ent.deathSound, ent:GetPos() )
	ent:Remove()
end

function PropDie( ent )
	ent:MW_PropDefaultDeathEffect ( ent )
end
--[[
function ENT:OnTakeDamage( damage )
	if (damage:GetDamage() > 0) then
		if ((damage:GetAttacker():GetNWInt("mw_melonTeam", 0) ~= self:GetNWInt("mw_melonTeam", 0) or not damage:GetAttacker():GetVar('careForFriendlyFire')) and not damage:GetAttacker():IsPlayer()) then 
			local HP = self:GetNWFloat("health", 1) - damage:GetDamage()
			self:SetNWFloat( "health", HP )
			if (HP <= 0) then
				PropDie (self)
			end
		end
	end
end]]

function ENT:OnRemove()
	if (SERVER) then
		if (self:GetNWFloat("health", 1) == self:GetNWFloat("maxhealth", 1) and CurTime()-self:GetCreationTime() < 30) then
			if (mw_teamCredits[self:GetNWInt("mw_melonTeam", 0)] != nil) then
				mw_teamCredits[self:GetNWInt("mw_melonTeam", 0)] = mw_teamCredits[self:GetNWInt("mw_melonTeam", 0)]+self.value
			end
			for k, v in pairs( player.GetAll() ) do
				if (self:GetNWInt("mw_melonTeam", 0) != 0) then
					if (v:GetInfo("mw_team") == tostring(self:GetNWInt("mw_melonTeam", 0))) then
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