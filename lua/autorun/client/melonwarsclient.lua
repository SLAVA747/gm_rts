hook.Add( "Initialize", "start", function()
	LocalPlayer().mw_selecting = 1
	LocalPlayer().mw_selStart = Vector(0,0,0)
	LocalPlayer().mw_selEnd = Vector(0,0,0)
	LocalPlayer().mw_toolCost = -1
	LocalPlayer().mw_hudColor = Color(10,10,10,20)
	
	LocalPlayer().mw_hover = 0
	LocalPlayer().mw_menu = 0
	LocalPlayer().mw_selectTimer = 0
	LocalPlayer().mw_spawnTimer = 0
	LocalPlayer().mw_cooldown = 0
	LocalPlayer().mw_frame = nil
	
	LocalPlayer().mw_units = 0
	LocalPlayer().mw_credits = 0
	
	foundMelons = {}

	return true 
end)

mw_team_colors  = {Color(255,50,50,255),Color(50,50,255,255),Color(255,200,50,255),Color(30,200,30,255),Color(255,50,255,255),Color(100,255,255,255),Color(255,120,0,255),Color(255,100,150,255)}

hook.Add( "Think", "update", function()	
	if (mw_selecting) then
		LocalPlayer().mw_selEnd = LocalPlayer():GetEyeTrace().HitPos
	end

	local tr = LocalPlayer():GetEyeTrace()
	local ent = tr.Entity
	if (ent:GetNWString("message", "nope") != "nope") then
        AddWorldTip( nil,ent:GetNWString("message", "nope"), nil, Vector(0,0,0), ent )
    end
end)

net.Receive( "Selection", function( len, pl )
	if (LocalPlayer():KeyDown(IN_SPEED)) then
		else table.Empty(foundMelons) end
	local ammount = net.ReadInt(16)
	for i = 1,ammount do
        table.insert(foundMelons, net.ReadEntity())
    end
	LocalPlayer():SetNWVector("mw_selEnd", LocalPlayer():GetNWVector("mw_selStart", Vector(0,0,0)))
	LocalPlayer().mw_selEnd = Vector(0,0,0)
end )

net.Receive( "RestartQueue", function( len, pl )
	LocalPlayer().mw_spawntime = CurTime()
end)

net.Receive("ContraptionSaveClient", function (len, pl)
	local dubJSON = net.ReadString()
	local name = net.ReadString()
	file.CreateDir( "melonwars/contraptions" )
	file.Write( "melonwars/contraptions/"..name..".txt", dubJSON )
end)

hook.Add("OnTextEntryGetFocus", "disableKeyboard", function (panel)
	LocalPlayer().disableKeyboard = true
end)

hook.Add("OnTextEntryLoseFocus", "enableKeyboard", function (panel)
	LocalPlayer().disableKeyboard = false
end)

hook.Add( "OnContextMenuOpen", "AddHalos", function()
	LocalPlayer():ConCommand("mw_context_menu 1")
end )

hook.Add( "OnContextMenuClose", "AddHalos", function()
	LocalPlayer():ConCommand("mw_context_menu 0")
end )

hook.Add( "PreDrawHalos", "AddHalos", function()

	--[[if (istable(foundMelons)) then
		halo.Add( foundMelons, Color( 255, 255, 100 ), 2, 2, 1, true, true )
	end]]

	local entityTable = {}
	if (LocalPlayer():KeyDown(IN_WALK)) then
		table.Empty(entityTable)
		local eyeEntity = LocalPlayer():GetEyeTrace().Entity
		if (tostring( eyeEntity ~= "Entity [0][worldspawn]")) then
			table.insert(entityTable, eyeEntity)
		if (istable(entityTable)) then
				halo.Add( entityTable, Color( 255, 100, 100 ), 2, 2, 1, true, true )
			end
		end
	end

	local zoneTable = ents.FindByClass( "ent_melon_zone" )
	local a = LocalPlayer():GetInfoNum("mw_team", 0)

	for i = table.Count(zoneTable), 1, -1 do
		if (zoneTable[i]:GetNWInt("zoneTeam", 0) != a or (zoneTable[i]:GetPos()-LocalPlayer():GetPos()):LengthSqr() > 10000000) then
			table.remove(zoneTable, i)
		end
	end
	halo.Add( zoneTable, Color(200,200,200,255), 0, 3, 1, true, true )
end)

