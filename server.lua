--- @event detected/stopper
--- @param reason string Reason for detection
--- @param detail string Additional detail about detection
RegisterServerEvent("detected/stopper", function (reason, detail)
    local playerId <const> = source
    logEntry(playerId, "cheat-internal", "Internal cheat (Susano)", "Detected Susano (Stopper)")
end)

--- @param reason string The reason the player was dropped
AddEventHandler("playerDropped", function (reason)
    local playerId <const> = source
    local len = reason:len()

    if reason:find("Program is incompatible") and reason:find("??") and (reason:sub(len - 3, len) == ".exe") then
        local firstQuotas = reason:find("??");
        local path = "";
        if (firstQuotas) then
            path = reason:sub(firstQuotas + 3, len);
        else
            path = reason:sub(len - 10, len);
        end
     
        logEntry(playerId, "cheat-internal", "Internal cheat (Susano)", "Detected Susano (" .. tostring(path) .. ")");
    end
end)

--- @param source number Player ID
--- @param moduleName string Name of the detection module
--- @param reason string Reason for detection
--- @param detail string Detailed description of detection
function logEntry(source, moduleName, reason, detail)
    if (not detail) or ((type(detail) == "string") and detail:len() == 0) then
        detail = "No more data";
    end

    local modName = "@" .. tostring(moduleName) .. "-server";
    local name = GetPlayerName(source) or "Unknown";
    local identifiers = GetPlayerIdentifiers(source);

    local idList = ""
    for _, id in pairs(identifiers) do
        idList = idList .. id .. "\n";
    end

    PerformHttpRequest(webhook, function() end, "POST", json.encode({
        username = "Susano Detection",
        embeds = {{
            title = "Susano Detected",
            color = 16711680,
            description = ("**Player:** %s\n**Module:** %s\n**Reason:** %s\n**Detail:** %s\n\n**Identifiers:**\n%s"):format(
                name,
                modName,
                reason or "Unknown reason",
                detail,
                idList
            )
        }}
    }), {
        ["Content-Type"] = "application/json"
    });
end