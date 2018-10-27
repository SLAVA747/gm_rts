
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
mw_icons_id_units = {"RTS_MelonWars/units/1.jpg","RTS_MelonWars/units/2.jpg","RTS_MelonWars/units/3.jpg","RTS_MelonWars/units/4.jpg","RTS_MelonWars/units/5.jpg","RTS_MelonWars/units/6.jpg","RTS_MelonWars/units/7.jpg","RTS_MelonWars/units/8.jpg","RTS_MelonWars/units/9.jpg","RTS_MelonWars/empty.jpg"}
--[[
"materials/RTS_MelonWars/Артиллерийское_депо.jpg"

"materials/RTS_MelonWars/Батарея_Б.jpg"
"materials/RTS_MelonWars/Батарея_М.jpg"
"materials/RTS_MelonWars/Батарея_С.jpg"
"materials/RTS_MelonWars/Башня_тесла.jpg"
"materials/RTS_MelonWars/Большие_ворота.jpg"
"materials/RTS_MelonWars/Большой_столб.jpg"
"materials/RTS_MelonWars/Военный_завод.jpg"
"materials/RTS_MelonWars/Воздушные_войска.jpg"
"materials/RTS_MelonWars/Ворота.jpg"
"materials/RTS_MelonWars/Госпиталь.jpg"
"materials/RTS_MelonWars/Казармы_базутчики.jpg"
"materials/RTS_MelonWars/Казармы_медики.jpg"
"materials/RTS_MelonWars/Казармы_пехота.jpg"
"materials/RTS_MelonWars/Казармы_пулемётчики.jpg"
"materials/RTS_MelonWars/Казармы_снаперы.jpg"
"materials/RTS_MelonWars/Казармы_шахиды.jpg"
"materials/RTS_MelonWars/Лифт.jpg"


"materials/RTS_MelonWars/Паровой_двигатель.jpg"


"materials/RTS_MelonWars/Радар.jpg"

"materials/RTS_MelonWars/Солнечная_батарея.jpg"
"materials/RTS_MelonWars/Столб.jpg"
"materials/RTS_MelonWars/Тумблер.jpg"
"materials/RTS_MelonWars/Турель.jpg"
"materials/RTS_MelonWars/Ускоритель.jpg"

"materials/RTS_MelonWars/Шредер.jpg"

"materials/RTS_MelonWars/Ядерная_шахта.jpg"
"materials/RTS_MelonWars/Ядерный_реактор.jpg"
]]
 

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

net.Receive("PlaySound", function(len, pl)
	local sound = net.ReadString()

	

end)

hook.Add("HUDDrawTargetID", "MelonHUDDrawTargetID", function()
	local trace = LocalPlayer():GetEyeTrace()

	if (IsValid(trace.Entity)) then
		local entity = trace.Entity
		local name = entity:GetNWString("mw_name")

		if (name) then
			surface.SetFont("Trebuchet24")

			local width, height = surface.GetTextSize(name)

			surface.SetTextColor(255, 215, 0)
			surface.SetTextPos(ScrW() / 2 - width / 2, ScrH() / 1.8)
			surface.DrawText(name)
		end
	end
end)

--Интерфейс
function i_take_my_water(my_water_take)
my_water = my_water_take;
end
function i_take_my_food(my_food_take)
my_food = my_food_take;
end

