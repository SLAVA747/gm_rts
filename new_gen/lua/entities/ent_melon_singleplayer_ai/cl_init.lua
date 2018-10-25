include('shared.lua')

function ENT:Draw()
    -- self.BaseClass.Draw(self) -- Overrides Draw
    self:DrawModel() -- Draws Model Client Side

    render.SetMaterial( Material( "color" ) )
	--for i=5, 1, -1 do
		--local neighbour = self:GetNWEntity("neighbour"..i, nil)
		--if (tostring(neighbour) ~= "[NULL Entity]") then
		local nearest = self:GetNWEntity("nearestPoint", nil)
		if (tostring(nearest) ~= "[NULL Entity]") then
			render.DrawBeam( self:GetPos()+Vector(0,0,250), nearest:GetPos(), 1, 1, 1, Color( 0, 255, 255, 255 ) )
			render.DrawBeam( self:GetPos()+Vector(0,0,250), nearest:GetPos(), 3, 1, 1, Color( 0, 255, 255, 100 ) )
		end
end