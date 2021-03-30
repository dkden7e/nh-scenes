local hidden = false
scenes = {}
local settingScene = false
local coords = {}

RegisterNetEvent('nh-scenes:send', function(sent)
    scenes = sent
end)

RegisterCommand('+scenecreate', function()
    coords = {}
    local placement = SceneTarget()
    settingScene = true
    while settingScene do
        Wait(5)
        DisableControlAction(0, 200, true)
        placement = SceneTarget()
        if placement ~= nil then
            DrawMarker(28, placement.x, placement.y, placement.z, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.1, 93, 17, 100, 150, false, false)
        end
        if IsControlJustReleased(0, 202) then
            settingScene = false
            return
        end
    end
    if placement == nil then return end
    coords = placement
    local scene = exports["nh-keyboard"]:KeyboardInput({
        header = "Add Scene",
        rows = {
            {
                id = 0,
                txt = "Message"
            },
            {
                id = 1,
                txt = "Color {white, red, blue, green, yellow}"
            },
            {
                id = 2,
                txt = "Distance {1.1 - 10.0}"
            },
        }
    })
    if scene[1].input == nil then return end
    local message = scene[1].input
    local color = scene[2].input
    local distance = tonumber(scene[3].input)
    if type(distance) ~= "number" or distance > 10.0 then distance = 10.0 end
    distance = distance + 0.0
    if distance < 1.1 then distance = 1.1 end
    if color == nil or (color ~= "white" and color ~= "red" and color ~= "blue" and color ~= "green" and color ~= "yellow") then color = "white" end
    TriggerServerEvent('nh-scenes:add', coords, message, color, distance)
end)

RegisterCommand('-scenecreate', function()
    settingScene = false
end)


RegisterCommand('+scenehide', function()
    hidden = not hidden
    if hidden then
        print("Scenes Disabled")
    else
        print("Scenes Enabled")
    end
end)


RegisterCommand('+scenedelete', function()
    local scene = ClosestSceneLooking()
    if scene ~= nil then
        TriggerServerEvent('nh-scenes:delete', scene)
    end
end)


Citizen.CreateThread(function()
    while true do
        Wait(5)
        if #scenes > 0 then
            if not hidden then
                local plyCoords = GetEntityCoords(PlayerPedId())
                local closest = ClosestScene()
                if closest > 10.0 then
                    Wait(333)
                else
                    for k, v in pairs(scenes) do
                        distance = Vdist(plyCoords, v.coords)
                        if distance <= v.distance then
                            DrawScene(v.coords, v.message, v.color)
                        end
                    end
                end
            else
                Wait(333)
            end
        else
            Wait(333)
        end
    end
end)

TriggerServerEvent('nh-scenes:fetch')
RegisterKeyMapping('+scenecreate', '(scenes): Place Scene', "NONE", "NONE")
RegisterKeyMapping('+scenehide', '(scenes): Toggle Scenes', "NONE", "NONE")
RegisterKeyMapping('+scenedelete', '(scenes): Delete Scene', "NONE", "NONE")
