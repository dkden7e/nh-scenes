local Scenes, Keys, IsRDR, Hidden, SettingScene = {}, {}, true, false, false
local Colors = {
    ["white"] = {255, 255, 255},
    ["red"] = {255, 0, 0},
    ["blue"] = {31, 106, 255},
    ["green"] = {97, 246, 67},
    ["yellow"] = {255, 255, 0},
    ["purple"] = {178, 102, 255},
    ["cyan"] = {0, 255, 255},
    ["pink"] = {255, 93, 163},
}

RegisterNetEvent("nh-scenes:send", function(sent)
    Scenes = sent
end)

RegisterNetEvent("nh-scenes:sendgamename", function(game)
    IsRDR = game == "rdr3"
    ProcessBinds()
end)

SceneTarget = function()
    local Cam = GetGameplayCamCoord()
    local handle
    if IsRDR then
        handle = Citizen.InvokeNative(0x377906D8A31E5586, Cam, GetCoordsFromCam(10.0, Cam), -1, PlayerPedId(), 4)
    else
        handle = StartExpensiveSynchronousShapeTestLosProbe(Cam, GetCoordsFromCam(10.0, Cam), -1, PlayerPedId(), 4)
    end
    local _, Hit, Coords, _, Entity = GetShapeTestResult(handle)
    return Coords
end

GetCoordsFromCam = function(distance, coords)
    local rotation = GetGameplayCamRot()
    local adjustedRotation = vector3((math.pi / 180) * rotation.x, (math.pi / 180) * rotation.y, (math.pi / 180) * rotation.z)
    local direction = vector3(-math.sin(adjustedRotation[3]) * math.abs(math.cos(adjustedRotation[1])), math.cos(adjustedRotation[3]) * math.abs(math.cos(adjustedRotation[1])), math.sin(adjustedRotation[1]))
    return vector3(coords[1] + direction[1] * distance, coords[2] + direction[2] * distance, coords[3] + direction[3] * distance)
end

DrawScene = function(x, y, z, text, color)
    if not text or not color or not x or not y or not z then return end
    local onScreen, gx, gy = GetScreenCoordFromWorldCoord(x, y, z)
    local dist = #(GetGameplayCamCoord() - vector3(x, y, z))
    
    local scale = ((1 / dist) * 2) * (1 / GetGameplayCamFov()) * 55
    
    if IsRDR then
        if (gx > 0 and gx < 1) or (gy > 0 and gy < 1) then
            onScreen, gx, gy = GetHudScreenPositionFromWorldPosition(x, y, z)
            local str = CreateVarString(10, "LITERAL_STRING", text)
            SetTextColor(color[1], color[2], color[3], 255)
            SetTextScale(0.0 * scale, 0.50 * scale)
            SetTextFontForCurrentCommand(1)
            SetTextCentre(1)
            SetTextDropshadow(1, 0, 0, 0, 255)
            DisplayText(str, gx, gy)
            
            local height = 0.06 * scale - 0.005
            local length = string.len(text)
            local limiter = 120
            if length > 98 then
                length = 98
                limiter = 200
            end
            local width = length / limiter * scale
            DrawRect(gx, (gy + scale / 50), width, height, 0, 0, 0, 90)
        end
    else
        if onScreen then
            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringKeyboardDisplay(text)
            SetTextColour(color[1], color[2], color[3], 255)
            SetTextScale(0.0 * scale, 0.50 * scale)
            SetTextFont(0)
            SetTextCentre(1)
            SetTextDropshadow(1, 0, 0, 0, 155)
            EndTextCommandDisplayText(gx, gy)
            
            local height = GetTextScaleHeight(1 * scale, 0) - 0.005
            local length = string.len(text)
            local limiter = 120
            if length > 98 then
                length = 98
                limiter = 200
            end
            local width = length / limiter * scale
            DrawRect(gx, (gy + scale / 50), width, height, 0, 0, 0, 90)
        end
    end
end

ClosestScene = function()
    local closestscene = 1000.0
    for i = 1, #Scenes do
        local distance = #(GetOffsetFromEntityGivenWorldCoords(PlayerPedId(), vector3(Scenes[i].x, Scenes[i].y, Scenes[i].z)))
        if (distance < closestscene) then
            closestscene = distance
        end
    end
    return closestscene
end

