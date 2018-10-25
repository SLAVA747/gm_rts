AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

function ENT:Initialize()
	--print("Started Initialize")

	MW_Energy_Defaults ( self )

	self.modelString = "models/props_combine/weaponstripper.mdl"
	self.maxHP = 100
	self.Angles = Angle(-90,0,180)
	local offset = Vector(-62.5,0,0)
	offset:Rotate(self:GetAngles())
	self:SetPos(self:GetPos()+offset)
	--self:SetPos(self:GetPos()+Vector(0,0,10))
	self.moveType = MOVETYPE_NONE

	self.canMove = false

	self.population = 0
	self.capacity = 0
	self:SetNWVector("energyPos", Vector(0,0,62.5))

	self.shotOffset = Vector(0,0,1)

	--print("Finished changing stats")
	MW_Energy_Setup ( self )
end

function ENT:Think(ent)
	if(self.spawned) then
		local can = self:GivePower(2)
		if (can) then
			self:SetNWString("message", "Generating energy")
		else
			self:SetNWString("message", "Energy full!")
		end
	end
	self:Energy_Add_State()
	self:NextThink( CurTime()+1 )
	return true
end

function ENT:SlowThink(ent)

end

function ENT:Shoot ( ent )

end

function ENT:DeathEffect ( ent )
	MW_DefaultDeathEffect ( ent )
end