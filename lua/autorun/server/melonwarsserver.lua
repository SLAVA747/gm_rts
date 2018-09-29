-- ( Some lines from the cl_spawnmenu.lua in the sandbox GM )
--function GM:Initialize()
--Net vars para mandar el equipo y los creditos al cliente
util.AddNetworkString( "MW_TeamCredits" )
util.AddNetworkString( "MW_TeamUpdate" )
util.AddNetworkString( "MW_TeamUnits" )
util.AddNetworkString( "MW_UpdateClientInfo" )
util.AddNetworkString( "MW_UpdateServerInfo" )

util.AddNetworkString( "MW_SpawnUnit" )
util.AddNetworkString( "SpawnBase" )
util.AddNetworkString( "SpawnBaseGrandWar" )
--util.AddNetworkString( "SpawnTransport" )
util.AddNetworkString( "MW_SpawnProp" )
util.AddNetworkString( "StartGame" )
util.AddNetworkString( "SandboxMode" )

util.AddNetworkString( "ToggleBarracks" )
util.AddNetworkString( "MW_Activate" )
util.AddNetworkString( "ActivateGate" )
util.AddNetworkString( "ActivateWaypoints" )
util.AddNetworkString( "PropellerReady" )
util.AddNetworkString( "UseWaterTank" )

util.AddNetworkString( "RestartQueue" )

util.AddNetworkString( "CalcContraption" )

util.AddNetworkString( "UpdateClientTeams" )
util.AddNetworkString( "UpdateServerTeams" )
util.AddNetworkString( "RequestServerTeams" )

util.AddNetworkString( "ContraptionSave" )
util.AddNetworkString( "ContraptionSaveClient" )
util.AddNetworkString( "ContraptionLoad" )
util.AddNetworkString( "RequestContraptionLoadToAssembler" )
util.AddNetworkString( "RequestContraptionLoadToClient" )

util.AddNetworkString( "EditorSetTeam" ) -- Unit marker
util.AddNetworkString( "ServerSetTeam" )
util.AddNetworkString( "EditorSetStage" ) -- Main base marker
util.AddNetworkString( "ServerSetStage" )
util.AddNetworkString( "EditorSetWaypoint" ) -- Waypoint
util.AddNetworkString( "ServerSetWaypoint" )
util.AddNetworkString( "DrawWireframeBox" )
--[[util.AddNetworkString( "EditorSetSpawnpoint" ) -- Waypoint
util.AddNetworkString( "ServerSetSpawnpoint" )]]

util.AddNetworkString( "ChatTimer" )

--CreateConVar( "mw_save_name", "default", 8192, "Set the name of the file to save with 'mw_save'" )
--CreateConVar( "mw_save_name_custom", "default", 8192, "Set the name of the file to save with 'mw_save'" )
CreateConVar ( "mw_save_name", "default", 8192, "Set the name of the file to save with 'mw_save'" )
CreateConVar ( "mw_save_path", "default", 8192, "Set the path of the file to save with 'mw_save'" )

mw_team_colors  = {Color(255,50,50,255),Color(50,50,255,255),Color(255,200,50,255),Color(30,200,30,255),Color(255,50,255,255),Color(100,255,255,255),Color(255,120,0,255),Color(10,30,70,255)}

function AddTabs()
	spawnmenu.AddToolTab( "MelonWars", "#Unique_Name", "icon16/wrench.png" )
end
-- Hook the Tab to the Spawn Menu
hook.Add( "AddToolMenuTabs", "MelonWars", AddTabs )

mw_teamCredits = {2000,2000,2000,2000,2000,2000,2000,2000}
mw_teamUnits = {0,0,0,0,0,0,0,0}
teamUnlocks = {0,0,0,0,0,0,0,0}

teamgrid = {}

local function spawn( ply )
	ply.mw_hover = 0
	ply.mw_menu = 0
	ply.mw_selectTimer = 0
	ply.mw_spawntimer = 0
	ply.mw_frame = nil
	ply.mw_credits = 2000
	for k, v in pairs( player.GetAll() ) do
		net.Start("UpdateClientTeams")
			net.WriteTable(teamgrid)
		net.Send(ply)
	end
	util.PrecacheModel( "models/hunter/tubes/circle2x2.mdl" )
end
hook.Add( "PlayerInitialSpawn", "some_unique_name", spawn )

local function takedmg( target, dmginfo )
	if (dmginfo:GetAttacker():GetClass() ~= "player") then
		if (target.Base == "ent_melon_prop_base") then
			target:SetNWFloat( "health", target:GetNWFloat( "health", 1)-dmginfo:GetDamage())
			if (target:GetNWFloat( "health", 1) <= 0) then
				target:MW_PropDefaultDeathEffect( target )
			end
		elseif (target:GetNWInt("propHP", -1) ~= -1) then
			target:SetNWInt( "propHP", target:GetNWInt( "propHP", 1)-dmginfo:GetDamage())
			if (target:GetNWInt( "propHP", 1) <= 0) then
				local effectdata = EffectData()
				effectdata:SetOrigin( target:GetPos() )
				util.Effect( "Explosion", effectdata )
				target:Remove()
			end
		end
	end
end
hook.Add( "EntityTakeDamage", "entitytakedmg", takedmg )

net.Receive( "MW_Activate", function( len, pl )
	local ent = net.ReadEntity()
	ent:Actuate();
end)

net.Receive( "ActivateGate", function( len, pl )
	local ent = net.ReadEntity()
	ent:Actuate();
end)

net.Receive( "MW_UpdateClientInfo", function( len, pl )
	local a = net.ReadInt(8)
	if (a != 0) then
		net.Start("MW_TeamCredits")
			net.WriteInt(mw_teamCredits[a] ,16)
		net.Send(pl)
		net.Start("MW_TeamUnits")
			net.WriteInt(mw_teamUnits[a] ,16)
		net.Send(pl)
	else
		net.Start("MW_TeamCredits")
			net.WriteInt(20000 ,16)
		net.Send(pl)
		net.Start("MW_TeamUnits")
			net.WriteInt(0 ,16)
		net.Send(pl)
	end
	local color = mw_team_colors[a]
	local vector_color = Vector(color.r/255, color.g/255, color.b/255)
	pl:SetPlayerColor(vector_color)
	pl:SetWeaponColor(vector_color)
end )

