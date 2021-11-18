local Scenes = {}

SendScenes = function(ply)
    TriggerClientEvent("nh-scenes:send", ply, Scenes)
end

LogScene = function(ply, text, coords)
    local f, err = io.open("textfiles/scenes.txt", "a")
    if not f then return print(err) end
    f:write("Player: [" .. ply .. "] Name: [" .. GetPlayerName(ply) .. "] Placed Scene: [" .. text .. "] At Coords = " .. coords .. "\n")
    f:close()
end

RegisterNetEvent("nh-scenes:fetch", function()
    local src = source
    TriggerClientEvent("nh-scenes:sendgamename", src, GetConvar("gamename", "gta5"))
    SendScenes(src)
end)

RegisterNetEvent("nh-scenes:add", function(x, y, z, message, color, distance)
    if not x or not y or not z or not color or not message or not distance then return end
    table.insert(Scenes, {
        message = message,
        color = color,
        distance = distance,
        x = x,
        y = y,
        z = z,
    })
    SendScenes(-1)
    LogScene(source, message, vector3(x, y, z))
end)

RegisterNetEvent("nh-scenes:delete", function(key)
    table.remove(Scenes, key)
    SendScenes(-1)
end)
