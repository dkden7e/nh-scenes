function SceneTarget(distance)
    local Cam = GetGameplayCamCoord()
    local _, Hit, Coords, _, Entity = GetShapeTestResult(StartExpensiveSynchronousShapeTestLosProbe(Cam, GetCoordsFromCam(10.0, Cam), -1, PlayerPedId(), 4))
    return Coords
end

function GetCoordsFromCam(distance, coords)
    local rotation = GetGameplayCamRot()
    local adjustedRotation = vector3((math.pi / 180) * rotation.x, (math.pi / 180) * rotation.y, (math.pi / 180) * rotation.z)
    local direction = vector3(-math.sin(adjustedRotation[3]) * math.abs(math.cos(adjustedRotation[1])), math.cos(adjustedRotation[3]) * math.abs(math.cos(adjustedRotation[1])), math.sin(adjustedRotation[1]))
    return vector3(coords[1] + direction[1] * distance, coords[2] + direction[2] * distance, coords[3] + direction[3] * distance)
end

function DrawScene(coords, text, color, dist)
    local onScreen, x, y = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z)
    if dist < 1.75 then dist = 1.75 end

    local scale = ((1 / dist) * 2) * (1 / GetGameplayCamFov()) * 70

    if onScreen then
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringKeyboardDisplay(text)
        SetTextFont(0)
        SetTextCentre(1)
        SetTextDropshadow(0, 0, 0, 0, 155)
        SetTextEdge(1, 0, 0, 0, 250)
        SetTextScale(0.0 * scale, 0.30 * scale)
        SetTextColour(color[1], color[2], color[3], 255)
        
        local height = GetTextScaleHeight(0.40 * scale, 0)
        local length = string.len(text)
        local limiter = 160
        if length > 98 then
            length = 98
            limiter = 200
        end
        local width = length / limiter * scale
        EndTextCommandDisplayText(x, y)
        DrawRect(x, y + scale / 90, width, height, 0, 0, 0, 90)
    end
end

function ClosestScene()
    local closestscene = 1000.0
    local coords = GetEntityCoords(PlayerPedId())
    for i = 1, #scenes do
        local distance = Vdist(scenes[i].coords[1], scenes[i].coords[2], scenes[i].coords[3], coords[1], coords[2], coords[3])
        if (distance < closestscene) then
            closestscene = distance
        end
    end
    return closestscene
end

function ClosestSceneLooking()
    local closestscene = 1000.0
    local scanid = nil
    local coords = SceneTarget()
    for i = 1, #scenes do
        local distance = Vdist(scenes[i].coords[1], scenes[i].coords[2], scenes[i].coords[3], coords[1], coords[2], coords[3])
        if (distance < closestscene and distance < scenes[i].distance) then
            scanid = i
            closestscene = distance
        end
    end
    return scanid
end