net.Receive( "MW_UpdateServerInfo", function( len, pl )
	local a = net.ReadInt(8)
	mw_teamCredits[a] = net.ReadInt(16)
	--mw_teamUnits[a] = net.ReadInt(16)
end )

net.Receive( "ToggleBarracks", function( len, pl )
	local ent = net.ReadEntity()
	local on = ent:GetNWBool("active", false)
	if (on) then
		ent:SetNWBool("active", false)
	else
		ent:SetNWBool("active", true)
	end
end )

net.Receive( "PropellerReady", function( len, pl )
	local ent = net.ReadEntity()
	ent:SetNWBool("done",true)
	local foundEnts = ents.FindInSphere(ent:GetPos(), 600 )
	for k, v in pairs( foundEnts ) do
		if (v:GetClass() == "ent_melon_propeller" or v:GetClass() == "ent_melon_hover") then
			v:SetNWBool("done",true)
		end
	end
end )

net.Receive( "UseWaterTank", function( len, pl )
	local ent = net.ReadEntity()
	local _team = ent:GetNWInt("capTeam", -1)
	mw_teamCredits[_team] = mw_teamCredits[_team]+1000
	for k, v in pairs( player.GetAll() ) do
		if (v:GetInfo("mw_team") == tostring(_team)) then
			net.Start("MW_TeamCredits")
				net.WriteInt(mw_teamCredits[_team] ,16)
			net.Send(v)
			v:PrintMessage( HUD_PRINTTALK, "///// Received 1000 water" )
		end
	end

	local effectdata = EffectData()
	effectdata:SetOrigin( ent:GetPos() )
	for i=0, 10 do
		util.Effect( "balloon_pop", effectdata )
	end
	local effectdata = EffectData()
	effectdata:SetOrigin( ent:GetPos())
	effectdata:SetScale(10)
	util.Effect( "watersplash", effectdata )
	ent:Remove()
end )

net.Receive( "MW_SpawnUnit", function( len, pl )
	local class = net.ReadString()
	local unit_index = net.ReadInt(16)
	local trace = net.ReadTable()
	local cost = net.ReadInt(16)
	local spawntime = net.ReadInt(16)
	local _team = net.ReadInt(8)
	local attach = net.ReadBool()
	local angle = net.ReadAngle()
	--print("Class: "..class.." - Trace Hitpos: "..tostring(trace.HitPos).." - Cost: "..cost.." - Team: ".._team)
	if ( IsValid( trace.Entity ) and trace.Entity.Base == "ent_melon_base") then return end
	if (trace.Entity:GetClass() == "ent_melon_wall" and (attach == false and mw_units[unit_index].welded_cost ~= -1 and unit_index < 9 --[[<< first building]])) then
		pl:PrintMessage( HUD_PRINTCENTER, "Cant spawn mobile units directly on buildings" )
		return
	end
	--newMarine.population = unit_population[mw_melonTeam]
	local newMarine = SpawnUnitAtPos(class, unit_index, trace.HitPos + trace.HitNormal * 5, angle, cost, spawntime, _team, attach, trace.Entity)

	undo.Create("Melon Marine")
	 undo.AddEntity( newMarine )
	 undo.SetPlayer( pl)
	undo.Finish()
end )

function SpawnUnitAtPos (class, unit_index, pos, ang, cost, spawntime, _team, attach, parent, pl)

	local newMarine = ents.Create( class )
	if ( !IsValid( newMarine ) ) then return end -- Check whether we successfully made an entity, if not - bail

	newMarine:SetPos( pos)
	newMarine:SetAngles( ang)

	sound.Play( "garrysmod/content_downloaded.wav", pos, 60, 90, 1 )

	if (IsValid(pl)) then
		sound.Play( "garrysmod/content_downloaded.wav", pl:GetPos(), 60, 90, 1 )
	end
	mw_melonTeam = _team

	newMarine.mw_spawntime = spawntime
	newMarine:Spawn()
	newMarine:SetNWFloat("spawnTime", spawntime)

	if (unit_index == -1 or unit_index == -2) then --si es un motor o un propeller
		newMarine:GetPhysicsObject():EnableCollisions( false )
	end

	--if (attach) then
	--	newMarine:SetPos(pos + Vector(0,0,-5))
	--end

	if (attach) then
		newMarine:SetCollisionGroup( COLLISION_GROUP_DISSOLVING )
		if (tostring(parent) != "[NULL Entity]") then
			newMarine:Welded(newMarine, parent)
		else
			newMarine:SetMoveType(MOVETYPE_NONE)
			newMarine:Welded(newMarine, game.GetWorld())
		end
	end

	newMarine:Ini(_team)

	if (IsValid(pl)) then
		pl.mw_melonTeam = _team
		newMarine:SetOwner(pl)
	end

	newMarine.realvalue = cost
	if (cvars.Bool("mw_admin_credit_cost")) then
		newMarine.value = cost
	else
		newMarine.value = 0
	end

	return newMarine
end

net.Receive( "ContraptionSave", function( len, pl )
	local name = net.ReadString()
	local entity = net.ReadEntity()

	--file.CreateDir( "melonwars/contraptions" )
	if (!entity:IsWorld()) then
		local entities = constraint.GetAllConstrainedEntities( entity )
		for k, v in pairs(entities) do
			if (v:GetClass() == "prop_physics") then
				v.realvalue = math.min(1000, v:GetPhysicsObject():GetMass()*10)
				--print("setting real value to "..math.min(1000, v:GetPhysicsObject():GetMass()*10))
			end
		end

		duplicator.SetLocalPos( pl:GetEyeTrace().HitPos )
		local duptable = duplicator.Copy(entity)
		local dubJSON = util.TableToJSON(duptable)

		duplicator.SetLocalPos( Vector(0,0,0) )
		net.Start("ContraptionSaveClient")
			net.WriteString(dubJSON)
			net.WriteString(name)
		net.Send(pl)
	end
end )

