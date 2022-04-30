local meta = FindMetaTable("Player")
if SERVER then
util.AddNetworkString("ScoreboardRatingAdd")
end

function meta:GetRating(name)
    local ratings = self:GetNWString("ratings",util.TableToJSON({}))
    print(self,ratings)
    ratings = util.JSONToTable(ratings)
    ratings = ratings or {}
    return ratings[name] or 0
end

if SERVER then
    function meta:SetRating(name,much)
        local ratings = self:GetNWString("ratings",util.TableToJSON({}))
        ratings = util.JSONToTable(ratings)
        ratings[name] = much
        self:SetNWString("ratings",util.TableToJSON(ratings))
        self:SetPData("ratings",util.TableToJSON(ratings))
    end
    hook.Add("PlayerInitialSpawn","RatingsLoad",function(ply)
        ply:SetNWString("ratings",ply:GetPData("ratings",util.TableToJSON({})))
        --print("[Rank]",ply)
    end)
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