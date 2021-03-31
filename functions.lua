function SceneTarget()
    local camCoords = GetPedBoneCoords(PlayerPedId(), 37193, 0.0, 0.0, 0.0)
    local farCoords = GetCoordsFromCam()
    local RayHandle = StartExpensiveSynchronousShapeTestLosProbe(camCoords, farCoords, -1, PlayerPedId(), 4)
    local _, hit, endcoords, surfaceNormal, entityHit = GetShapeTestResult(RayHandle)
    if endcoords[1] == 0.0 then return end
    return endcoords
end

function GetCoordsFromCam()
    local rot = GetGameplayCamRot(2)
    local coord = GetGameplayCamCoord()
    
    local tZ = rot.z * 0.0174532924
    local tX = rot.x * 0.0174532924
    local num = math.abs(math.cos(tX))
    
    newCoordX = coord.x + (-math.sin(tZ)) * (num + 4.0)
    newCoordY = coord.y + (math.cos(tZ)) * (num + 4.0)
    newCoordZ = coord.z + (math.sin(tX) * 8.0)
    return vector3(newCoordX, newCoordY, newCoordZ)
end

function DrawScene(coords, text, color, dist)
    local onScreen, x, y = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z)

    local scale = ((1 / dist) * 2) * (1 / GetGameplayCamFov()) * 70

    if onScreen then
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringKeyboardDisplay(text)
        SetTextFont(0)
        SetTextCentre(1)
        SetTextDropshadow(0, 0, 0, 0, 155)
        SetTextEdge(1, 0, 0, 0, 250)
        SetTextScale(0.0 * scale, 0.25 * scale)
        SetTextColour(color[1], color[2], color[3], 255)
        
        local height = GetTextScaleHeight(0.40 * scale, 0)
        local width = (string.len(text)) / 200 * scale
        EndTextCommandDisplayText(x, y)
        DrawRect(x, y + scale / 90, width, height, 0, 0, 0, 90)
    end
end

function ClosestScene()
    local closestscene = 1000.0
    for i = 1, #scenes do
        local distance = Vdist(scenes[i].coords, GetEntityCoords(PlayerPedId()))
        if (distance < closestscene) then
            closestscene = distance
        end
    end
    return closestscene
end

function ClosestSceneLooking()
    local closestscene = 1000.0
    local scanid = nil
    for i = 1, #scenes do
        local distance = Vdist(scenes[i].coords, SceneTarget())
        if (distance < closestscene and distance < scenes[i].distance) then
            scanid = i
            closestscene = distance
        end
    end
    return scanid
end