net.Receive( "ContraptionLoad", function( len, pl )

	undo.Create("Melon Marine")

	local fileJSON = net.ReadString()
	local duptable = util.JSONToTable( fileJSON )
	local ent = net.ReadEntity()
	local pos
	if (ent:GetClass() == "player") then
		pos = ent:GetEyeTrace().HitPos
	else
		pos = ent:GetPos()
	end
	duplicator.SetLocalPos( pos - Vector((duptable.Maxs.x+duptable.Mins.x)/2, (duptable.Maxs.y+duptable.Mins.y)/2, duptable.Mins.z-10))
	local paste = duplicator.Paste( player.GetByID( 0 ), duptable.Entities, duptable.Constraints )
	duplicator.SetLocalPos( Vector(0,0,0) )
	local mw_melonTeam = pl:GetInfoNum("mw_team", 0)
	local massHealthMultiplier = 1
	local massCostMultiplier = 10
	for k, v in pairs(paste) do
		if (v.Base == "ent_melon_base") then
			v:Ini(mw_melonTeam)
		end
		if (v:GetClass() == "ent_melon_propeller" or v:GetClass() == "ent_melon_hover") then
			v:SetNWBool("done",true)
		end
		if (!string.StartWith( v:GetClass(), "ent_melon")) then
			v:SetColor(mw_team_colors[mw_melonTeam])
			v:SetNWInt("mw_melonTeam", mw_melonTeam)
			v:SetNWInt("propHP", math.min(1000,v:GetPhysicsObject():GetMass()*massHealthMultiplier))--max 1000 de vida
			v.realvalue = v:GetPhysicsObject():GetMass()*massCostMultiplier
			hook.Run("MelonWarsEntitySpawned", v)
		end
		if (ent:GetClass() == "player") then
			v:SetVar('targetPos', pos)
			v:SetNWVector('targetPos', pos)
		else
			v:SetVar('targetPos', ent.targetPos+Vector(0,0,1))
			v:SetNWVector('targetPos', ent.targetPos+Vector(0,0,1))
			v:SetVar('moving', true)
		end
		undo.AddEntity( v )
	end

	 undo.SetPlayer( pl)
	undo.Finish()
end )

net.Receive( "RequestContraptionLoadToAssembler", function( len, pl )
	local ent = net.ReadEntity()
	local _file = net.ReadString()
	ent.file = _file
	ent.player = pl
	ent:SetNWBool("active", true)
	ent:SetNWFloat("nextSlowThink", CurTime()+net.ReadFloat())
	
	--net.Start("ContraptionLoad")
	--	net.WriteString(_file)
	--	net.WriteVector(ent:GetPos())
	--net.SendToServer()
end )

net.Receive( "MW_SpawnProp", function( len, pl )
	local index = net.ReadInt(16)
	local trace = net.ReadTable()
	local cost = net.ReadInt(16)
	local _team = net.ReadInt(8)
	local propAngle = pl.propAngle

	local offset = Vector(0,0,mw_base_props[index].offset.z)
	if (cvars.Bool("mw_prop_offset") == true) then
		offset = mw_base_props[index].offset
	end
	local xoffset = Vector(offset.x*(math.cos(propAngle.y/180*math.pi)), offset.x*(math.sin(propAngle.y/180*math.pi)),0)
	local yoffset = Vector(offset.y*(-math.sin(propAngle.y/180*math.pi)), offset.y*(math.cos(propAngle.y/180*math.pi)),0)
	offset = xoffset+yoffset+Vector(0,0,offset.z)
	MW_SpawnProp(mw_base_props[index].model, trace.HitPos + trace.HitNormal + offset, propAngle + mw_base_props[index].angle, _team, trace.Entity, cost, pl)
end )

function MW_SpawnProp(model, pos, ang, _team, parent, cost, pl)
	local newMarine = ents.Create( "ent_melon_wall" )
	if ( !IsValid( newMarine ) ) then return end -- Check whether we successfully made an entity, if not - bail
	--if ( IsValid( trace.Entity ) and trace.Entity.Base == "ent_melon_base" ) then return end
	
	newMarine:SetPos(pos)
	newMarine:SetAngles(ang)
	newMarine:SetModel(model)
	
	sound.Play( "garrysmod/content_downloaded.wav", pos, 60, 90, 1 )

	newMarine:SetNWInt("mw_melonTeam", _team)

	newMarine:Spawn()

	if (parent != nil) then
		local weld = constraint.Weld( newMarine, parent, 0, 0, 0, true , false )
	else
		newMarine:SetMoveType(MOVETYPE_NONE)
		local weld = constraint.Weld( newMarine, game.GetWorld(), 0, 0, 0, true , false )
	end

	newMarine:SetVar("shotOffset", offset) 	--/////////////////////////////NOT WORKING

	if (IsValid(pl)) then
		sound.Play( "garrysmod/content_downloaded.wav", pl:GetPos(), 60, 90, 1 )
		pl.mw_melonTeam = _team
		newMarine:SetOwner(pl)
		undo.Create("Melon Marine")
		 undo.AddEntity( newMarine )
		 undo.SetPlayer( pl)
		undo.Finish()
	end

	newMarine.realvalue = cost
	if (cvars.Bool("mw_admin_credit_cost")) then
		newMarine.value = cost
	else
		newMarine.value = 0
	end

	local effectdata = EffectData()
	effectdata:SetEntity( newMarine )
	util.Effect( "propspawn", effectdata )

	return newMarine
end

net.Receive( "SpawnBase", function( len, pl )
	local trace = net.ReadTable()
	local _team = net.ReadInt(8)
	if ( IsValid( trace.Entity ) and trace.Entity.Base == "ent_melon_base" ) then return end
	MW_SpawnBaseAtPos(_team, trace.HitPos, pl, false)
end )

net.Receive( "SpawnBaseGrandWar", function( len, pl )
	local trace = net.ReadTable()
	local _team = net.ReadInt(8)
	if ( IsValid( trace.Entity ) and trace.Entity.Base == "ent_melon_base" ) then return end
	MW_SpawnBaseAtPos(_team, trace.HitPos, pl, true)
end )

function MW_SpawnBaseAtPos(_team, vector, pl, grandwar)

	local class = "ent_melon_main_building"
	if (grandwar) then
		class = "ent_melon_main_building_grand_war"
	end
	local newMarine = ents.Create( class )
	if ( !IsValid( newMarine ) ) then return end -- Check whether we successfully made an entity, if not - bail
	newMarine:SetPos( vector)
	
	sound.Play( "garrysmod/content_downloaded.wav", vector, 60, 90, 1 )

	mw_melonTeam = _team

	newMarine.mw_spawntime = 0

	newMarine:Spawn()
	newMarine:SetNWInt("mw_melonTeam", _team)

	newMarine:Ini(_team)

	if (IsValid(pl)) then
		sound.Play( "garrysmod/content_downloaded.wav", pl:GetPos(), 60, 90, 1 )
		undo.Create("Melon Marine")
		 undo.AddEntity( newMarine )
		 undo.SetPlayer( pl)
		undo.Finish()
	end
