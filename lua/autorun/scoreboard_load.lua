if SERVER then
	AddCSLuaFile("scoreboard/scoreboard.lua")
	AddCSLuaFile("scoreboard/team_panel.lua")
	AddCSLuaFile("scoreboard/player_panel.lua")
	AddCSLuaFile("scoreboard/connecting_team.lua")
	include("scoreboard/connecting_team.lua")
	include("scoreboard/rating.lua")
	AddCSLuaFile("scoreboard/rating.lua")
else
	include("scoreboard/scoreboard.lua")
	include("scoreboard/rating.lua")
end