net.Receive("HUDTeam", function(len, pl)
if (HUDTeama) then
HUDTeama:Remove()
end
	local icon_jump = 1;
	local pl = LocalPlayer()
	local icon_jump_up=5;
	local id_cost = 0;
	HUDTeama = vgui.Create( "DPanel" )
	local MelonColor = net.ReadColor(MelonColor)
	HUDTeama:SetPos( 5, 5 ) -- Set the position of the panel
	HUDTeama:SetSize( 255, ScrH()-20 ) -- Set the size of the panel
	HUDTeama:SetBackgroundColor(0,0,0,0)
	HUDTeama.Paint = function()
		draw.RoundedBox(5,8,3,242,ScrH()-26, Color(0,0,0))
		draw.RoundedBox(5,10,5,237,ScrH()-30, MelonColor)
	end
	

	-- Settings menu
local Status_Panel = vgui.Create( "DPanel", HUDTeama )
Status_Panel:SetPos( 5, 5 )
Status_Panel:SetSize( 255, 40)
Status_Panel.Paint = function()
		draw.RoundedBox(0,8,3,231,36, Color(0,0,0))
		draw.RoundedBox(0,10,5,226,32, Color(255,255,255,255))
		draw.RoundedBox(0,8,3,40,36, Color(0,0,0))
		draw.RoundedBox(0,10,5,36,32, Color(255,255,255,255))
		


	end
Settings_img = vgui.Create( "DImageButton", Status_Panel )	-- Add image to Frame
Settings_img:SetPos( 10, 6 )	-- Move it into frame
Settings_img:SetSize( 30, 30 )	-- Size it to 150x150
Settings_img:SetImage( "materials/RTS_MelonWars/icon/5.png" )










	-- units menu
	local Buld_menu = vgui.Create("DPanel", HUDTeama )
			local DScrollPanel = vgui.Create( "DScrollPanel", Buld_menu )
			Buld_menu:SetPos( 5, 300 )
			Buld_menu:SetSize( 240, ScrH()-370)
			Buld_menu.Paint = function()
			draw.RoundedBox(5,8,3,231,ScrH()-371, Color(0,0,0))
			draw.RoundedBox(5,10,5,227,ScrH()-377, MelonColor)
			end
			 DScrollPanel:SetSize( 235, ScrH()-377 )
			
	for i=0, 700, 70 do
		for j=0,150,70 do
		id_cost=id_cost+1
		if id_cost > 9 then
			id_cost=10
		end
			local MelonBuildMenu = DScrollPanel:Add( "DImageButton")
			if j == 0 then
				MelonBuildMenu:SetPos( 13+j, 10+i+icon_jump_up )				// Set position
			else
				MelonBuildMenu:SetPos( icon_jump+13+j, 10+i+icon_jump_up )				// Set position
				icon_jump=icon_jump+1
			end
			MelonBuildMenu:SetSize( 65, 65 )
			MelonBuildMenu:SetImage( mw_icons_id_units[id_cost] )	// Set the material - relative to /materials/ directory
			MelonBuildMenu.DoClick = function()
					LocalPlayer():ConCommand("mw_chosen_unit "..tostring(id_cost)) 
					LocalPlayer():ConCommand("mw_action 1")
					pl.mw_frame:Remove()
					pl.mw_frame = nil
				end
			end
		icon_jump=1	
		icon_jump_up=icon_jump_up+5;
	end
	-- Meat and water menu
Status_Panel = vgui.Create( "DPanel", HUDTeama )
Status_Panel:SetPos( 10, ScrH()-68 )
Status_Panel:SetSize( 255, 40)
Status_Panel.Paint = function()
		draw.RoundedBox(0,8,3,226,36, Color(0,0,0))
		draw.RoundedBox(0,10,5,221,32, Color(255,255,255,255))
		draw.RoundedBox(0,8,3,112,36, Color(0,0,0))
		draw.RoundedBox(0,10,5,107,32, Color(255,255,255,255))
		
		draw.DrawText( tostring(my_water), "CloseCaption_Bold", 72, 8, Color(0,0,0,255), TEXT_ALIGN_CENTER )
		draw.DrawText( tostring(my_food).."/"..tostring(cvars.Number("mw_admin_max_units")), "CloseCaption_Bold", 185, 8,  Color(0,0,0,255), TEXT_ALIGN_CENTER )
				
	end
local Water_img = vgui.Create( "DImage", Status_Panel )	-- Add image to Frame
Water_img:SetPos( 10, 12 )	-- Move it into frame
Water_img:SetSize( 20, 20 )	-- Size it to 150x150
Water_img:SetImage( "materials/RTS_MelonWars/icon/1.png" )
local Meat_img = vgui.Create( "DImage", Status_Panel )	-- Add image to Frame
Meat_img:SetPos( 120, 12 )	-- Move it into frame
Meat_img:SetSize( 20, 20 )	-- Size it to 150x150
Meat_img:SetImage( "materials/RTS_MelonWars/icon/2.png" )




end) 
-- F1 в помощь
function myfunc() if input.IsKeyDown( KEY_F1 ) then 
	local pl = LocalPlayer()
	local Hide_Hud = true;
	  if HUDTeama then
		if (HUDTeama:Hide(false)) then
		HUDTeama:Hide(true)
		print ("скрыл")
		else
		HUDTeama:Hide(false)
end
end
end
end


hook.Add("Think","twsgsh",myfunc)

-- Отрубаем к херам sandboxсовскую хрень
--hook.Add('OnContextMenuOpen', 'MelonPlayerDisableContextMenu', function() return false end)
--hook.Add( "OnSpawnMenuOpen", "MelonPlayerDisableFukingQButton", function() return false end )
-- Отрубаем HP, бронь, патроны и тд.
hook.Add( "HUDShouldDraw", "HideHUD", function( name )
	if ( name == "CHudHealth" or name == "CHudBattery" or name == "CHudAmmo" or name == "CHudSecondaryAmmo" or name == "CHudDeathNotice" or name == "CHudHintDisplay" ) then return false end
end)

-- Делаем интерфейс
-- hook.Add( "Think", "MelonPlayerShowHud", function( ply, key )
--	if (input.IsKeyDown( KEY_Q ) ) then
--		print( "hi" )
--	end
-- end )