end

net.Receive( "SellEntity", function( len, pl )
	local entity = net.ReadEntity()
	local playerTeam = net.ReadInt(8)
	if (entity.Base == "ent_melon_base") then
		if (entity.canMove == true) then
			if (entity.gotHit or CurTime()-entity:GetCreationTime() >= 30 or entity.fired ~= false) then
				pl:PrintMessage( HUD_PRINTTALK, "///// Can't sell mobile mw_units after 30 seconds, after they got hit, or after they fired." )
				sound.Play( "buttons/button2.wav", pl:GetPos(), 75, 100, 1 )
				entity = nil
			end
		end
	end
	if (entity ~= nil) then
		if (entity:GetClass() == "ent_melon_main_building" or (entity.Base ~= "ent_melon_base" and entity.Base ~= "ent_melon_prop_base" and entity.Base ~= "ent_melon_energy_base" and entity:GetClass() ~= "prop_physics") or (entity:GetClass() == "prop_physics" and entity:GetNWInt("mw_melonTeam", -1) ~= playerTeam)) then
			pl:PrintMessage( HUD_PRINTTALK, "///// That's not a sellable entity" )
			sound.Play( "buttons/button2.wav", pl:GetPos(), 75, 100, 1 )
			entity = nil
		end
	end
	if (entity ~= nil) then
		if (entity:GetClass() == "prop_physics" or entity.gotHit or CurTime()-entity:GetCreationTime() >= 30 or (entity.Base == "ent_melon_base" and entity.fired ~= false)) then --pregunta si NO se va a recivir el dinero de refund
			mw_teamCredits[playerTeam] = mw_teamCredits[playerTeam]+entity.value*0.25
			for k, v in pairs( player.GetAll() ) do
				if (v:GetInfo("mw_team") == tostring(entity:GetNWInt("mw_melonTeam", 0))) then
					net.Start("MW_TeamCredits")
						net.WriteInt(mw_teamCredits[entity:GetNWInt("mw_melonTeam", 0)] ,16)
					net.Send(v)
					v:PrintMessage( HUD_PRINTTALK, "///// "..tostring(entity.value*0.25).." Water Recovered" )
				end
			end
		end
		sound.Play( "garrysmod/balloon_pop_cute.wav", pl:GetPos(), 75, 100, 1 )
		local vPoint = Vector( 0, 0, 0 )
		local effectdata = EffectData()
		effectdata:SetOrigin( entity:GetPos() )
		for i=0, 5 do
			util.Effect( "balloon_pop", effectdata )
		end
		entity:Remove()
	end
end )
util.AddNetworkString( "SellEntity" )

net.Receive( "LegalizeContraption", function( len, pl )
	local traceEntity = pl:GetEyeTrace().Entity
	local mw_melonTeam = net.ReadInt(8)
	
	local mass = 0 --precio por masa
	local cons = 0 --precio por construction tools

	local entities = constraint.GetAllConstrainedEntities( traceEntity )
	if (IsValid(traceEntity)) then
		for _, ent in pairs( entities ) do
			if (!freeze) then
				local c = ent:GetClass()
				if (c == "prop_physics") then
					if (ent:GetNWInt("mw_melonTeam", -1) == -1) then
						local phys = ent:GetPhysicsObject()
						if (IsValid(phys)) then
							mass = mass+math.min(1000,phys:GetMass()) --max 1000 de vida
						end
					end
				end
			end
		end
	end
	local massCostMultiplier = 10
	local massHealthMultiplier = 1
	if (mw_teamCredits[mw_melonTeam] >= mass*massCostMultiplier or not cvars.Bool("mw_admin_credit_cost")) then
		if (IsValid(traceEntity)) then
			for _, ent in pairs( entities ) do
				if (string.StartWith( ent:GetClass(), "gmod_" ) or string.StartWith( ent:GetClass(), "prop_vehicle")) then
					ent:Remove()
				else
					if (!string.StartWith( ent:GetClass(), "ent_melon")) then
						ent:SetColor(mw_team_colors[mw_melonTeam])
						ent:SetNWInt("mw_melonTeam", mw_melonTeam)
						ent:SetNWInt("propHP", math.min(1000,ent:GetPhysicsObject():GetMass()*massHealthMultiplier))--max 1000 de vida
						--ent:GetPhysicsObject():SetMaterial( "ice" )
						ent.realvalue = ent:GetPhysicsObject():GetMass()*massCostMultiplier
					end
				end
			end
			if (cvars.Bool("mw_admin_credit_cost")) then
				mw_teamCredits[mw_melonTeam] = mw_teamCredits[mw_melonTeam]-mass*massCostMultiplier
				net.Start("MW_TeamCredits")
					net.WriteInt(mw_teamCredits[mw_melonTeam] ,16)
				net.Send(pl)
			end
		end
	end
end )
util.AddNetworkString( "LegalizeContraption" )

concommand.Add( "mw_reset_credits", function( ply )
	if (ply:IsAdmin()) then
		local c = cvars.Number("mw_admin_starting_credits")
		mw_teamCredits = {c,c,c,c,c,c,c,c}
		for k, v in pairs( player.GetAll() ) do
			net.Start("MW_TeamCredits")
				net.WriteInt(c ,16)
			net.Send(v)
		end
	end

	local AI = ents.FindByClass( "ent_melon_singleplayer_AI" )
	if (IsValid(AI[1])) then
		AI[1]:CheaterAlert()
	end
end)

concommand.Add( "mw_singleplayer_waypoints_reposition", function( ply )
	local nodes = ents.FindByClass( "ent_melon_singleplayer_waypoint" )
	for k, v in pairs( nodes ) do
		v:SetPos(v.pos-Vector(0,0,10))
		v.time = 0
		v.pos = v:GetPos()
	end
end)

