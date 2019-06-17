include('shared.lua')

function ENT:ClientThink()
	if (self.t == nil or self.t == -1) then
		self.t = self:GetNWInt("mw_melonTeam", -1)
	end
	if (self.m == nil) then
		if (self:GetMoveType() != nil) then
			self.m = self:GetMoveType()
		end
	end
end

function ENT:Draw()
    if (self.m != MOVETYPE_NONE or cvars.Number("mw_team") == self.t) then
	    self:DrawModel() -- Draws Model Client Side
	end
    local time = self:GetNWFloat("spawnTime",0)
    if (CurTime() < time) then
	    local angle = LocalPlayer():EyeAngles()+Angle(0,0,90)
	    angle:RotateAroundAxis( LocalPlayer():EyeAngles():Up(), -90 )
	    local vpos = self:WorldSpaceCenter()--+angle:Forward()*10-angle:Right()*10/2
		cam.Start3D2D( vpos, angle, 0.5 )
			draw.SimpleText( tostring(math.ceil(time-CurTime())).."s", "Trebuchet24", 0, 0, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		cam.End3D2D()
	end
end

// New Year
/*function ENT:OnRemove()
	MW_Firework(self, 50, 1.5)
	MW_Firework(self, 50, 2)
end*/