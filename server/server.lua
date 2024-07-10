RegisterNetEvent("zerio-cardealer-imagecreator:getinfo")
AddEventHandler("zerio-cardealer-imagecreator:getinfo", function()
  if Config.DiscordWebHook ~= nil and Config.DiscordWebHook ~= "" then
    TriggerClientEvent("zerio-cardealer-imagecreator:getinfo", source,
      { url = Config.DiscordWebHook, type = "files", authKey = nil })
  elseif Config.FiveManageKey ~= nil and Config.FiveManageKey ~= "" then
    TriggerClientEvent("zerio-cardealer-imagecreator:getinfo", source,
      { url = "https://api.fivemanage.com/api/image", type = "image", authKey = Config.FiveManageKey })
  elseif Config.FiveMerrKey ~= nil and Config.FiveMerrKey ~= "" then
    TriggerClientEvent("zerio-cardealer-imagecreator:getinfo", source,
      { url = "https://api.fivemerr.com/v1/media/images", type = "file", authKey = Config.FiveMerrKey, encoding = "png" })
  end
end)

RegisterNetEvent("zerio-cardealer-imagecreator:getcars")
AddEventHandler("zerio-cardealer-imagecreator:getcars", function()
  local src = source
  exports["oxmysql"]:query("SELECT * FROM `zerio_cardealer-vehicles` WHERE `image` = ''", function(result)
    if result then
      local data = {}
      for i, v in pairs(result) do
        data[i] = {
          model = v.model,
        }
      end
      TriggerClientEvent("zerio-cardealer-imagecreator:importcars", src, data)
    end
  end)
end)

RegisterNetEvent("zerio-cardealer-imagecreator:save")
AddEventHandler("zerio-cardealer-imagecreator:save", function(data)
  exports["oxmysql"]:query(
    "UPDATE `zerio_cardealer-vehicles` SET `image` = ? WHERE `model` = ?",
    { data.img, data.model }
  )
end)
