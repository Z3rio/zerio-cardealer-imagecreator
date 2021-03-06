-- THIS IS ORIGINALLY MADE BY RENZUZU ALTHOUGH REWORKED BY ZERIO
local resultVehicles
local thumbs = {}

RegisterCommand('getperms', function(source, args, rawCommand)
    for i = 0 , GetNumPlayerIdentifiers(source) do
        if GetPlayerIdentifier(source,i) and Config.Admins[GetPlayerIdentifier(source,i)] then
            local ply = Player(source).state
            ply.screenshotperms = true
            print("You have access to using the image creator\n^4Commands List: \n^1/startscreenshot - Start taking all the images\n/resetscreenshot - Reset screenshot index (last vehicle number for continuation purpose)")
        end
    end
end)

RegisterNetEvent("zerio-cardealer-imagecreator:getcars")
AddEventHandler("zerio-cardealer-imagecreator:getcars", function()
    local src = source
    exports["oxmysql"]:query("SELECT * FROM `zerio_cardealer-vehicles` WHERE `image` = ''", function(result)
        if result then
            local data = {}
            for i,v in pairs(result) do
                data[i] = {
                    model = v.model
                }
            end
            TriggerClientEvent("zerio-cardealer-imagecreator:importcars", src, data)
        end
    end)
end)

RegisterNetEvent("zerio-cardealer-imagecreator:save")
AddEventHandler("zerio-cardealer-imagecreator:save", function(data)
    exports["oxmysql"]:query(string.format("UPDATE `zerio_cardealer-vehicles` SET `image` = '%s' WHERE `model` = '%s'", data.img, data.model))
end)