hook.Add( "PostDrawTranslucentRenderables", "hud", function()
	local angle = LocalPlayer():EyeAngles()+Angle(-90,0,0)
	
	if (LocalPlayer().mw_selecting and LocalPlayer():GetNWVector("mw_selStart", Vector(0,0,0)) ~= Vector(0,0,0)) then
		local mw_selStart = LocalPlayer():GetNWVector("mw_selStart", Vector(0,0,0))
		local mw_selEnd = LocalPlayer():GetNWVector("mw_selEnd", Vector(0,0,0))
		local radius = mw_selStart:Distance(mw_selEnd)/2
		surface.SetDrawColor(Color( 0, 255, 0, 255 ))
		cam.Start3D2D((mw_selStart+mw_selEnd)/2 + Vector(0,0,3), Angle(0,0,0), 3 )
		for i = 1, 160 do
			surface.DrawRect( math.sin(i/math.pi/8)*radius/3, math.cos(i/math.pi/8)*radius/3, 2, 2)
		end
		cam.End3D2D()
	end

	if (istable(foundMelons)) then
		surface.SetDrawColor(Color( 0, 255, 0, 255 ))
		draw.NoTexture()
		for k, v in pairs( foundMelons ) do
			if (v:IsValid()) then
				local floorTrace = v.floorTrace
				if (floorTrace != nil) then
					if (floorTrace.Hit) then
						local hp = v:GetNWFloat("health", 0)
						if (hp > 0) then
							local maxhp = v:GetNWFloat("maxhealth", 1)
							local pos = v:GetPos()+v:OBBCenter()
							if (v.circleSize ~= nil) then
								local polySize = v.circleSize
								local poly = {
									{ x = polySize, y = 0 },
									{ x = polySize*0.72, y = polySize*0.72 },
									{ x = 0, y = polySize },
									{ x = -polySize*0.72, y = polySize*0.72 },
									{ x = -polySize, y = 0 },
									{ x = -polySize*0.72, y = -polySize*0.72 },
									{ x = 0, y = -polySize },
									{ x = polySize*0.72, y = -polySize*0.72 }
								}
								surface.SetDrawColor(Color( 255*math.min((1-hp/maxhp)*2,1), 255*math.min(hp/maxhp*2,1), 0, 255 ))
								cam.Start3D2D(Vector(pos.x, pos.y, floorTrace.HitPos.z+1), floorTrace.HitNormal:Angle()+Angle(90,0,0), 1 )
									surface.DrawPoly( poly )
								cam.End3D2D()
							end
						end
					end
				end
			else
				table.RemoveByValue( foundMelons, v )
			end
		end
	end
end )

