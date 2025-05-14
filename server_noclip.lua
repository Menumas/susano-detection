RegisterServerEvent("noclip/detected", function (data)
    local playerId <const> = source
    local name = GetPlayerName(playerId) or "Unknown"
    local identifiers = GetPlayerIdentifiers(playerId)

    local idList = ""
    for _, id in pairs(identifiers) do
        idList = idList .. id .. "\n"
    end

    PerformHttpRequest("https://webhook-url", function() end, "POST", json.encode({
        username = "Noclip Detected",
        embeds = {{
            title = "Noclip Flag Detected",
            color = 16711680,
            description = ("**Player:** %s\n**Reason:** %s\n**Detail:** %s\n\n**Identifiers:**\n%s"):format(
                name,
                data.reason or "Unknown",
                data.detail or "No detail",
                idList
            ),
            image = {
                url = data.image or ""
            }
        }}
    }), {
        ["Content-Type"] = "application/json"
    })
end)
