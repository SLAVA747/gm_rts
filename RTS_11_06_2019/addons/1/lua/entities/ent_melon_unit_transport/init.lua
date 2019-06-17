AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

function ENT:Initialize()

	MW_Defaults ( self )

	self.unit = 2
	self.modelString = "models/props_junk/wood_crate002a.mdl"
	self.maxHP = 50
	//self.Angles = Angle(0,0,0)
	//self:SetPos(self:GetPos()+Vector(0,0,10))

	self.moveType = MOVETYPE_VPHYSICS
	self.canMove = false
	self.population = 1
	self:SetNWInt("maxunits", 10)
	self:SetNWInt("count", 0)

	self.canEatUnits = true

	MW_Setup ( self )

	self:SetCollisionGroup(COLLISION_GROUP_NONE)

	for i=0, 9 do
		self:SetNWString("class"..i, "")
		self:SetNWFloat("hp"..i, 0)
		self:SetNWInt("value"..i, 0)
	end
end

function ENT:ModifyColor()
	self:SetColor(Color(self:GetColor().r/2+100, self:GetColor().g/2+100, self:GetColor().b/2+100, 255))
end

function ENT:SlowThink(ent)
	--self:SetNWInt("count", 0)
end

function ENT:Shoot ( ent )
	--MW_DefaultShoot ( ent )
end

function ENT:DeathEffect ( ent )
	MW_DefaultDeathEffect ( ent )
end

function ENT:PhysicsCollide( data, physobj )
	local hitEntity = data.HitEntity
	if (hitEntity:IsWorld()) then return end
	
	if (self.canEatUnits and hitEntity:GetNWInt("mw_melonTeam", 0) == self:GetNWInt("mw_melonTeam", -1)) then
		if (hitEntity.Base == "ent_melon_base" and hitEntity.canMove == true and hitEntity:GetClass() != "ent_melon_engine" and hitEntity:GetClass() != "ent_melon_engine_large"and hitEntity:GetClass() != "ent_melon_wheel") then
			if (hitEntity.population <= self:GetNWInt("maxunits", 0) - self:GetNWInt("count", 0)) then
				local index = self:GetNWInt("count", 0)
				self:SetNWInt("count", index+hitEntity.population)
				self:SetNWString("class"..index, hitEntity:GetClass())
				self:SetNWFloat("hp"..index, hitEntity:GetNWFloat("health", 0))
				self:SetNWInt("value"..index, hitEntity.value)
				MW_UpdatePopulation(hitEntity.population, self:GetNWInt("mw_melonTeam", 0))
				self.population = self.population+hitEntity.population
				hitEntity.fired = true
				hitEntity:Remove()
			end
		end
	end
end

function ENT:Actuate()
	self:FreeUnits()
end

function ENT:FreeUnits()
	if (self:GetNWInt("count", 0) > 0) then
		local count = 0
		for i=0, 9 do
			if (self:GetNWString("class"..i, "") != "") then
				count = count+1

				local class = self:GetNWString("class"..i, "")
				local pos = self:GetPos()+Vector(math.random(-10,10),math.random(-10,10),count*10)
				local value = self:GetNWInt("value"..i, 0)
				local hp = self:GetNWInt("hp"..i, 0)
				local _team = self:GetNWInt("mw_melonTeam", -1)

				local newMarine = ents.Create( class )
				if ( !IsValid( newMarine ) ) then return end -- Check whether we successfully made an entity, if not - bail

				newMarine:SetPos(pos)
				
				--sound.Play( "garrysmod/content_downloaded.wav", trace.HitPos, 60, 90, 1 )
				--sound.Play( "garrysmod/content_downloaded.wav", pl:GetPos(), 60, 90, 1 )
				mw_melonTeam = _team

				newMarine:Spawn()
				
				newMarine:Ini(_team)
				newMarine.fired = true
				
				local pl = self:GetOwner()

				pl.mw_melonTeam = _team
				
				newMarine:SetOwner(pl)

				newMarine.value = value
				newMarine:SetNWFloat("Health", hp)
				
				undo.Create("Melon Marine")
				 undo.AddEntity( newMarine )
				 undo.SetPlayer( pl)
				undo.Finish()

				self:SetNWString("class"..i, "")
				self:SetNWInt("value"..i, 0)
				self:SetNWInt("hp"..i, 0)
			end
		end
		self:SetNWInt("count", 0)
		self.canEatUnits = false
		local originalColor = self:GetColor()
		self:SetColor(Color(self:GetColor().r/2, self:GetColor().g/2, self:GetColor().b/2, 255))
		timer.Simple(10, function()
			if (IsValid(self)) then
				self.canEatUnits = true
				self:SetColor(originalColor)
			end
		end)
	end
end

function ENT:OnRemove()
	MW_UpdatePopulation(-self.population, self:GetNWInt("mw_melonTeam", 0))
	self:FreeUnits()
end