ClosestSceneLooking = function()
    local closestscene = 1000.0
    local scanid = nil
    local coords = SceneTarget()
    for i = 1, #Scenes do
        local distance = #(vector3(Scenes[i].x, Scenes[i].y, Scenes[i].z) - coords)
        if (distance < closestscene and distance < Scenes[i].distance) then
            scanid = i
            closestscene = distance
        end
    end
    return scanid
end

CreateScene = function()
    if SettingScene then SettingScene = false return end
    CreateThread(function()
        local x, y, z
        SettingScene = true
        
        while SettingScene do
            Wait(0)
            DisableControlAction(2, Keys["CANCEL"], true)
            x, y, z = table.unpack(SceneTarget())
            if IsRDR then
                Citizen.InvokeNative(0x2A32FAA57B937173, 0x50638AB9, x, y, z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.15, 0.15, 0.15, 93, 17, 100, 255, false, false, 2, false, false)
            else
                DrawMarker(28, x, y, z, 0, 0, 0, 0, 0, 0, 0.15, 0.15, 0.15, 93, 17, 100, 255, false, false)
            end
            if IsDisabledControlJustReleased(2, Keys["CANCEL"]) then
                SettingScene = false
                return
            end
        end
        
        if x == nil or y == nil or z == nil then return end
        
        local keyboard, message, color, distance = exports["nh-keyboard"]:Keyboard({
            header = "Add Scene",
            rows = {
                "Message",
                "Color {white, red, blue, cyan, green, yellow, purple, pink}",
                "Distance {1.1 - 10.0}"
            }
        })
        
        if not keyboard then return end
        distance = tonumber(distance)
        if not distance or type(distance) ~= "number" or distance > 10.0 then distance = 10.0 end
        if distance < 1.1 then distance = 1.1 end
        distance = distance + 0.0

        color = color and string.lower(color)
        if not color or not Colors[color] then color = "white" end
        color = Colors[color]
        
        TriggerServerEvent("nh-scenes:add", x, y, z, message, color, distance)
    end)
end

HideScenes = function()
    Hidden = not Hidden
    if Hidden then
        print("Scenes Disabled")
    else
        print("Scenes Enabled")
    end
end

DeleteScene = function()
    local scene = ClosestSceneLooking()
    if scene then
        TriggerServerEvent("nh-scenes:delete", scene)
    end
end

ProcessBinds = function()
    if IsRDR then
        Keys = {
            ["CANCEL"] = 0x156F7119, --Esc/Backspace
            ["CREATE"] = 0x064D1698, -- Home
            ["DELETE"] = 0x4AF4D473, -- Delete
            ["HIDE"] = 0xA5BDCD3C -- Right Bracket
        }
        CreateThread(function()
            while true do
                Wait(0)
                if IsDisabledControlJustReleased(2, Keys["CREATE"]) then
                    CreateScene()
                end
                if IsDisabledControlJustPressed(2, Keys["DELETE"]) then
                    DeleteScene()
                end
                if IsDisabledControlJustPressed(2, Keys["HIDE"]) then
                    HideScenes()
                end
            end
        end)
    else
        Keys = {
            ["ESC"] = 200, --Esc/Backspace
        }
        RegisterCommand("+scenecreate", function() end)
        RegisterCommand("-scenecreate", CreateScene)
        RegisterCommand("+scenehide", HideScenes)
        RegisterCommand("+scenedelete", DeleteScene)
        RegisterKeyMapping("+scenecreate", "(scenes): Place Scene", "keyboard", "")
        RegisterKeyMapping("+scenehide", "(scenes): Toggle Scenes", "keyboard", "")
        RegisterKeyMapping("+scenedelete", "(scenes): Delete Scene", "keyboard", "")
    end
end



Citizen.CreateThread(function()
    TriggerServerEvent("nh-scenes:fetch")
    while true do
        local wait = 0
        if #Scenes > 0 then
            if not Hidden then
                local closest = ClosestScene()
                if closest > 10.0 then
                    wait = 250
                else
                    for i = 1, #Scenes do
                        local distance = #(GetOffsetFromEntityGivenWorldCoords(PlayerPedId(), vector3(Scenes[i].x, Scenes[i].y, Scenes[i].z)))
                        if distance <= Scenes[i].distance then
                            local success, err = pcall(function()
                                return DrawScene(Scenes[i].x, Scenes[i].y, Scenes[i].z, Scenes[i].message, Scenes[i].color)
                            end)
                            if not success then
                                print(err)
                            end
                        end
                    end
                end
            else
                wait = 250
            end
        else
            wait = 250
        end
        Wait(wait)
    end
end)
