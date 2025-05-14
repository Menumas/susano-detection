local function HasInternalNoclip()
    -- bypass for admin
    return false
end

local function IsPedValidGround(ped)
    local veh = IsPedInAnyVehicle(ped, false)
    local speed = GetEntitySpeed(ped)
    local para = GetPedParachuteState(ped)
    local flyveh = IsPedInFlyingVehicle(ped)
    local fall = IsPedFalling(ped)
    local parafall = IsPedInParachuteFreeFall(ped)
    local isDead = IsEntityDead(ped) or (GetEntityHealth(ped) <= 0) or IsPedFatallyInjured(ped)
    local heightAg = GetEntityHeightAboveGround(ped)

    if (heightAg <= 3.0 or heightAg >= 150.0) then
        return false
    end

    if veh then
        return false
    end

    if isDead then
        return false
    end

    if speed >= 8.0 then
        return false
    end

    if para and para > 0 then
        return false
    end

    if flyveh then
        return false
    end

    if fall or parafall then
        if (speed > 0.01) and (speed < 2.0) and (not IsPedRunning(ped)) and (not IsPedWalking(ped)) and (heightAg > 3.0) then -- susano noclip
            return true
        end

        return false   
    end

    if IsPlayerTeleportActive() then
        return false
    end

    if not (HasCollisionLoadedAroundEntity(ped) == 1) then
        return false
    end

    local cam = GetRenderingCam()
    if (cam ~= -1) then
        return false
    end

    return true
end

local lastCoords = vec3(0, 0, 0)
local inNoclipMovement = false
local flags = 0
local PlayerPedId = PlayerPedId()
local function HandleNoclip()
    local boneIndex = GetPedBoneIndex(PlayerPedId, 31086) 
    local headPosition = GetWorldPositionOfEntityBone(PlayerPedId, boneIndex)
    local coords = vector3(headPosition.x, headPosition.y, headPosition.z)


    if (lastCoords and (lastCoords.x ~= 0.0) and (lastCoords.y ~= 0.0)) then
        if (IsPedValidGround(PlayerPedId)) then
            local distance = #(coords - lastCoords)
            if (distance > 5) and (distance < 50) then
                SetEntityCoords(PlayerPedId, lastCoords.x, lastCoords.y, lastCoords.z)

                Citizen.SetTimeout((inNoclipMovement and 500 or 2000), function()
                    flags = flags + 1

                    if (flags == 20) then
                        exports["screenshot-basic"]:requestScreenshotUpload("http://webhook-url", "files[]", function (data)
                            TriggerServerEvent("noclip/detected", {
                                reason = "Flag 20 triggered",
                                detail = "Client-side condition met, screenshot taken",
                                image = imageUrl
                            })
                        end)
                    end

                    inNoclipMovement = false
                end)

                inNoclipMovement = true
            end
        else
            Wait(1000)
        end
    end

    if (not inNoclipMovement) then
        lastCoords = coords
    else
        SetEntityCoords(PlayerPedId, lastCoords.x, lastCoords.y, lastCoords.z)
    end
end

Citizen.CreateThread(function ()
    while true do
        Wait(100)
        if (not HasInternalNoclip()) then
            HandleNoclip()
        else
            Wait(2000)
        end
    end
end)
