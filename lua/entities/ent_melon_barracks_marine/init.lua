AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

function ENT:Initialize()
	--print("Started Initialize")

	MW_Defaults ( self )

	self.unit = 1
	self.modelString = "models/Items/ammocrate_ar2.mdl"
	self.maxHP = 100
	self.Angles = Angle(0,0,0)
	self:SetPos(self:GetPos()+Vector(0,0,10))

	--print("Changing stats")
	
	self:BarrackInitialize()
	self.population = 1
	self:SetNWInt("maxunits", 10)
	--print("Finished changing stats")

	MW_Setup ( self )
	
	--print("Finished Initialize")
end

function ENT:Think(ent)

	self:SetNWInt("count", 0)

	self:BarrackSlowThink()

	self:NextThink(CurTime()+0.2)
	return true
end

function ENT:Shoot ( ent )
	--MW_DefaultShoot ( ent )
end

function ENT:DeathEffect ( ent )
	MW_DefaultDeathEffect ( ent )
end