concommand.Add( "mw_singleplayer_waypoints_increment", function( ply )
	local nodes = ents.FindByClass( "ent_melon_singleplayer_waypoint" )
	for k, v in pairs( nodes ) do
		v.waypoint = v.waypoint+1
		v:SetNWInt("waypoint", v.waypoint)
	end
end)

concommand.Add( "mw_singleplayer_waypoints_decrement", function( ply )
	local nodes = ents.FindByClass( "ent_melon_singleplayer_waypoint" )
	for k, v in pairs( nodes ) do
		v.waypoint = v.waypoint-1
		v:SetNWInt("waypoint", v.waypoint)
	end
end)

concommand.Add( "mw_reset_power", function( ply )
	if (ply:IsAdmin()) then
		mw_teamUnits = {0,0,0,0,0,0,0,0}
		--local allMelons = ents.GetAll()
		--for k, v in pairs(allMelons) do
	--	
	--		if (v.Base == "ent_melon_base") then
	--			prnt(v:GetVar("mw_melonTeam"))
	--			--mw_teamUnits[v:GetVar("mw_melonTeam")] = mw_teamUnits[v:GetVar("mw_melonTeam")]
	--		end
	--	end
		
		for k, v in pairs( player.GetAll() ) do
			local mw_melonTeam = v:GetInfoNum("mw_team", 0)
			net.Start("MW_TeamUnits")
				net.WriteInt(mw_teamUnits[mw_melonTeam] ,16)
			net.Send(v)
		end

		--[[
		local AI = ents.FindByClass( "ent_melon_singleplayer_AI" )
		if (IsValid(AI[1])) then
			AI[1]:CheaterAlert()
		end
		]]
	end
end)

concommand.Add( "+mw_select", function( ply )
	ply.mw_selecting = true
	local trace = util.TraceLine( {
		start = ply:EyePos(),
		endpos = ply:EyePos() + ply:EyeAngles():Forward() * 10000,
		filter = function( ent ) if ( ent:GetClass() != "player" ) then return true end end,
		mask = MASK_WATER+MASK_SOLID
	} )
	--print(trace.Entity)
	ply.mw_selStart = trace.HitPos
	ply:SetNWVector("mw_selStart", ply.mw_selStart)
	ply:SetNWBool("mw_selecting", ply.mw_selecting)
	sound.Play( "buttons/lightswitch2.wav", ply:GetPos(), 75, 100, 1 )
end)


local function StartGame( len, pl )
	for k, v in pairs( player.GetAll() ) do
		net.Start("RestartQueue")
		net.Send(v)
		sound.Play( "garrysmod/content_downloaded.wav", v:GetPos()+Vector(0,0,45), 100, 40, 1)
		v:PrintMessage( HUD_PRINTCENTER, "The MelonWars match has begun!" )
		v:PrintMessage( HUD_PRINTTALK, "/////////////////////////////// The MelonWars match has begun!" )
	end
end
net.Receive( "StartGame", StartGame)

local function SandboxMode( len, pl )
	for k, v in pairs( player.GetAll() ) do
		sound.Play( "garrysmod/save_load1.wav", v:GetPos()+Vector(0,0,45), 100, 150, 1)
		v:PrintMessage( HUD_PRINTTALK, "////////// MelonWars options set to Sandbox" )
	end
end
net.Receive( "SandboxMode", SandboxMode)

util.AddNetworkString( "Selection" )
concommand.Add( "-mw_select", function( ply )
	ply.mw_selecting = false
	ply:SetNWBool("mw_selecting", ply.mw_selecting)

	--Encuentra todas las entidades en la esfera de selección

	local foundEnts = ents.FindInSphere((ply.mw_selEnd+ply.mw_selStart)/2, ply.mw_selStart:Distance(ply.mw_selEnd)/2+0.1 )
	local selectEnts = table.Copy( foundEnts )
	if (!ply:KeyDown(IN_SPEED)) then ply.foundMelons = {} end
	--Busca de esas entidades cuales son sandias, y cuales son del equipo correcto

	--print("////////")
	--print("Building foundEnts")
	for k, v in pairs( selectEnts ) do
		if (v.moveType != MOVETYPE_NONE) then
			local tbl = constraint.GetAllConstrainedEntities( v )
			if (istable(tbl)) then
				for kk, vv in pairs (tbl) do
					if (!table.HasValue(selectEnts, vv)) then
						table.insert(foundEnts, vv)
						--print("Added "..tostring(vv))
					else
						--print("Discarded "..tostring(vv))
					end
				end
			end
		end
	end
	--PrintTable(foundEnts)

	--print("Building foundMelons")
	for k, v in pairs( foundEnts ) do
		if (v.Base == "ent_melon_base") then
			if (cvars.Bool("mw_admin_move_any_team", false) or v:GetNWInt("mw_melonTeam", -1) == ply:GetInfoNum( "mw_team", -1 )) then
				--if (v:GetNWInt("mw_melonTeam", 0) != 0) then
					table.insert(ply.foundMelons, v)
					--print("Added "..tostring(v).." succesfully")
				--else
				--	print("Didn't add "..tostring(v).." because it had no team")
				--end
			--else
			--	print("Didn't add "..tostring(v).." because it wasn't my team")
			end
		--else
		--	print("Didn't add "..tostring(v).." because it was a base prop")
		end
	end
	--PrintTable(ply.foundMelons)
	--Le envia al client la lista de sandias para que pueda dibujar los halos
	net.Start("Selection")
		net.WriteInt(table.Count(ply.foundMelons),16)
		for k,v in pairs(ply.foundMelons) do
			net.WriteEntity(v)
		end
	net.Send(ply)
	sound.Play( "buttons/lightswitch2.wav", ply:GetPos(), 75, 90, 1 )
	ply.mw_selEnd = Vector(0,0,0)
	ply.mw_selStart = Vector(0,0,0)
	ply:SetNWVector("mw_selStart", Vector(0,0,0))
	ply:SetNWBool("mw_selecting",  Vector(0,0,0))
end)

