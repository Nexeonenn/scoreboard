local meta = FindMetaTable("Player")
local plyRatings = {}

if SERVER then
util.AddNetworkString("ScoreboardRatingAdd")
util.AddNetworkString("ScoreboardRatingSync")
end


if SERVER then
    function syncRatings(ply)
        local data = util.Compress(ply:GetPData("ratings",util.TableToJSON({})))
        local len = string.len(data)
        net.Start("ScoreboardRatingSync")
        net.WriteEntity(ply)
        net.WriteInt(len,32)
        net.WriteData(data,len)
        net.Broadcast()
    end
else
    net.Receive("ScoreboardRatingSync",function(_,_)
        local ply = net.ReadEntity()
        local len = net.ReadInt(32)
        local data = util.Decompress(net.ReadData(len))
        local datatable = util.JSONToTable(data)
        plyRatings[ply] = datatable
    end)
end


function meta:GetRating(name)
    plyRatings[self] = plyRatings[self] or {}
    if SERVER then
        plyRatings[self] = self:GetPData("ratings",util.TableToJSON({}))
    end
    return plyRatings[self][name] or 0
end

if SERVER then
    timer.Simple(0.1,function()
        for i,v in ipairs(player.GetAll()) do
            syncRatings(v)
        end
    end)
    function meta:SetRating(name,much)
        local ratings = self:GetPData("ratings",util.TableToJSON({}))
        ratings = util.JSONToTable(ratings)
        ratings[name] = much
        self:SetPData("ratings",util.TableToJSON(ratings))
        syncRatings(self)
    end
    hook.Add("PlayerInitialSpawn","RatingsLoad",syncRatings)
end

function meta:AddRating(name,much)
    if SERVER then
        self:SetRating(name,self:GetRating(name)+much)
    else
        net.Start("ScoreboardRatingAdd")
        net.WriteString(name)
        net.WriteEntity(self)
        net.SendToServer()
    end
end
local limits = {}

if SERVER then
    net.Receive("ScoreboardRatingAdd",function(_,ply)
        local giver = ply
        local name = net.ReadString()
        local who = net.ReadEntity()
        if(giver == who) then 
            giver:ChatPrint("[Rating] U can't do it with yourself lol")
            return
        end
        if (IsValid(who) and IsValid(giver))then
        limits[giver] = limits[giver] or {}
        limits[giver][who] = limits[giver][who] or 0
            if( limits[giver][who] < CurTime() ) then
                limits[giver][who] = CurTime()+60 
                who:AddRating(name,1)
                giver:ChatPrint("[Rating] Given "..who:Name().." "..name.." rating.")
                who:ChatPrint("[Rating] "..giver:Name().." gave u "..name.." rating.")
            else
                giver:ChatPrint("[Rating] 60 sec limit sry ("..math.Round(limits[giver][who]-CurTime()).." left)")
            end
        end
    end)
end