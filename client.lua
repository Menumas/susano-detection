--- @return false|table If no cheat detected, returns false. otherwise, returns a table with reason and detail
local function Stopper()
    local gameTimer = GetGameTimer()
    local countTimer = 0
    local countTotal = 0

    while (true) do
        Citizen.Wait(50)

        if (GetGameTimer() == gameTimer) then
            countTimer = countTimer + 1
        end

        if (countTimer >= 10) then
            return {
                reason = "Internal cheat (Susano)",
                detail = "Detected Susano resource stopper"
            }
        end

        countTotal = countTotal + 1
        if (countTotal >= 15) then
            break
        end
    end

    return false
end

--- Creates a loop to periodically check for the Susano stopper cheat
Citizen.CreateThread(function ()
    while (true) do
        Citizen.Wait(6000)

        local detected = Stopper()
        if (detected) then
            TriggerServerEvent("detected/stopper", detected.reason, detected.detail)
        end
    end
end)