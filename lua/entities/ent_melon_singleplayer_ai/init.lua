AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

mw_team_colors  = {Color(255,50,50,255),Color(50,50,255,255),Color(255,200,50,255),Color(30,200,30,255),Color(255,50,255,255),Color(100,255,255,255),Color(255,120,0,255),Color(10,30,70,255)}

teamgrid = {
	{false,false,false,false,false,false,false,false},
	{false,false,false,false,false,false,false,false},
	{false,false,false,false,false,false,false,false},
	{false,false,false,false,false,false,false,false},
	{false,false,false,false,false,false,false,false},
	{false,false,false,false,false,false,false,false},
	{false,false,false,false,false,false,false,false},
	{false,false,false,false,false,false,false,false}
}

local lastunit = nil

function ENT:Initialize()
	
	self:StandardRules()
	
	self:SetUseType( SIMPLE_USE )

	self.slowThinkTimer = 2
	self.checkVictoryTimer = CurTime()+2
	self.won = false

	self.mw_melonTeam = 0
	
	self.nextSlowThink = 0
	self:SetModel( "models/props_combine/combinethumper002.mdl" )
	
	self:SetAngles(Angle(0,0,0))
	
	self:SetMaterial("models/shiny")
	
	self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self:SetMoveType( MOVETYPE_NONE )
	local weld = constraint.Weld( self, game.GetWorld(), 0, 0, 0, true , false )

	--self:FindNeighbours()

	self:SetColor(Color(50,50,50,255))

	local z = nil
	self.paths = {z,z,z,z,z,z,z,z,z,z}
	self.path = 1
	self.pathcount = 1
	--self:SetRallyPoints ()

	self.orders = {};
	self.done = false;
	self.nextOrder = CurTime()+0.1;
	self.order = 1;
	self.orderAmmount = 0;
	self.spawnClass = "";
	self.spawnNumber = 0;

	self.stage = 2;
	self.started = false;

	self.cheater = false;

	self.lastOrder = 0;

	self.checkingdefeat = false;
end

function ENT:Think()

	--[[if (CurTime() > self.nextSlowThink) then
		self.nextSlowThink = CurTime()+self.slowThinkTimer
		self:SpawnUnit( "ent_melon_marine" )
	end]]

	if (!self.started) then
		self.nextOrder = CurTime()+0.1;
		if (cvars.Bool("mw_admin_playing")) then
			self:Stage(self.stage)
			self.started = true;
		end
	elseif (cvars.Bool("mw_admin_playing") ) then
		--self:CheckRules()
		if (!self.won) then
			if (self.checkVictoryTimer < CurTime()) then
				if (self:CheckVictory()) then
					self.won = true
					while (self.order <= self.orderAmmount and !string.StartWith(self.orders[self.order], "defeat")) do
						self.order = self.order+1
					end
					self.order = self.order+1
					self.nextOrder = CurTime()
					self.spawnNumber = 0
				else
					self.checkVictoryTimer = CurTime()+2
				end
			end
		end
		local passes = 0
		while (self.nextOrder <= CurTime() and passes < 50) do
			passes = passes+1
			self.lastOrder = self.nextOrder
			if (self.checkingdefeat) then
				if (self:CheckDefeat()) then
					self.checkingdefeat = false
				else
					self.nextOrder = CurTime()+3
				end
			elseif (self.spawnNumber > 0) then
				self:SpawnUnit(self.spawnClass, self.path)
				self.nextOrder = CurTime()+0.1
				self.spawnNumber = self.spawnNumber-1
			elseif (self.order <= self.orderAmmount) then
				self:ReadWord(self.orders[self.order])
				self.order = self.order+1
			end
		end
	end
end

function ENT:CheckDefeat()
	local allents = ents.GetAll()

	for k, v in pairs (allents) do
		if (v.Base == "ent_melon_base") then
			if (v:GetNWInt("mw_melonTeam", -1) == 0) then
				return false
			end
		end
	end
	return true
end

function ENT:CheckVictory()
	local allents = ents.FindByClass( "ent_melon_main_building" )
	return table.Count(allents) == 0
end

function ENT:FindNeighbours()

	self.pathcount = 0
	for k, v in pairs( ents.FindByClass( "ent_melon_singleplayer_waypoint" ) ) do
		if (v.waypoint == 1) then
			self.paths[v.path] = v
			print("Path "..tostring(v.path).." set to "..tostring(v))
			self.pathcount = self.pathcount + 1
		end
	end
end

