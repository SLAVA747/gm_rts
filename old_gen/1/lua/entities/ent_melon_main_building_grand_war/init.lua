AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

debri_props	 = {
"models/props_combine/combine_light002a.mdl",
"models/props_combine/tprotato2_chunk01.mdl",
"models/props_combine/tprotato2_chunk03.mdl",
"models/props_combine/combine_barricade_bracket02b.mdl",
"models/props_combine/combine_lock01.mdl",
"models/props_combine/combine_barricade_bracket01b.mdl",
"models/props_combine/combine_barricade_bracket01a.mdl",
"models/props_junk/watermelon01.mdl",
"models/props_junk/watermelon01.mdl",
"models/props_junk/watermelon01.mdl",
"models/props_junk/watermelon01.mdl",
"models/props_junk/watermelon01.mdl",
"models/props_junk/watermelon01.mdl",
"models/props_junk/watermelon01.mdl",
"models/props_junk/watermelon01.mdl",
"models/props_junk/watermelon01.mdl",
"models/props_junk/watermelon01.mdl",
"models/props_junk/watermelon01.mdl",
"models/props_junk/watermelon01.mdl",
"models/props_junk/watermelon01.mdl",
"models/props_junk/watermelon01.mdl",
"models/props_junk/watermelon01.mdl",
"models/props_junk/watermelon01.mdl",
"models/props_junk/watermelon01.mdl"
}

function ENT:Initialize()

	MW_Defaults ( self )
		
	self.slowThinkTimer = 1
	self.nextSlowThink = 0
	self.modelString = "models/props_combine/combinethumper001a.mdl"
	self.Angles = Angle(0,0,0)
	self.shotOffset = Vector(0,-20,30)
	self:SetPos(self:GetPos()+Vector(0,0,1))
	self.materialString = "models/shiny"
	
	self.canMove = false
	self.canBeSelected = false
	
	self.maxHP = 500
	self.income = 50
	self.dead = false
	
	self.population = 0
	
	self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self.moveType = MOVETYPE_NONE 
	--local weld = constraint.Weld( self, game.GetWorld(), 0, 0, 0, true , false )
	
	self:SetNWInt("energy", 0)
	self:SetNWFloat("state", 0) --0 = neutral, 1 = dar, -1 = necesitar
	self:SetNWInt("maxenergy", 100)
	self:SetNWVector("energyPos", Vector(0,0,100))

	MW_Setup ( self )
	
	self.zone = ents.Create( "ent_melon_zone" )
		self.zone:SetModel("models/hunter/tubes/circle2x2.mdl")
		self.zone:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )
		
		self.zone:SetPos(self:GetPos())
		self.zone:Spawn()
		self.zone:SetPos(self:GetPos()+Vector(0,0,-12))
		self.zone:SetMoveType( MOVETYPE_NONE )
		self.zone:SetModelScale( 33.6, 0 )
		self.zone:SetMaterial( "models/debug/debugwhite" )
		self.zone:SetNWInt("zoneTeam", mw_melonTeam)
		
		self:DeleteOnRemove( self.zone )
end