local screenshot = false
local cam = nil
local VehiclesFromDB = {}
local webhook = nil
local returncoord = nil

Citizen.CreateThread(function()
  RegisterNetEvent("zerio-cardealer-imagecreator:importcars")
  AddEventHandler("zerio-cardealer-imagecreator:importcars", function(result)
    VehiclesFromDB = result
  end)

  RegisterNetEvent("zerio-cardealer-imagecreator:getinfo")
  AddEventHandler("zerio-cardealer-imagecreator:getinfo", function(result)
    webhook = result
  end)

  TriggerServerEvent("zerio-cardealer-imagecreator:getcars")
  TriggerServerEvent("zerio-cardealer-imagecreator:getinfo")

  Wait(500)

  RegisterCommand("startscreenshot", function()
    if screenshot == false then
      StartScreenShoting()
      screenshot = true
    else
      screenshot = false
      if returncoord then
        SetEntityCoords(ped, returncoord.x, returncoord.y, returncoord.z)
      end
    end
  end, false)

  local inshell = false
  function InShowRoom(bool)
    Citizen.CreateThread(function()
      if bool then
        inshell = true
        while inshell do
          Citizen.Wait(0)
          NetworkOverrideClockTime(22, 00, 00)
        end
      else
        inshell = false
      end
    end)
  end

  local fov = 40.0

  function ClassList(class)
    local name

    if class == "0" then
      name = 40.0
    elseif class == "1" then
      name = 40.0
    elseif class == "2" then
      name = 45.0
    elseif class == "3" then
      name = 40.0
    elseif class == "4" then
      name = 40.0
    elseif class == "5" then
      name = 40.0
    elseif class == "6" then
      name = 40.0
    elseif class == "7" then
      name = 41.0
    elseif class == "8" then
      name = 30.0
    elseif class == "9" then
      name = 45.0
    elseif class == "10" then
      name = 45.0
    elseif class == "11" then
      name = 45.0
    elseif class == "12" then
      name = 45.0
    elseif class == "13" then
      name = 30.0
    elseif class == "14" then
      name = 40.0
    elseif class == "15" then
      name = 48.0
    elseif class == "16" then
      name = 60.0
    elseif class == "17" then
      name = 45.0
    elseif class == "18" then
      name = 44.0
    elseif class == "19" then
      name = 44.0
    elseif class == "20" then
      name = 45.0
    elseif class == "21" then
      name = 70.0
    else
      name = 40.0
    end
    return name
  end

  function GetFovVehicle(vehicle)
    local class = tostring(GetVehicleClass(vehicle))
    return ClassList(class)
  end

  local maxscreenshotnumber = 0

  function StartScreenShoting()
    InShowRoom(true)
    local ped = PlayerPedId()
    if ped then
      returncoord = GetEntityCoords(ped)
      screenshot = true
      FreezeEntityPosition(ped, true)
      CreateLocation()
      while not IsIplActive("xs_arena_interior") do
        Wait(0)
      end

      RequestCollisionAtCoord(2800.5966796875, -3799.7370605469, 139.41514587402)
      vec = vector3(2800.5966796875, -3799.7370605469, 139.41514587402)
      cam = CreateCamWithParams(
        "DEFAULT_SCRIPTED_CAMERA",
        2800.5966796875 - 4.0,
        -3799.7370605469 - 4.0,
        140.9514587402,
        360.00,
        0.00,
        0.00,
        60.00,
        false,
        0
      )
      if cam then
        PointCamAtCoord(cam, 2800.5966796875, -3799.7370605469, 139.51514587402)
        SetCamActive(cam, true)
        SetCamFov(cam, 42.0)
        SetCamRot(cam, -15.0, 0.0, 252.063)
      end
      RenderScriptCams(true, true, 1, true, true)
      SetFocusPosAndVel(2800.5966796875, -3799.7370605469, 139.41514587402, 0.0, 0.0, 0.0)
      DisplayHud(false)
      DisplayRadar(false)
      Citizen.CreateThread(function()
        local coord = vector3(2800.5966796875, -3799.7370605469, 139.41514587402)
        while screenshot do
          Citizen.Wait(0)
          DrawLightWithRange(coord.x - 4.0, coord.y - 3.0, coord.z + 0.3, 255, 255, 255, 40.0, 15.0)
          DrawSpotLight(
            coord.x - 4.0,
            coord.y + 5.0,
            coord.z,
            coord,
            255,
            255,
            255,
            20.0,
            1.0,
            1.0,
            20.0,
            0.95
          )
        end
      end)
      Wait(2000)
      maxscreenshotnumber = #VehiclesFromDB
      for i, v in pairs(VehiclesFromDB) do
        print(tostring(i) .. "/" .. tostring(maxscreenshotnumber) .. ": " .. v.model)

        if screenshot == false then
          break
        end
        local hashmodel = GetHashKey(v.model)
        if hashmodel and IsModelInCdimage(hashmodel) ~= false then
          CreateMobilePhone(1)
          CellCamActivate(true, true)
          Citizen.Wait(100)
          SpawnVehicleLocal(v.model)
          if webhook then
            local wait = promise.new()

            exports["screenshot-basic"]:requestScreenshotUpload(webhook.url, webhook.type, {
              headers = {
                Authorization = webhook.authKey,
              },
              encoding = webhook.encoding
            }, function(data)
              local image = json.decode(data)
              DestroyMobilePhone()
              CellCamActivate(false, false)
              if image and image.url then
                TriggerServerEvent("zerio-cardealer-imagecreator:save", {
                  model = v.model,
                  img = image.url
                })
              elseif
                  image
                  and image.attachments
                  and image.attachments[1]
                  and image.attachments[1].proxy_url ~= nil
              then
                TriggerServerEvent("zerio-cardealer-imagecreator:save", {
                  model = v.model,
                  img = image.attachments[1].proxy_url,
                })
              else
                error("Seems like the image wasnt successfully uploaded")
              end

              wait:resolve()
            end)

            Citizen.Await(wait)
          end
        else
          print("Seems like this model is invalid")
        end
      end
      while screenshot do
        Citizen.Wait(111)
      end
      RenderScriptCams(false)
      DestroyAllCams(true)
      ClearFocus()
      if cam then
        SetCamActive(cam, false)
      end
      CellCamActivate(false, false)
      InShowRoom(false)
      SetEntityCoords(ped, returncoord.x, returncoord.y, returncoord.z)
      Wait(200)
      FreezeEntityPosition(ped, false)
    end
  end

  local arenacoord = vector4(2800.5966796875, -3799.7370605469, 139.41514587402, 244.5432434082)
  function CreateLocation()
    local ped = PlayerPedId()
    LoadArena()
    SetCoords(ped, arenacoord, 82.0, true)
  end

  function SetCoords(ped, x, y, z, h)
    RequestCollisionAtCoord(x, y, z)
    while not HasCollisionLoadedAroundEntity(ped) do
      RequestCollisionAtCoord(x, y, z)
      Citizen.Wait(1)
    end
    DoScreenFadeOut(950)
    Wait(1000)
    SetEntityCoords(ped, x + 5.0, y - 5.0, z)
    SetEntityHeading(ped, h)
    DoScreenFadeIn(3000)
  end

  ---------------------------------------------------------------------------------------
  --            Arena Resource by Titch2000 You may edit but please keep credit.
  ---------------------------------------------------------------------------------------
  -- config
  local map = 9
  local scene = "scifi"

  local maps = {
    ["dystopian"] = {
      "Set_Dystopian_01",
      "Set_Dystopian_02",
      "Set_Dystopian_03",
      "Set_Dystopian_04",
      "Set_Dystopian_05",
      "Set_Dystopian_06",
      "Set_Dystopian_07",
      "Set_Dystopian_08",
      "Set_Dystopian_09",
      "Set_Dystopian_10",
      "Set_Dystopian_11",
      "Set_Dystopian_12",
      "Set_Dystopian_13",
      "Set_Dystopian_14",
      "Set_Dystopian_15",
      "Set_Dystopian_16",
      "Set_Dystopian_17",
    },

    ["scifi"] = {
      "Set_Scifi_01",
      "Set_Scifi_02",
      "Set_Scifi_03",
      "Set_Scifi_04",
      "Set_Scifi_05",
      "Set_Scifi_06",
      "Set_Scifi_07",
      "Set_Scifi_08",
      "Set_Scifi_09",
      "Set_Scifi_10",
    },

    ["wasteland"] = {
      "Set_Wasteland_01",
      "Set_Wasteland_02",
      "Set_Wasteland_03",
      "Set_Wasteland_04",
      "Set_Wasteland_05",
      "Set_Wasteland_06",
      "Set_Wasteland_07",
      "Set_Wasteland_08",
      "Set_Wasteland_09",
      "Set_Wasteland_10",
    },
  }

  function UnloadArena()
    RemoveIpl("xs_arena_interior")
  end

  function LoadArena()
    RequestIpl("xs_arena_interior")
    RequestIpl("xs_arena_interior_vip")
    RequestIpl("xs_arena_banners_ipl")

    local interiorID = GetInteriorAtCoords(2800.000, -3800.000, 100.000)

    if interiorID then
      if not IsInteriorReady(interiorID) then
        Wait(1)
      end

      EnableInteriorProp(interiorID, "Set_Crowd_A")
      EnableInteriorProp(interiorID, "Set_Crowd_B")
      EnableInteriorProp(interiorID, "Set_Crowd_C")
      EnableInteriorProp(interiorID, "Set_Crowd_D")

      if scene == "dystopian" then
        EnableInteriorProp(interiorID, "Set_Dystopian_Scene")
        EnableInteriorProp(interiorID, maps[scene][map])
      end
      if scene == "scifi" then
        EnableInteriorProp(interiorID, "Set_Scifi_Scene")
        EnableInteriorProp(interiorID, maps[scene][map])
      end
      if scene == "wasteland" then
        EnableInteriorProp(interiorID, "Set_Wasteland_Scene")
        EnableInteriorProp(interiorID, maps[scene][map])
      end
    end
  end

  local loading = false
  LastVehicleFromGarage = nil
  function SpawnVehicleLocal(model)
    if loading or GetNumberOfStreamingRequests() > 0 then
      return
    end
    local ped = PlayerPedId()

    if not ped then
      return
    end

    if LastVehicleFromGarage ~= nil then
      ReqAndDelete(LastVehicleFromGarage)
    end
    for _i = 1, 2 do
      local coords = GetEntityCoords(ped)
      local nearveh = GetClosestVehicle(coords.x, coords.y, coords.z, 2.000, 0, 70)
      if nearveh then
        if DoesEntityExist(nearveh) then
          ReqAndDelete(nearveh)
        end
        while DoesEntityExist(nearveh) do
          ReqAndDelete(nearveh)
          Wait(100)
        end
      end
    end
    vec = vector3(2800.5966796875, -3799.7370605469, 139.41514587402)
    local hash = GetHashKey(model)

    if hash then
      local count = 0
      if not HasModelLoaded(hash) then
        RequestModel(hash)
        while not HasModelLoaded(hash) do
          count = count + 1
          Citizen.Wait(100)

          if count == 10 then
            error("Couldnt load vehicle " .. model)
            return
          end
        end
        loading = true
      end
      loading = false
      vec = vector3(2800.5966796875, -3799.7370605469, 139.41514587402)
      LastVehicleFromGarage = CreateVehicle(hash, vec.x, vec.y, vec.z, 90.0, false, true)

      if LastVehicleFromGarage then
        while not DoesEntityExist(LastVehicleFromGarage) do
          Wait(0)
        end
        local minDim, maxDim = GetModelDimensions(hash)
        local modelSize = maxDim - minDim
        local fovval = modelSize.x * modelSize.y * modelSize.z
        fov = fovval + 20
        if cam then
          SetCamFov(cam, fov)
        end
        SetEntityHeading(LastVehicleFromGarage, 80.117)
        FreezeEntityPosition(LastVehicleFromGarage, true)
        SetEntityCollision(LastVehicleFromGarage, false)
        SetVehicleDirtLevel(LastVehicleFromGarage, 0.0)
        local currentcar = LastVehicleFromGarage
        if currentcar ~= LastVehicleFromGarage then
          ReqAndDelete(LastVehicleFromGarage)
          SetModelAsNoLongerNeeded(hash)
        end
        SetModelAsNoLongerNeeded(hash)
        SetVehicleEngineOn(LastVehicleFromGarage, true, true, false)
        Wait(500)
      end
    end
  end

  function ReqAndDelete(object)
    if DoesEntityExist(object) then
      NetworkRequestControlOfEntity(object)
      local attempt = 0
      while not NetworkHasControlOfEntity(object) and attempt < 100 and DoesEntityExist(object) do
        NetworkRequestControlOfEntity(object)
        Citizen.Wait(11)
        attempt = attempt + 1
      end
      DetachEntity(object, false, false)
      SetEntityCollision(object, false, false)
      SetEntityAlpha(object, 0.0, true)
      SetEntityAsMissionEntity(object, true, true)
      SetEntityAsNoLongerNeeded(object)
      DeleteEntity(object)
    end
  end
end)
