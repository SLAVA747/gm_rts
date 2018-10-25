AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.

include('shared.lua')

mw_team_colors  = {Color(255,50,50,255),Color(50,50,255,255),Color(255,200,50,255),Color(30,200,30,255),Color(255,50,255,255),Color(100,255,255,255),Color(255,120,0,255),Color(10,30,70,255)}

function ENT:Initialize()
		
	self:SetUseType( SIMPLE_USE )

	self.slowThinkTimer = 2

	self.mw_melonTeam = 0
	
	self.nextSlowThink = 0
	self:SetModel( "models/props_junk/PopCan01a.mdl" )

	self:PhysicsInit( SOLID_VPHYSICS ) 
	self:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	--self:SetMoveType( MOVETYPE_NONE )

	self:SetAngles(Angle(0,0,0))
	self.groundPosition = self:GetPos()
	self:SetNWBool("visible", true)
	
	self:SetMaterial("models/shiny")
	self:SetColor(Color(50,50,50,255))

	--self:FindNext()

	self.pos = self:GetPos()
	self.time = 0

	self.waypoint = 1
	self:SetNWInt("waypoint", 1)
	self.path = 1
	self:SetNWInt("path", 1)
end

function ENT:FindNext()

	local nodes = ents.FindByClass( "ent_melon_singleplayer_waypoint" )

	local found = false

	for k, v in pairs( nodes ) do
		if (!found) then
			if (v.path == self.path) then
				if (v.waypoint == self.waypoint+1) then
					self:SetNWEntity("nearestPoint", v)
					found = true
				end
			end
		end
	end

	if (!found) then
		local nearest = nil
		local nodes = ents.FindByClass( "ent_melon_main_building" )
		for k, v in pairs( nodes ) do
			if (v ~= self) then
				if (nearest == nil) then
					nearest = v
					self:SetNWEntity("nearestPoint", v)
				else
					if (nearest:GetPos():Distance(self:GetPos()) > v:GetPos():Distance(self:GetPos())) then
						nearest = v
						self:SetNWEntity("nearestPoint", v)
					end
				end
			end
		end
	end

	self:SetNWInt("waypoint", self.waypoint)
	self:SetNWInt("path", self.path)

	self:SetColor(Color(0,0,0,0))
	self:SetRenderMode( RENDERMODE_TRANSALPHA )
	self:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )
	self:SetNWBool("visible", false)
end

function ENT:MakeWaypointVisible()
	self:SetColor(Color(0,0,0,255))
	self:SetCollisionGroup( COLLISION_GROUP_NONE )
	self:SetNWBool("visible", true)
end

function ENT:Think()

	if (self.time < 8) then
		
		self.time = self.time + 2
		self:SetPos(self.pos+Vector(0,0,self.time))
	else
		self:SetMoveType(MOVETYPE_NONE)
	end
end

function ENT:Use( activator, caller, useType, value )
	net.Start("EditorSetWaypoint")
		net.WriteEntity(self)
		net.WriteInt(self.waypoint, 8)
		net.WriteInt(self.path, 8)
	net.Send(activator)
end