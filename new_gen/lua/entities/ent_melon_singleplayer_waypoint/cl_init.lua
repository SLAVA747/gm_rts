include('shared.lua')

function ENT:Draw()
    self:DrawModel() -- Draws Model Client Side
    render.SetMaterial( Material( "color" ) )
	local nearest = self:GetNWEntity("nearestPoint", nil)
	if (tostring(nearest) ~= "[NULL Entity]") then
		render.DrawBeam( self:GetPos(), nearest:GetPos(), 1, 1, 1, Color( 0, 255, 255, 255 ) )
		render.DrawBeam( self:GetPos(), nearest:GetPos(), 3, 1, 1, Color( 0, 255, 255, 100 ) )
	end
	local angle = EyeAngles()
	angle:RotateAroundAxis(angle:Right(),90)
	angle:RotateAroundAxis(angle:Up(),-90)
	local vpos = self:WorldSpaceCenter()+Vector(0,0,20)-angle:Forward()*8
	cam.Start3D2D( vpos, angle, 0.4 )
		surface.SetFont( "DermaLarge" )
		surface.SetTextColor( 255, 255, 255, 255 )
		surface.SetTextPos( 0, 0 )
		surface.DrawText( self:GetNWInt("path",-1).."-"..self:GetNWInt("waypoint",-1) )
	cam.End3D2D()
end