function ENT:SpawnUnit(unit_class, path)
	local newMarine = ents.Create( unit_class )
	local spawnpos = nil
	if (IsValid(self.paths[path])) then
		spawnpos = self.paths[path]:GetPos()
	else
		print("There are no waypoints with path "..path)
		return
	end
	local offset = Vector(0,0,30)

	--[[if (IsValid(self.paths[path])) then
				offset = (self.paths[path].pos-self:GetPos()):GetNormalized()*80
			end]]

	if ( !IsValid( newMarine ) ) then return end -- Check whether we successfully made an entity, if not - bail
	newMarine:SetPos( spawnpos + offset + Vector(math.random(-10,10),math.random(-10,10),0))
	
	sound.Play( "ambient/misc/hammer1.wav", spawnpos, 75, 100, 1 )
	
	mw_melonTeam = self:GetNWInt("mw_melonTeam", 0)
	newMarine.population = 0
	newMarine:Spawn()
	newMarine:SetNWInt("mw_melonTeam", self:GetNWInt("mw_melonTeam", 0))
	//newMarine:SetColor(Color(70,70,70,255))
	newMarine.defensiveStance = true

	if (unit_class == "ent_melon_medic" and lastunit != nil) then
		newMarine:SetVar("followEntity", lastunit)
		newMarine:SetNWEntity("followEntity", lastunit)
		newMarine:SetVar("forcedTargetEntity", newMarine)
		newMarine:SetVar("targetEntity", newMarine)
		newMarine:SetNWEntity("targetEntity", newMarine)
		newMarine:SetVar("chasing", true)
	else
		lastunit = newMarine
		local i = 1
		local node = self.paths[path]
		if (node != nil) then
			while (IsValid(node) && i < 100) do
				newMarine.rallyPoints[i] = node:GetPos()
				node = node:GetNWEntity("nearestPoint", nil)
				i = i+1
			end
			if (i == 100) then
				print("EMERGENCY EXIT")
			end
		end
	end

	--[[
	if (ent.targetPos == ent:GetPos()) then
		newMarine:SetVar('targetPos', ent:GetPos()+Vector(100,0,0))
		newMarine:SetNWVector('targetPos', ent:GetPos()+Vector(100,0,0))
	else
		newMarine:SetVar('targetPos', ent.targetPos+Vector(0,0,1))
		newMarine:SetNWVector('targetPos', ent.targetPos+Vector(0,0,1))
	end
	newMarine:SetVar('moving', true)
	]]
end


function ENT:StandardRules()
	--GetConVar( "mw_admin_playing" ):SetBool( true )
	--GetConVar( "mw_admin_cutscene" ):SetBool( true )
	GetConVar( "mw_admin_move_any_team" ):SetBool( false )
	GetConVar( "mw_admin_credit_cost" ):SetBool( true )
	GetConVar( "mw_admin_allow_free_placing" ):SetBool( false )
	GetConVar( "mw_admin_spawn_time" ):SetBool( true )
	GetConVar( "mw_admin_allow_manual_placing" ):SetBool( true )
	GetConVar( "mw_admin_max_units" ):SetInt(100)
	concommand.Run( player.GetAll()[1], "mw_reset_credits" )

	for i=1,8 do
      teamgrid[i] = {}     -- create a new row
      for j=1,8 do
        teamgrid[i][j] = false
      end
    end
	self:UpdateTeams()
end

