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

function DrawScene(coords, text, color)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(coords[1], coords[2], coords[3])
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(0)
        SetTextProportional(1)
        if color == "white" then
            SetTextColour(255, 255, 255, 255)
        elseif color == "red" then
            SetTextColour(235, 52, 52, 255)
        elseif color == "blue" then
            SetTextColour(52, 70, 235, 255)
        elseif color == "green" then
            SetTextColour(52, 235, 55, 255)
        elseif color == "yellow" then
            SetTextColour(235, 232, 52, 255)
        end
        SetTextDropshadow(0, 0, 0, 0, 155)
        SetTextEdge(1, 0, 0, 0, 250)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        
        DrawText(_x, _y)
        local factor = (string.len(text)) / 175
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 90)
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