hook.Add( "HUDPaint", "hud", function()

	local AlertIcons = ents.FindByClass( "ent_melon_HUD_alert" )
	local a = LocalPlayer():GetInfoNum("mw_team", 0)
	for k, v in pairs(AlertIcons) do
		if (v:GetNWInt("drawTeam", 0) == a) then
			local pos = v:GetPos():ToScreen()
			pos = Vector(pos.x, pos.y)
			local border = ScrH()/3
			local center = Vector(ScrW()/2, ScrH()/2)
			if ((pos-center):LengthSqr() > border*border) then
				pos = center+(pos-center):GetNormalized()*border
			end
			surface.SetDrawColor(Color(255,0,0,255))
		  	surface.DrawRect( pos.x - 16, pos.y - 20, 32, 40 )
			surface.SetDrawColor(Color(150,0,0,255))
		  	surface.DrawRect( pos.x - 12, pos.y - 16, 24, 32 )
		  	surface.SetDrawColor(Color(255,0,0,255))
		  	surface.DrawRect( pos.x - 3, pos.y - 12, 6, 14 )
		  	surface.DrawRect( pos.x - 3, pos.y + 6, 6, 6 )
		  end
	end

	local MainBases = ents.FindByClass( "ent_melon_main_building*" )

	for k, v in pairs(MainBases) do
		local drw = false
	    if ((LocalPlayer():GetPos()-v:GetPos()):LengthSqr() < 800000) then
	    	drw = true
	    elseif (CurTime() < v:GetNWFloat("lastHit", 0)+5) then
	    	drw = true
	    end

	    if (drw) then
		    local pos = (v:GetPos()+Vector(0,0,v:OBBMaxs().z)):ToScreen()
			pos = Vector(pos.x, pos.y-100)
			--local border = ScrH()/2
			--local center = Vector(ScrW()/2, ScrH()/2)
			--if ((pos-center):LengthSqr() > border*border) then
			--	pos = center+(pos-center):GetNormalized()*border
			--end
			local percent = v:GetNWInt("health", 3)/v:GetNWInt("maxhealth", 10)
			surface.SetDrawColor(Color(0,0,0,255))
		  	surface.DrawRect( pos.x - 15, pos.y - 55, 30, 160 )
			surface.SetDrawColor(Color(255,0,0,255))
		  	surface.DrawRect( pos.x - 10, pos.y + 100 -150*(percent), 20, 150*(percent) )
		end
	end

	if (istable(foundMelons)) then
		for k, v in pairs( foundMelons ) do
			if (v:IsValid()) then
				--[[local hp = v:GetNWFloat("health", 0)
				local maxhp = v:GetNWFloat("maxhealth", 1)
				if (hp > 0) then
					local pos = v:GetPos():ToScreen()
					local clampedBar = math.max(15, math.min(100, hp))
					surface.SetDrawColor(Color( 0, 0, 0, 100 ))
					surface.DrawOutlinedRect( pos.x - clampedBar/2 -1, pos.y - 61, clampedBar +2, 13 )
					surface.SetDrawColor(Color( 255*math.min((1-hp/maxhp)*2,1), 255*math.min(hp/maxhp*2,1), 0, 100 ))
					surface.DrawRect( pos.x - clampedBar/2, pos.y - 60, clampedBar, 11 )

					surface.SetFont( "Trebuchet18" )
					surface.SetTextColor( 0, 0, 0, 255 )
					surface.SetTextPos( pos.x - 6, pos.y - 63 )
					surface.DrawText( math.Round(hp))]]

					local fe = v:GetNWEntity("followEntity", nil)
					if (fe:IsValid() && fe != v) then
						pos = fe:WorldSpaceCenter():ToScreen()
						DrawMelonCross(pos, Color( 0, 150, 255, 255 ))
					elseif (v:GetNWBool("moving", false)) then
						pos = v:GetNWVector("targetPos"):ToScreen()
						DrawMelonCross(pos, Color( 0, 255, 0, 255 ))
					end

					local te = v:GetNWEntity("targetEntity", nil)
					if (te:IsValid() && te != v) then
						pos = te:WorldSpaceCenter():ToScreen()
						DrawMelonCross(pos, Color( 255, 0, 0, 255 ))
					end
				end
			--end
		end
	end

	local points = ents.FindByClass( "ent_melon_cap_point" )
	table.Add(points, ents.FindByClass( "ent_melon_outpost_point" ))
	table.Add(points, ents.FindByClass( "ent_melon_mcguffin" ))
	table.Add(points, ents.FindByClass( "ent_melon_water_tank" ))
	if (istable(points)) then
		for k, v in RandomPairs( points ) do
			if (IsValid(v)) then
				local captured = {0,0,0,0,0,0,0,0}
				local capturing = 0
				for i=1, 8 do
					if (v:GetNWInt("captured"..tostring(i), 0) > 0) then
						local vpos = v:WorldSpaceCenter()+Vector(0,0,100)
						local pos = vpos:ToScreen()
						surface.SetDrawColor(Color( 0, 0, 0, 255 ))
						surface.DrawRect( pos.x - 5 -3, pos.y - 123, 10 +6, 106 )
						surface.SetDrawColor(Color( 255, 255, 255, 255 ))
						surface.DrawRect( pos.x - 5 , pos.y - 120, 10, 100 )
						surface.SetDrawColor(mw_team_colors[i])
						local capture = v:GetNWInt("captured"..tostring(i), 0)
						surface.DrawRect( pos.x - 5 , pos.y - 20 - capture, 10 , capture )
					end
				end
			end
		end
	end
end )

function DrawMelonCross (pos, _color)
	surface.SetDrawColor(Color( 0, 0, 0, 255 ))
	surface.DrawRect( pos.x-2, pos.y-10, 9, 25 )
	surface.DrawRect( pos.x-10, pos.y-2, 25, 9 )
	surface.SetDrawColor(_color)
	surface.DrawRect( pos.x, pos.y-8, 5, 21 )
	surface.DrawRect( pos.x-8, pos.y, 21, 5 )
end

net.Receive( "MW_TeamCredits", function( len, pl )
	LocalPlayer().mw_credits = net.ReadInt(16)
end )

net.Receive( "MW_TeamUnits", function( len, pl )
	LocalPlayer().mw_units = net.ReadInt(16)
end )

net.Receive( "ChatTimer", function( len, pl )
	LocalPlayer().chatTimer = 1000
end )

net.Receive( "RequestContraptionLoadToClient", function( len, pl )
	local _file = net.ReadString()
	local ent = net.ReadEntity()
	net.Start("ContraptionLoad")
		net.WriteString(file.Read( _file ))
		net.WriteEntity(ent)
	net.SendToServer()
end )