function ENT:CheaterAlert()
	--[[
	if (self.done) then
		if (!self.cheater) then
			self.cheater = true
			self.nextOrder = CurTime()+0.1;
			self.order = 1;
			if (math.random( 1, 100 ) == 1) then
			self.orders = string.Explode("\n",[[
say Wait...-Are-you-trying-to-cheat?
wait 3
say Really?-What-a-shame.
wait 3
say I-thought-this-gamemode-could-be-fun
wait 3
say But-if-you-must-cheat-to-have-fun,-then-i-guess-there's-no-point-anymore.
wait 5
say Welp,-im-gonna-go-get-some-pizza.-Summon-me-again-when-you-are-ready-to-play-for-real.
wait 5
say See-yah.
wait 1
say *Leaves*
wait 1
say (You-dirty-cheater)
wait 2
cheateralert
]]--[[)
		else
			self.orders = string.Explode("\n",[[
say Wait...-Are-you-trying-to-cheat?
wait 3
say Really?-What-a-shame.
wait 3
say Well,-call-me-when-you-want-to-play-for-real.
wait 3
say *Leaves*
wait 1
disappear
]]--[[)
		end
			self.orderAmmount = table.Count(self.orders)-1
		end
	else
		self.done = true
	end
	]]
end

function ENT:CheckRules()
	--[[if (!self.cheater) then
		if (cvars.Number("mw_admin_max_units") != 100 || GetConVar( "mw_admin_move_any_team" ):GetBool() ||!GetConVar( "mw_admin_credit_cost" ):GetBool() ||GetConVar( "mw_admin_allow_free_placing" ):GetBool() ||!GetConVar( "mw_admin_spawn_time" ):GetBool() ||!GetConVar( "mw_admin_allow_manual_placing" ):GetBool()) then
			self:CheaterAlert()
		end
	end]]
end

function ENT:Stage (stage)
	for k, v in pairs( ents.FindByClass( "ent_melon_singleplayer_waypoint" ) ) do
		v:FindNext()
	end
	self:FindNeighbours()
	self:StandardRules()
	self.path = math.random(1, self.pathcount)
	local stagestring
	if (file.Exists(GetConVarString( "mw_save_path" ).."melonwars_stage_"..GetConVarString( "mw_save_name" )..".lua", "LUA")) then
		print("Finding file "..GetConVarString( "mw_save_path" ).."melonwars_stage_"..GetConVarString( "mw_save_name" )..".lua in the LUA folder.")
		stagestring = file.Read( GetConVarString( "mw_save_path" ).."melonwars_stage_"..GetConVarString( "mw_save_name" )..".lua", "LUA")
	elseif (file.Exists(GetConVarString( "mw_save_path" ).."melonwars_stage_"..GetConVarString( "mw_save_name" )..".txt", "DATA")) then
		--"melonwars/<campaign>"
		print("Finding file "..GetConVarString( "mw_save_path" ).."melonwars_stage_"..GetConVarString( "mw_save_name" )..".txt in the DATA folder.")
		stagestring = file.Read( GetConVarString( "mw_save_path" ).."melonwars_stage_"..GetConVarString( "mw_save_name" )..".txt", "DATA")
	else
		print("File "..GetConVarString( "mw_save_name" ).." not found in addon folder, and file melonwars_stage_"..GetConVarString( "mw_save_name" ).." not found in folder "..GetConVarString( "mw_save_path" ))
		return false
	end
	self.orders = string.Explode("\n",stagestring)
	self.orderAmmount = table.Count(self.orders)
end

function ENT:ReadWord(word)
	local exp = string.Explode(" ", word)
	self:ReplaceVariables(exp)
	if (exp[1] == "wait") then
		self.nextOrder = util.StringToType(exp[2], "float")+CurTime()
		lastunit = nil
	elseif (exp[1] == "say") then
		local text = table.concat( exp, " ", 2)
		for k, v in pairs( player.GetAll() ) do
			net.Start("ChatTimer")
			net.Send(v)
			v:PrintMessage( HUD_PRINTTALK, text )
			sound.Play( "common/weapon_select.wav", v:GetPos(), 60, 40, 1 )
			sound.Play( "common/weapon_select.wav", v:GetPos(), 60, 40, 1 )
			sound.Play( "common/weapon_select.wav", v:GetPos(), 60, 40, 1 )
			sound.Play( "common/weapon_select.wav", v:GetPos(), 60, 80, 1 )
			sound.Play( "common/weapon_select.wav", v:GetPos(), 60, 80, 1 )
			sound.Play( "common/weapon_select.wav", v:GetPos(), 60, 160, 1 )
		end
	elseif (exp[1] == "spawn") then
		self.spawnNumber = util.StringToType(exp[2], "int")
		self.spawnClass = string.TrimRight( "ent_melon_"..exp[3], string.Right( exp[3], 1 ) )
	elseif (exp[1] == "path") then
		self.path = util.StringToType(exp[2], "int")
	elseif (exp[1] == "spawnpoint") then
		self.spawnpoint = util.StringToType(exp[2], "int")
	elseif (string.StartWith(exp[1], "randompath")) then
		self.path = math.random(1, self.pathcount)
	elseif (string.StartWith(exp[1], "cheateralert")) then
		game.CleanUpMap()
	elseif (string.StartWith(exp[1], "disappear")) then
		self:Remove()
	elseif (string.StartWith(exp[1], "clear")) then
		self.checkingdefeat = true
		self.nextOrder = CurTime()+3
	--elseif (string.StartWith(exp[1], "end") or string.StartWith(exp[1], "defeat")) then
	--	self.order = self.orderAmmount+1
	elseif (exp[1] == "team") then
		teamgrid[util.StringToType(exp[2], "int")][util.StringToType(exp[3], "int")] = true
		teamgrid[util.StringToType(exp[3], "int")][util.StringToType(exp[2], "int")] = true
		self:UpdateTeams ()
	elseif (exp[1] == "unteam") then
		teamgrid[util.StringToType(exp[2], "int")][util.StringToType(exp[3], "int")] = false
		teamgrid[util.StringToType(exp[3], "int")][util.StringToType(exp[2], "int")] = false
		self:UpdateTeams ()
	elseif (exp[1] == "addcredits") then
		local credits = mw_teamCredits[util.StringToType(exp[2], "int")]+util.StringToType(exp[3], "int")
		self:UpdateCredits(util.StringToType(exp[2], "int"),  credits)
	elseif (exp[1] == "setcredits") then
		local credits = util.StringToType(exp[3], "int")
		self:UpdateCredits(util.StringToType(exp[2], "int"),  credits)
	elseif (exp[1] == "setpower") then
		self:UpdatePower(util.StringToType(exp[2], "int"))
	elseif (exp[1] == "cutscene") then
		if (string.StartWith( exp[2], "start" )) then
			GetConVar( "mw_admin_cutscene" ):SetBool( true )
		else
			GetConVar( "mw_admin_cutscene" ):SetBool( false )
		end
	-------------------------------------------------------------------Control
	elseif (exp[1] == "goto") then
		self:Goto(exp[2])
	elseif (exp[1] == "if") then
		if (exp[2] == "mcguffin") then
			local a = self:CheckMcGuffin()
			if (table.Count(exp) == 2) then
				if (a > 0) then
					self:Goto(exp[3])
				end
			else
				if (_Compare(a, exp[3], util.StringToType(exp[4], "int"))) then
					self:Goto(exp[5])
				end
			end
		else
			if (_Compare(exp[2], exp[3], exp[4])) then
				self:Goto(exp[5])
			end
		end
	elseif (exp[1] == "set") then
		self:SetNWInt(exp[2], util.StringToType(exp[3], "int"))
	elseif (exp[1] == "add") then
		self:SetNWInt(exp[2], self:GetNWInt(exp[2],0) + util.StringToType(exp[3], "int"))
	end
end

function ENT:Goto(tag)
	local goto = 3
	tag = string.TrimRight(tag)
	while (not string.StartWith(self.orders[goto], tag) and not string.EndsWith(self.orders[goto], ":") and goto <= self.orderAmmount) do
		goto = goto+1
	end
	if (goto > self.orderAmmount or goto == 3) then
		print("Error with command 'goto'. Tag '"..tag.."' not found.")
	else
		self.order = goto
	end
end

function ENT:ReplaceVariables(exp)
	for k, v in pairs(exp) do
		if (string.StartWith(v, "&")) then
			exp[k] = tostring(self:GetNWInt(string.Trim(string.TrimLeft(v, "&")), -1337))
			print("///////////////// Changed "..v.." for "..exp[k])
		end
	end
end

function _Compare (a, x, b)
	if (type(a) == "string") then a = util.StringToType(a, "float") end
	if (type(b) == "string") then b = util.StringToType(b, "float") end
	if (x == ">") then
		return a > b
	elseif (x == "<") then
		return a < b
	elseif (x == ">=") then
		return a >= b
	elseif (x == "<=") then
		return a <= b
	elseif (x == "!=") then
		return a != b
	elseif (x == "==" or x == "=") then
		return a == b
	end
	return false
end

function ENT:CheckMcGuffin()
	local a = 0
	local foundEnts = ents.FindByClass( "ent_melon_mcguffin" )
	for k, v in pairs( foundEnts ) do
		if (v:GetNWInt("capTeam", 0) != 0) then
			a = a + 1
		end
	end
	return a
end

function ENT:UpdateCredits(_team, value)
	mw_teamCredits[_team] = value
	for k, v in pairs( player.GetAll() ) do
		if (v:GetInfo("mw_team") == tostring(_team)) then
			net.Start("MW_TeamCredits")
				net.WriteInt(value ,16)
			net.Send(v)
		end
	end
end 

function ENT:UpdatePower(value)
	for k, v in pairs( player.GetAll() ) do
		if (v:IsAdmin()) then
			v:ConCommand("mw_admin_max_units "..tostring(value))
		end
	end
end


function ENT:UpdateTeams ()
	for k, v in pairs( player.GetAll() ) do
		net.Start("UpdateClientTeams")
			net.WriteTable(teamgrid)
		net.Send(v)
	end
end

function ENT:Use( activator, caller, useType, value )
	net.Start("EditorSetStage")
		net.WriteEntity(self)
	net.Send(activator)
	--self.mw_melonTeam = 2
	--self:SetColor(Color(0,0,255,255))
end

function ENT:OnRemove()
	GetConVar( "mw_admin_cutscene" ):SetBool( false )
	self:UpdatePower(100)
end