
local tag = "connecting_team"

if SERVER then
	util.AddNetworkString(tag)

	gameevent.Listen("player_connect")
	hook.Add("player_connect", tag, function(data)
		local info = {}
		info.name = data.name
		info.steamid = data.networkid
		info.userid = data.userid
		info.left = false

		net.Start(tag)
			net.WriteTable(info)
		net.Broadcast()
	end)

	gameevent.Listen("player_disconnect")
	hook.Add("player_disconnect", tag, function(data)
		local info = {}
		info.name = data.name
		info.steamid = data.networkid
		info.userid  = data.userid
		info.left = true

		net.Start(tag)
			net.WriteTable(info)
		net.Broadcast()
	end)
elseif CLIENT then
	TEAM_DISCONNECTED = -1
	team.SetUp(TEAM_CONNECTING, "Wchodzą...", Color(97, 184, 12))
	team.SetUp(TEAM_DISCONNECTED, "Niedawno wyszli", Color(63, 67, 82))

	player.Connecting = {}

	player.DisconnectedTimeout = 30

	net.Receive(tag, function()
		if not player.Connecting then return end

		local info = net.ReadTable()
		info.since = CurTime()
		player.Connecting[info.userid or "BOT"] = info
		
	end)

	gameevent.Listen("player_spawn")
	hook.Add("player_spawn", tag, function(data)
		if not player.Connecting then return end

		local info = player.Connecting[data.userid]
		if info then
			info.spawned = true
		end
	end)

	team._GetPlayers = team._GetPlayers or team.GetPlayers
	function team.GetPlayers(id)
		if id == TEAM_CONNECTING or id == TEAM_DISCONNECTED then
			local tbl = {}
			for userid, info in next, player.Connecting do
				if (id == TEAM_CONNECTING and not info.left) or (id == TEAM_DISCONNECTED and info.left) then
					tbl[#tbl + 1] = info
				end
			end
			return tbl
		end

		return team._GetPlayers(id)
	end
end