net.Receive( "EditorSetTeam", function( len, pl )
	local ent = net.ReadEntity()
	local frame = vgui.Create("DFrame")
	local w = 250
	local h = 160
	frame:SetSize(w,h)
	frame:SetPos(ScrW()/2-w/2+150,ScrH()/2-h/3)
	frame:SetTitle("Set team")
	frame:MakePopup()
	frame:ShowCloseButton()
	local button = vgui.Create("DButton", frame)
	button:SetSize(50,18)
	button:SetPos(w-53,3)
	button:SetText("x")
	function button:DoClick()
		frame:Remove()
		frame = nil
	end
	for i=1, 8 do
		button = vgui.Create("DButton", frame)
		button:SetSize(29,100)
		button:SetPos(5+30*(i-1),50)
		button:SetText("")
		function button:DoClick()
			net.Start("ServerSetTeam")
				net.WriteEntity(ent)
				net.WriteInt(i, 4)
			net.SendToServer()
			ent:SetColor(mw_team_colors[i])
			ent.mw_melonTeam = i
			frame:Remove()
			frame = nil
		end
		button.Paint = function(s, w, h)
			draw.RoundedBox( 6, 0, 0, w, h, Color(30,30,30,255) )
			draw.RoundedBox( 4, 2, 2, w-4, h-4, mw_team_colors[i] )
		end
	end
end )

net.Receive( "EditorSetStage", function( len, pl )
	local ent = net.ReadEntity()
	local frame = vgui.Create("DFrame")
	local w = 250
	local h = 100
	frame:SetSize(w,h)
	frame:SetPos(ScrW()/2-w/2+150,ScrH()/2-h/3)
	frame:SetTitle("Set Stage")
	frame:MakePopup()
	frame:ShowCloseButton()
	local button = vgui.Create("DButton", frame)
	button:SetSize(50,18)
	button:SetPos(w-53,3)
	button:SetText("x")
	function button:DoClick()
		frame:Remove()
		frame = nil
	end
	local wang = vgui.Create("DNumberWang", frame)
	wang:SetPos(20,50)
	button = vgui.Create("DButton", frame)
	button:SetSize(100,50)
	button:SetPos(120,35)
	button:SetText("Done")
	function button:DoClick()
		net.Start("ServerSetStage")
			net.WriteEntity(ent)
			net.WriteInt(wang:GetValue(), 8)
		net.SendToServer()
		ent.stage = wang:GetValue()
		frame:Remove()
		frame = nil
	end
end )

net.Receive( "DrawWireframeBox", function( len, pl )
	local pos = net.ReadVector()
	local min = net.ReadVector()
	local max = net.ReadVector()
	render.DrawWireframeBox( pos, Angle(0,0,0), min, max, Color(255,255,255,255), false )
end )	

net.Receive( "EditorSetWaypoint", function( len, pl )
	local ent = net.ReadEntity()
	local waypoint = net.ReadInt(4)
	local path = net.ReadInt(4)
	local frame = vgui.Create("DFrame")
	local w = 250
	local h = 110
	frame:SetSize(w,h)
	frame:SetPos(ScrW()/2-w/2+150,ScrH()/2-h/3)
	frame:SetTitle("Set Waypoint")
	frame:MakePopup()
	frame:ShowCloseButton()
	local button = vgui.Create("DButton", frame)
	button:SetSize(50,18)
	button:SetPos(w-53,3)
	button:SetText("x")
	function button:DoClick()
		frame:Remove()
		frame = nil
	end
	local label = vgui.Create("DLabel", frame)
	label:SetPos(20,20)
	label:SetText("Waypoint")
	local waypointwang = vgui.Create("DNumberWang", frame)
	waypointwang:SetPos(20,35)
	if (ent.waypoint == nil) then ent.waypoint = 1 end
	waypointwang:SetValue(ent.waypoint)
	label = vgui.Create("DLabel", frame)
	label:SetPos(20,55)
	label:SetText("Path")
	local pathwang = vgui.Create("DNumberWang", frame)
	pathwang:SetPos(20,70)
	if (ent.path == nil) then ent.path = 1 end
	pathwang:SetValue(ent.path)
	button = vgui.Create("DButton", frame)
	button:SetSize(100,50)
	button:SetPos(120,35)
	button:SetText("Done")
	function button:DoClick()
		net.Start("ServerSetWaypoint")
			net.WriteEntity(ent)
			net.WriteInt(waypointwang:GetValue(), 8)
			net.WriteInt(pathwang:GetValue(), 8)
		net.SendToServer()
		ent.waypoint = waypointwang:GetValue()
		ent.path = pathwang:GetValue()
		frame:Remove()
		frame = nil
	end
end )