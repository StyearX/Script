local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local ReqFunc = (syn and syn.request) or (http and http.request) or http_request or request

local function GetUserProfile(userId)
    local url = "https://users.roblox.com/v1/users/" .. userId
    local success, result = pcall(function()
        local res = ReqFunc({
            Url = url,
            Method = "GET",
            Headers = {["User-Agent"] = "Roblox/1.0"}
        })
        if res and res.Body then
            return HttpService:JSONDecode(res.Body)
        end
        return nil
    end)
    return success, result
end

local function GetFriendsCount(userId)
    local url = "https://friends.roblox.com/v1/users/" .. userId .. "/friends/count"
    local success, result = pcall(function()
        local res = ReqFunc({
            Url = url,
            Method = "GET",
            Headers = {["User-Agent"] = "Roblox/1.0"}
        })
        if res and res.Body then
            local data = HttpService:JSONDecode(res.Body)
            return data.count or 0
        end
        return 0
    end)
    return success, result
end

local function GetFollowersCount(userId)
    local url = "https://friends.roblox.com/v1/users/" .. userId .. "/followers/count"
    local success, result = pcall(function()
        local res = ReqFunc({
            Url = url,
            Method = "GET",
            Headers = {["User-Agent"] = "Roblox/1.0"}
        })
        if res and res.Body then
            local data = HttpService:JSONDecode(res.Body)
            return data.count or 0
        end
        return 0
    end)
    return success, result
end

local function GetFollowingCount(userId)
    local url = "https://friends.roblox.com/v1/users/" .. userId .. "/followings/count"
    local success, result = pcall(function()
        local res = ReqFunc({
            Url = url,
            Method = "GET",
            Headers = {["User-Agent"] = "Roblox/1.0"}
        })
        if res and res.Body then
            local data = HttpService:JSONDecode(res.Body)
            return data.count or 0
        end
        return 0
    end)
    return success, result
end

local UserInfoSystem = {}

function UserInfoSystem.GetInfo(userId)
    userId = userId or LocalPlayer.UserId
    
    local data = {
        username = LocalPlayer.Name,
        displayName = LocalPlayer.DisplayName,
        userId = userId,
        description = "",
        friends = 0,
        followers = 0,
        following = 0,
        avatarUrl = "rbxthumb://type=AvatarHeadShot&id=" .. userId .. "&w=420&h=420"
    }
    
    local success, profile = GetUserProfile(userId)
    if success and profile then
        data.description = profile.description or ""
        data.username = profile.name or LocalPlayer.Name
        data.displayName = profile.displayName or LocalPlayer.DisplayName
    end
    
    local success2, friends = GetFriendsCount(userId)
    if success2 then
        data.friends = friends
    end
    
    local success3, followers = GetFollowersCount(userId)
    if success3 then
        data.followers = followers
    end
    
    local success4, following = GetFollowingCount(userId)
    if success4 then
        data.following = following
    end
    
    return data
end

function UserInfoSystem.GetFriendsList(userId)
    userId = userId or LocalPlayer.UserId
    local list = {}
    local url = "https://friends.roblox.com/v1/users/" .. userId .. "/friends"
    
    local success, result = pcall(function()
        local res = ReqFunc({
            Url = url,
            Method = "GET",
            Headers = {["User-Agent"] = "Roblox/1.0"}
        })
        if res and res.Body then
            local data = HttpService:JSONDecode(res.Body)
            return data.data or {}
        end
        return {}
    end)
    
    if success and result then
        for _, friend in ipairs(result) do
            table.insert(list, {
                id = friend.id,
                name = friend.name,
                displayName = friend.displayName
            })
        end
    end
    
    return list
end

function UserInfoSystem.GetFollowersList(userId)
    userId = userId or LocalPlayer.UserId
    local list = {}
    local url = "https://friends.roblox.com/v1/users/" .. userId .. "/followers?limit=100"
    
    local success, result = pcall(function()
        local res = ReqFunc({
            Url = url,
            Method = "GET",
            Headers = {["User-Agent"] = "Roblox/1.0"}
        })
        if res and res.Body then
            local data = HttpService:JSONDecode(res.Body)
            return data.data or {}
        end
        return {}
    end)
    
    if success and result then
        for _, follower in ipairs(result) do
            table.insert(list, {
                id = follower.id,
                name = follower.name,
                displayName = follower.displayName
            })
        end
    end
    
    return list
end

function UserInfoSystem.GetFollowingList(userId)
    userId = userId or LocalPlayer.UserId
    local list = {}
    local url = "https://friends.roblox.com/v1/users/" .. userId .. "/followings?limit=100"
    
    local success, result = pcall(function()
        local res = ReqFunc({
            Url = url,
            Method = "GET",
            Headers = {["User-Agent"] = "Roblox/1.0"}
        })
        if res and res.Body then
            local data = HttpService:JSONDecode(res.Body)
            return data.data or {}
        end
        return {}
    end)
    
    if success and result then
        for _, following in ipairs(result) do
            table.insert(list, {
                id = following.id,
                name = following.name,
                displayName = following.displayName
            })
        end
    end
    
    return list
end

return UserInfoSystem