concommand.Add( "mw_typeselect", function( ply, cmd, args )
	if (args[1]) then
		ply.mw_selecting = false
		ply:SetNWBool("mw_selecting", false)

		--Encuentra todas las entidades en la esfera de selección
		print("Attempting type select with class "..args[1])
		
		local foundEnts = ents.FindInSphere(ply:GetEyeTrace().HitPos, 300)
		if (!ply:KeyDown(IN_SPEED)) then ply.foundMelons = {} end
		--Busca de esas entidades cuales son sandias, y cuales son del equipo correcto
		for k, v in pairs( foundEnts ) do
			if (v.Base == "ent_melon_base") then
				if (v:GetClass() == args[1]) then
					if (cvars.Bool("mw_admin_move_any_team", false) or v:GetNWInt("mw_melonTeam", 0) == ply:GetInfoNum( "mw_team", 0 )) then
						if (v:GetVar("canBeSelected") == true) then
							table.insert(ply.foundMelons, v)
						end
					end
				end
			end
		end
		--Le envia al client la lista de sandias para que pueda dibujar los halos
		net.Start("Selection")
			net.WriteInt(table.Count(ply.foundMelons),16)
			for k,v in pairs(ply.foundMelons) do
				net.WriteEntity(v)
			end
		net.Send(ply)
		sound.Play( "buttons/lightswitch2.wav", ply:GetPos(), 75, 90, 1 )
		ply.mw_selEnd = Vector(0,0,0)
		ply.mw_selStart = Vector(0,0,0)
		ply:SetNWVector("mw_selStart", Vector(0,0,0))
		ply:SetNWBool("mw_selecting",  Vector(0,0,0))
	end
end)

concommand.Add( "mw_stop", function( ply )
	local stopedMelons = false
	if (ply.foundMelons ~= nil) then
		for k, v in pairs( ply.foundMelons ) do
			if (!IsValid(v)) then
				--Si murió, lo saco de la tabla
				table.remove(ply.foundMelons, k)
			else
				if (v.Base == "ent_melon_base") then
					--si sigue vivo, le doy la order
					--si no, mueve
					v:SetVar("targetPos", v:GetPos())
					v:SetNWVector("targetPos", v:GetPos())
					v:SetVar("moving", false)
					v:SetVar("chasing", false)
					v:SetVar("followEntity", v)
					v:SetNWEntity("followEntity", v)
					for i=1, 30 do
						v.rallyPoints[i] = Vector(0,0,0)
					end
					stopedMelons = true
				end
			end
		end
	end
		
	if (stopedMelons) then
		sound.Play( "buttons/button16.wav", ply:GetPos(), 75, 100, 1 )
	end
end)

concommand.Add( "mw_order", function( ply )
	local trace = util.TraceLine( {
		start = ply:EyePos(),
		endpos = ply:EyePos() + ply:EyeAngles():Forward() * 10000,
		filter = function( ent ) if ( ent:GetClass() != "player" ) then return true end end,
		mask = MASK_WATER+MASK_SOLID
	} )
	
	if (ply.foundMelons ~= nil) then
		for k, v in pairs( ply.foundMelons ) do
			if (!IsValid(v) or not string.StartWith(v:GetClass(), "ent_melon_")) then
				--Si murió, lo saco de la tabla
				table.remove(ply.foundMelons, k)
			end
		end

		if (ply:KeyDown(IN_SPEED)) then
			for k, v in pairs( ply.foundMelons ) do
				local i = 30
				while i >= 0 do
					if (i == 0) then
						v.rallyPoints[1] = trace.HitPos
						v.moving = true
						movedMelons = true
						i = -1
					elseif (v.rallyPoints[i] ~= Vector(0,0,0)) then
						if (i < 30) then
							if (v.rallyPoints[i+1] == Vector(0,0,0)) then
								v.rallyPoints[i+1] = trace.HitPos
								movedMelons = true
								i = -1
							end
						end
					end
					i = i-1
				end
			end
		elseif (ply:KeyDown(IN_WALK)) then
			for k, v in pairs( ply.foundMelons ) do
				if (IsValid(v) and string.StartWith(v:GetClass(), "ent_melon_")) then
					--si tenia apretado alt, dispara
					if (tostring(trace.Entity) == "Entity [0][worldspawn]") then
						--si se le apuntó al mundo, sacar objetivo
						v:SetVar("forcedTargetEntity", v)
						v:SetVar("targetEntity", v)
						v:SetVar("followEntity", v)
						v:SetNWEntity("followEntity", v)
						v:SetNWEntity("targetEntity", v)
						v:SetVar("chasing", false)
					else
						if (v:GetNWInt("mw_melonTeam", 0) == trace.Entity:GetNWInt("mw_melonTeam", 0)) then
							--si se le apuntó a algo, darle eso como objetivo
							v:SetVar("followEntity", trace.Entity)
							v:SetNWEntity("followEntity", trace.Entity)
							v:SetVar("forcedTargetEntity", v)
							v:SetVar("targetEntity", v)
							v:SetNWEntity("targetEntity", v)
							v:SetVar("chasing", false)
						else
							v:SetVar("followEntity", v)
							v:SetNWEntity("followEntity", v)
							v:SetVar("forcedTargetEntity", trace.Entity)
							v:SetVar("targetEntity", trace.Entity)
							v:SetNWEntity("targetEntity", trace.Entity)
							v:SetVar("chasing", true)
						end
					end
					movedMelons = true
				end
			end
		elseif (ply:KeyDown(IN_DUCK)) then
			local center = Vector(0,0,0)
			local i = 0
			for k, v in pairs( ply.foundMelons ) do
				if (IsValid(v) and string.StartWith(v:GetClass(), "ent_melon_")) then
					center = center+v:GetPos()
					i = i+1
				end
			end
			center = center/i
			local distance = 50
			for k, v in pairs( ply.foundMelons ) do
				if (IsValid(v) and string.StartWith(v:GetClass(), "ent_melon_")) then
					--local clampedMagnitude = math.max(100,math.min(500,(v:GetPos()-center):Length()))
					distance = distance + 25/(1+distance*0.1)
					local newTarget = v:GetPos()+(v:GetPos()-center):GetNormalized()*distance
					v:RemoveRallyPoints()
					v:SetVar("targetPos", newTarget)
					v:SetNWVector("targetPos", newTarget)
					v:SetVar("moving", true)
					v:SetVar("chasing", false)
					v:SetVar("followEntity", v)
					v:SetNWEntity("followEntity", v)
					movedMelons = true
				end
			end
		else
			for k, v in pairs( ply.foundMelons ) do
				--si no, mueve
				if (IsValid(v) and string.StartWith(v:GetClass(), "ent_melon_")) then
					v:RemoveRallyPoints()
					v:SetVar("targetPos", trace.HitPos)
					v:SetNWVector("targetPos", trace.HitPos)
					v:SetVar("moving", true)
					v:SetVar("chasing", false)
					v:SetVar("followEntity", v)
					v:SetNWEntity("followEntity", v)
					movedMelons = true
				end
			end
		end
	end


	--[[
	local movedMelons = false
	if (ply.foundMelons ~= nil) then
		for k, v in pairs( ply.foundMelons ) do
			if (v.Base == "ent_melon_base") then
				if (!IsValid(v)) then
					--Si murió, lo saco de la tabla
					table.remove(ply.foundMelons, k)
				else
					--si sigue vivo, le doy la order
					if (ply:KeyDown(IN_SPEED)) then
						local i = 30
						while i >= 0 do
							if (i == 0) then
								v.rallyPoints[1] = trace.HitPos
								v.moving = true
								movedMelons = true
								i = -1
							elseif (v.rallyPoints[i] ~= Vector(0,0,0)) then
								if (i < 30) then
									if (v.rallyPoints[i+1] == Vector(0,0,0)) then
										v.rallyPoints[i+1] = trace.HitPos
										movedMelons = true
										i = -1
									end
								end
							end
							i = i-1
						end
					elseif (ply:KeyDown(IN_WALK)) then
						--si tenia apretado alt, dispara
						if (tostring(trace.Entity) == "Entity [0][worldspawn]") then
							--si se le apuntó al mundo, sacar objetivo
							v:SetVar("forcedTargetEntity", v)
							v:SetVar("targetEntity", v)
							v:SetVar("followEntity", v)
							v:SetNWEntity("followEntity", v)
							v:SetNWEntity("targetEntity", v)
							v:SetVar("chasing", false)
						else
							if (v:GetNWInt("mw_melonTeam", 0) == trace.Entity:GetNWInt("mw_melonTeam", 0)) then
								--si se le apuntó a algo, darle eso como objetivo
								v:SetVar("followEntity", trace.Entity)
								v:SetNWEntity("followEntity", trace.Entity)
								v:SetVar("forcedTargetEntity", v)
								v:SetVar("targetEntity", v)
								v:SetNWEntity("targetEntity", v)
								v:SetVar("chasing", false)
							else
								v:SetVar("followEntity", v)
								v:SetNWEntity("followEntity", v)
								v:SetVar("forcedTargetEntity", trace.Entity)
								v:SetVar("targetEntity", trace.Entity)
								v:SetNWEntity("targetEntity", trace.Entity)
								v:SetVar("chasing", true)
							end
						end
						movedMelons = true
					elseif (if (ply:KeyDown(IN_DUCK)) then)

					else
						--si no, mueve
						v:RemoveRallyPoints()
						v:SetVar("targetPos", trace.HitPos)
						v:SetNWVector("targetPos", trace.HitPos)
						v:SetVar("moving", true)
						v:SetVar("chasing", false)
						v:SetVar("followEntity", v)
						v:SetNWEntity("followEntity", v)
						movedMelons = true
					end
				end
			end
		end
	end
	]]
		
	if (movedMelons) then
		sound.Play( "garrysmod/ui_click.wav", ply:GetPos(), 75, 100, 1 )
	else
		sound.Play( "common/wpn_denyselect.wav", ply:GetPos(), 75, 100, 1 )
	end
end)

