--xgui.prepareDataType( "TIIPURMLimits" )
--xgui.prepareDataType( "TIIPURMRestrictions" )
--xgui.prepareDataType( "TIIPURMLoadouts" )

urm = urm or {}
urm.weapons = {
	"weapon_357",
	"weapon_slam",
	"weapon_ar2",
	"weapon_bugbait",
	"weapon_crossbow",
	"weapon_crowbar",
	"weapon_frag",
	"weapon_physcannon",
	"weapon_physgun",
	"weapon_pistol",
	"weapon_rpg",
	"weapon_shotgun",
	"weapon_smg1",
	"weapon_stunstick",
	"weapon_annabelle"
}
for k,v in pairs (weapons.GetList()) do
	table.insert(urm.weapons,v.ClassName)
end
urm.vehicles = table.GetKeys(list.Get( "Vehicles" ))	
urm.npcs = table.GetKeys(list.Get( "NPC" ))
urm.entities = table.GetKeys(list.Get( "SpawnableEntities" ))
urm.tools = table.GetKeys(weapons.GetStored( 'gmod_tool' ).Tool)
urm.cleanup = cleanup.GetTable()
urm.all = {}
table.Add(urm.all,urm.weapons )	
table.Add(urm.all,urm.vehicles )	
table.Add(urm.all,urm.npcs )	
table.Add(urm.all,urm.entities )	
table.Add(urm.all,urm.tools )	

local textboxDefaults = {}
function urm.getDefaultTextboxText(textbox)
	return textboxDefaults[textbox] or ""
end

function urm.setDefaultTextboxText(textbox,default)

	color = color or Color(150,150,150)
	default_color = Color(0,0,0)
	
	if textboxDefaults[textbox] then
		textboxDefaults[textbox] = default
		return
	end
	
	textboxDefaults[textbox] = default
	
	textbox.OnLoseFocus = function()
		local text = textbox:GetValue()
		if (not text) or (text == "") then
			textbox:SetText(urm.getDefaultTextboxText(textbox))
			textbox:SetTextColor(color)
		end
		
		textbox:UpdateConvarValue()
		hook.Call( "OnTextEntryLoseFocus", nil, textbox )
	end

	textbox.OnGetFocus = function()
		local text = textbox:GetValue()
		if (text == default) then
			textbox:SetText("")
			textbox:SetTextColor(default_color)
		else
			textbox:SetTextColor(default_color)
			textbox:SelectAll()
		end
		hook.Run( "OnTextEntryGetFocus", textbox )
	end

	textbox:SetText(default)
	textbox:SetTextColor(color)
	
end

urm.loaded = true

if urm.load_list then
	for k,v in pairs(urm.load_list) do
		include(v)
	end
end

