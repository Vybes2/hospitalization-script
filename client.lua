local player = GetPlayerPed(-1)
local isPlayerInHospital = false
local nearestLoc = nil
local nearestLocationName = nil
local waitTime = 0
local timerActive = false

local locations = {
    SandyMedical = {
        x = 1839.34,
        y = 3673.06,
        z = 34.28,
        heading = 203.88
    },
    PillBoxMedical = {
        x = 360.01,
        y = -589.41,
        z = 28.66,
        heading = 246.54
    }
}

RegisterCommand("hospitalize", function(source, args)
    local specifiedHospital = args[1]
    local specifiedWaitTime = tonumber(args[2]) or 0  -- Default to 0 seconds if not specified or invalid

    if specifiedHospital then
        if locations[specifiedHospital] then
            nearestLocationName = specifiedHospital
            nearestLoc = locations[nearestLocationName]

            TriggerEvent("chatMessage", "Hospital", {255, 0, 0}, "You have been hospitalized at " .. nearestLocationName)
            isPlayerInHospital = true
            SetEntityHealth(player, 200)
            -- Set wait time
            waitTime = specifiedWaitTime
            if waitTime > 0 then
                TriggerEvent("chatMessage", "Hospital", {255, 0, 0}, "You must wait for " .. waitTime .. " seconds before leaving the hospital.")
                StartTimer()
            end
        else
            TriggerEvent("chatMessage", "Hospital", {255, 0, 0}, "Invalid hospital name or hospital not found")
        end
    else
        TriggerEvent("chatMessage", "Hospital", {255, 0, 0}, "Please specify a hospital name")
    end
end, false)

RegisterCommand("leavehospital", function(source, args)
    if isPlayerInHospital then
        if waitTime > 0 and timerActive then
            TriggerEvent("chatMessage", "Hospital", {255, 0, 0}, "You must wait for " .. waitTime .. " seconds before leaving the hospital.")
        else
            TriggerEvent("chatMessage", "Hospital", {255, 0, 0}, "You have left the hospital")
            isPlayerInHospital = false

            -- Set respawn position
            local respawnX, respawnY, respawnZ = nearestLoc.x, nearestLoc.y, nearestLoc.z
            SetEntityCoordsNoOffset(player, respawnX, respawnY, respawnZ, true, true, true)

            if waitTime <= 0 then
                FreezeEntityPosition(player, false)
            end
        end
    else
        TriggerEvent("chatMessage", "Hospital", {255, 0, 0}, "You are not in a hospital")
    end
end, false)

function StartTimer()
    timerActive = true
    Citizen.CreateThread(function()
        while timerActive and waitTime > 0 do
            Citizen.Wait(1000)  -- Wait for 1 second
            waitTime = waitTime - 1
        end
        timerActive = false
    end)
end