concommand.Add( "mw_save", function( ply )
	local allents = ents.GetAll()
	for k, v in pairs( allents ) do
		if (v:GetClass() == "ent_melon_main_building") then
			-- Si es una cierra, spawnear base
			local newMarker = ents.Create("ent_melonmarker_base")
			newMarker:SetPos(v:GetPos())
			newMarker:Spawn()
			newMarker:SetMelonTeam(v:GetNWInt("mw_melonTeam", 0))
			v:Remove()
		elseif (v:GetClass() == "ent_melon_wall") then
			local newMarker = ents.Create("ent_melonmarker_base_prop")
			newMarker:SetPos(v:GetPos())
			newMarker:SetAngles(v:GetAngles())
			newMarker:Spawn()
			newMarker:SetMelonTeam(v:GetNWInt("mw_melonTeam", 0), v:GetModel(), v.melonParent)
			v:Remove()
		elseif (v.Base == "ent_melon_base") then
			local newMarker = ents.Create("ent_melonmarker_unit")
			newMarker:SetPos(v:GetPos())
			newMarker:Spawn()
			newMarker:SetMelonTeam(v:GetNWInt("mw_melonTeam", 0), v:GetClass(), v:GetCollisionGroup() == COLLISION_GROUP_DISSOLVING)
			v:Remove()
		end
	end

	file.CreateDir( "melonwars" )
	file.Write( GetConVarString( "mw_save_name" )..".txt", gmsave.SaveMap( ply ))
	print("Stage saved to '"..GetConVarString( "mw_save_name" )..".txt'. Remember to move it into your Campaign's folder.")
end)

