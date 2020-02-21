local function LoadCS(path)
	if SERVER then
		AddCSLuaFile("tablet/" .. path)
	else
		include("tablet/" .. path)
	end
end

LoadCS("ui.lua")
LoadCS("init.lua")
LoadCS("config.lua")

LoadCS("client/apps.lua")
LoadCS("client/main.lua")

LoadCS("client/estore.lua")
LoadCS("client/gunshop.lua")
LoadCS("client/webbrowser.lua")
LoadCS("client/gouvernement.lua")

if SERVER then
	resource.AddSingleFile("materials/ugc/tablet/appicon_blank.png")
	resource.AddSingleFile("materials/ugc/tablet/back_btn.png")
	resource.AddSingleFile("materials/ugc/tablet/battery.png")
	resource.AddSingleFile("materials/ugc/tablet/crimenet.png")
	resource.AddSingleFile("materials/ugc/tablet/estore.png")
	resource.AddSingleFile("materials/ugc/tablet/gunstore.png")
	resource.AddSingleFile("materials/ugc/tablet/gunstoreowner.png")
	resource.AddSingleFile("materials/ugc/tablet/menu_btn.png")
	resource.AddSingleFile("materials/ugc/tablet/power_btn.png")
	resource.AddSingleFile("materials/ugc/tablet/signal.png")
	resource.AddSingleFile("materials/ugc/tablet/speedy.png")
	resource.AddSingleFile("materials/ugc/tablet/tablet.png")
	resource.AddSingleFile("materials/ugc/tablet/workgm.png")
	resource.AddSingleFile("materials/ugc/tablet/background.png")
end