concommand.Add( "mw_load", function( ply )
	--gmsave.LoadMap(  , "DATA") , ply )

	local tab
	--"data/melonwars_save_"
	if (file.Exists(/*GetConVarString( "mw_save_path" ).."melonwars_save_"..*/GetConVarString( "mw_save_name" )..".lua", "LUA")) then
		//print("Finding file "..GetConVarString( "mw_save_path" ).."melonwars_save_"..GetConVarString( "mw_save_name" )..".lua")
		tab = util.JSONToTable( file.Read( /*GetConVarString( "mw_save_path" ).."melonwars_save_"..*/GetConVarString( "mw_save_name" )..".lua", "LUA"))
	elseif (file.Exists(/*GetConVarString( "mw_save_path" ).."melonwars_save_"..*/GetConVarString( "mw_save_name" ), "DATA")) then
		--"melonwars/<campaign>"
		//print(GetConVarString( "mw_save_path" ).."melonwars_save_"..GetConVarString( "mw_save_name" )..".txt")
		tab = util.JSONToTable( file.Read( /*GetConVarString( "mw_save_path" ).."melonwars_save_"..*/GetConVarString( "mw_save_name" ), "DATA"))
	else
		print("File "..GetConVarString( "mw_save_name" ).." not found in addon folder")
		return false
	end
	game.CleanUpMap()
	DisablePropCreateEffect = true
	duplicator.RemoveMapCreatedEntities()
	duplicator.Paste( ply, tab.Entities, tab.Constraints )
	mw_teamUnits = {0,0,0,0,0,0,0,0}
	for k, v in pairs( player.GetAll() ) do
		local mw_melonTeam = v:GetInfoNum("mw_team", 0)
		if (mw_melonTeam != 0) then
			net.Start("MW_TeamUnits")
				net.WriteInt(mw_teamUnits[mw_melonTeam] ,16)
			net.Send(v)
		end
	end
	if ( IsValid( ply ) ) then
		gmsave.PlayerLoad( ply, tab.Player )
	end

	local allents = ents.GetAll()
	for k, v in pairs( allents ) do
		if (v.Base == "ent_melon_base" or v:GetClass() == "ent_melon_wall") then
			v:Remove() -- Si quedó alguna entidad melon guardada la borra
		elseif (v:GetClass() == "ent_melonmarker_base") then
			MW_SpawnBaseAtPos(v.mw_melonTeam, v:GetPos())
			v:Remove()
		elseif (v:GetClass() == "ent_melonmarker_base_prop") then
			MW_SpawnProp(v.melonModel, v:GetPos(), v:GetAngles(), v.mw_melonTeam, nil, 0)
			v:Remove()
		elseif (v:GetClass() == "ent_melonmarker_unit") then
			if (!v.attach) then
				SpawnUnitAtPos(v.melonClass, 0, v:GetPos(), v:GetAngles(), 0, 0, v.mw_melonTeam, v.attach)
			else
				SpawnUnitAtPos(v.melonClass, 0, v:GetPos(), v:GetAngles(), 0, 0, v.mw_melonTeam, v.attach, v:GetParent())
			end
			v:Remove()
		elseif (v:GetClass() == "ent_melon_cap_point") then
			v:SetPos(v:GetPos()-Vector(0,0,70))
			v:Initialize()
		elseif (v:GetClass() == "ent_melon_outpost_point") then
			v:SetPos(v:GetPos()-Vector(0,0,162.5))
			v:Initialize()
		elseif (v:GetClass() == "ent_melon_mcguffin") then
			v:SetPos(v:GetPos()-Vector(0,0,100))
			v:Initialize()
		elseif (v:GetClass() == "ent_melon_water_tank") then
			v:SetPos(v:GetPos()-Vector(0,0,50))
			v:Initialize()
		elseif (v:GetClass() == "ent_melon_singleplayer_waypoint") then
			v:FindNext()
		end
	end
end)

concommand.Add( "mw_waypoints", function( ply )
	for k, v in pairs( ents.FindByClass( "ent_melon_singleplayer_waypoint" ) ) do
		v:FindNext()
	end
end)

concommand.Add( "mw_singleplayer_waypoints_visible", function( ply )
	for k, v in pairs( ents.FindByClass( "ent_melon_singleplayer_waypoint" ) ) do
		v:MakeWaypointVisible()
	end
end)


concommand.Add( "mw_admin_reset_teams", function( ply )
	for i=1,8 do
      teamgrid[i] = {}     -- create a new row
      for j=1,8 do
        teamgrid[i][j] = false
      end
    end
end)

hook.Add( "InitPostEntity", "start", function()	
	mw_save_name_custom = "melonwars_default_save"
	teamgrid = {}          -- create the matrix
    for i=1,8 do
      teamgrid[i] = {}     -- create a new row
      for j=1,8 do
        teamgrid[i][j] = false
      end
    end
	local tbl = player.GetAll()
	for k, v in pairs( tbl ) do
		v:PrintMessage( HUD_PRINTTALK, "____________________________________________________" )
		v:PrintMessage( HUD_PRINTTALK, "Melon Wars: RTS is running in this server." )
		v:PrintMessage( HUD_PRINTTALK, "Thanks for playing!" )
		v:PrintMessage( HUD_PRINTTALK, "____________________________________________________" )
	end
	print("=========================================================================================")
	print("Melon Wars: RTS is running in this server.")
	print("Thanks for using Melon Wars! Enjoy!")
	print("=========================================================================================")
end)

hook.Add( "Think", "update", function()	
	local tbl = player.GetAll()
	for k, v in pairs( tbl ) do
		if (v.mw_selecting) then
			local trace = util.TraceLine( {
				start = v:EyePos(),
				endpos = v:EyePos() + v:EyeAngles():Forward() * 10000,
				filter = function( ent ) if ( ent:GetClass() != "player" ) then return true end end,
				mask = MASK_WATER+MASK_SOLID
			} )
			v.mw_selEnd = trace.HitPos
			v:SetNWVector("mw_selEnd", v.mw_selEnd)
		end
	end
end)

net.Receive( "UpdateServerTeams", function( len, pl )
	--if (ply:IsAdmin()) then
		teamgrid = net.ReadTable()
		for k, v in pairs( player.GetAll() ) do
			net.Start("UpdateClientTeams")
				net.WriteTable(teamgrid)
			net.Send(v)
		end
	--end
end)

net.Receive( "RequestServerTeams", function( len, pl )
	net.Start("UpdateClientTeams")
		net.WriteTable(teamgrid)
	net.Send(pl)
end)

net.Receive( "ServerSetTeam", function( len, pl )
	local ent = net.ReadEntity()
	ent.mw_melonTeam = net.ReadInt(4)
	local color = mw_team_colors[i]
	ply:SetPlayerColor( Vector( color.r / 255, color.g / 255, color.b / 255 ) )
end)

net.Receive( "ServerSetWaypoint", function( len, pl )
	local ent = net.ReadEntity()
	ent.waypoint = net.ReadInt(8)
	ent.path = net.ReadInt(8)
	ent:SetNWInt("waypoint", ent.waypoint)
	ent:SetNWInt("path", ent.path)
end)

hook.Add("PlayerSay", "MelonPlayerSay", function(player, text, team)
	if (text:lower() == "!start") then
		StartGame()
	elseif (text:lower() == "!stop") then
		SandboxMode()
	end
end)

--hook.Add("PlayerSpawnProp", "MelonPlayerSpawnProp", function(player, model)

--end)

hook.Add("PlayerSpawnedProp", "MelonPlayerSpawnedProp", function(player, model, entity)
	entity.melon_playerName = player:Name()
	print(entity.melon_playerName)
end)
