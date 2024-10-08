----------------------------------------------------------------------------------------------------
-- vRP
----------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")

src = {}
Tunnel.bindInterface("wall",src)
----------------------------------------------------------------------------------------------------
-- Variables
----------------------------------------------------------------------------------------------------
---@type boolean
local WallStatus = false
---@type boolean
local LineStatus = false
---@type number
local MaxDistance = 300
---@type table
local VehicleOffsets = {
    [-1] = { -1.2,1.2 },
    [0] = { 1.2,1.2 },
    [1] = { -1.2,0.0 },
    [2] = { 1.2,0.0 },
    [3] = { -1.2,-1.2 },
    [4] = { 1.2,-1.2 },
    [5] = { -1.2,-2.4 },
    [6] = { 1.2,-2.4 }
}
---@type table
local WallConfig = {
    Source = false,
    Passport = true,
    Names = true,
    Jobs = true,
    Health = true,
    Vehicle = true,
    Lines = false
}

--- Toogle wall from server
---@param status boolean
---@return void
function src.ToogleWall(status)
    if status then
        WallStatus = true
        CreateBlips()
    else
        WallStatus = false
    end
end

--- Create Blips.
---@return void
function CreateBlips()
    CreateThread(function()
        while WallStatus do
            local PlayerPedId = PlayerPedId()
            local Players     = GetActivePlayers()

            for k,v in pairs(Players) do
                local PlayerPed      = GetPlayerPed(v)
                local PlayerServerId = GetPlayerServerId(v)

                if not PlayerServerId or PlayerPed == 0 or not IsPedAPlayer(PlayerPed) or not DoesEntityExist(PlayerPed) then goto Skip end
                if v == PlayerId() then goto Skip end

                local PedCoords     = GetEntityCoords(PlayerPed)
                local DistanceToPed = #(PedCoords - GetEntityCoords(PlayerPedId))

                if not PedCoords then goto Skip end

                if WallConfig["Lines"] then
                    local currentTime = GetGameTimer()
                    local hue         = (currentTime % 30000) / 15000.0
                    local r,g,b       = HSVToRGB(hue,1,1)
                    local cx,cy,cz    = table.unpack(GetEntityCoords(PlayerPedId))
                    local x,y,z       = table.unpack(GetEntityCoords(PlayerPed))

                    DrawLine(cx,cy,cz,x,y,z,r,g,b,255)
                end

                if not Player(PlayerServerId)["state"]["_wall"] then
                    local VehicleOffset,VehicleSeat = GetPedVehicleOffset(PlayerPed)
                    local x = (VehicleSeat and VehicleOffset.x or PedCoords.x)
                    local y = (VehicleSeat and VehicleOffset.y or PedCoords.y)
                    local z = PedCoords.z + 1.0

                    DrawTopText3D(x,y,z,("\n SOURCE: [~g~"..PlayerServerId.."~w~]") or "")

                    goto Skip
                end

                if DistanceToPed > MaxDistance then goto Skip end

                local PlayerName = (IsEntityVisible(PlayerPed) and "~w~" or "~r~")..""..Player(PlayerServerId)["state"]["_wall"][2].."~w~"
                local PlayerInvencible = GetPlayerInvincible(v) and " [~r~GODMODE~w~]" or ""
                local PlayerHealth = GetEntityHealth(PlayerPed) > 101 and "~g~"..PlayerHealth.."~w~"..PlayerInvencible or "~r~MORTO~w~"
                local PlayerArmor = "~b~"..GetPedArmour(PlayerPed).."~w~"

                local SideText = ""
                if Player(PlayerServerId)["state"]["_wall"][3] then
                    SideText = Player(PlayerServerId)["state"]["_wall"][3][1] or "Desempregado"
                end

                local Wall = ""
                if Player(PlayerServerId)["state"]["_wallStatus"] then
                    Wall = "\n[~g~WALL~w~]"
                end

                local SourceText                = (WallConfig["Source"] and "\n SOURCE: [~g~"..PlayerServerId.."~w~]") or ""
                local VehicleOffset,VehicleSeat = GetPedVehicleOffset(PlayerPed)
                local x                         = (VehicleSeat and VehicleOffset.x or PedCoords.x)
                local y                         = (VehicleSeat and VehicleOffset.y or PedCoords.y)
                local z                         = PedCoords.z + 1.0

                local TopText                   = (WallConfig["Passport"] and "[~o~"..Player(PlayerServerId)["state"]["_wall"][1].."~w~] " or "")..(WallConfig["Names"] and PlayerName or "")..(WallConfig["Jobs"] and " ("..SideText..") " or "")..(NetworkIsPlayerTalking(v) and "\n~y~FALANDO~w~" or "")
                local BottomText                = (WallConfig["Health"] and PlayerHealth.." | "..PlayerArmor.."" or "")..SourceText..""..Wall..(WallConfig["Vehicle"] and (VehicleSeat and "\n~y~P"..(VehicleSeat + 2).."~w~" or "") or "")

                DrawTopText3D(x,y,z,TopText)
                DrawBottomText3D(x,y,z - 1.2,BottomText,DistanceToPed)

                ::Skip::
            end

            Wait(1)
        end
    end)
end

--- Get ped vehicle offset.
---@param Ped number
---@return table
---@return number | boolean
function GetPedVehicleOffset(Ped)
    local PedSeat = -2
    if not Ped or not DoesEntityExist(Ped) or not IsEntityAPed(Ped) or not IsPedAPlayer(Ped) then
        goto finish
    end

    if GetVehiclePedIsIn(Ped,false) ~= 0 then
        local Vehicle = GetVehiclePedIsIn(Ped,false)
        if not Vehicle or not DoesEntityExist(Vehicle) or not IsEntityAVehicle(Vehicle) then
            goto finish
        end
    end

    for i = -1,6 do
        if GetPedInVehicleSeat(GetVehiclePedIsIn(Ped,false),i) == Ped then
            PedSeat = i
            break
        end
    end

    if PedSeat ~= -2 and VehicleOffsets[PedSeat] then
        return GetOffsetFromEntityInWorldCoords(GetVehiclePedIsIn(Ped,false),VehicleOffsets[PedSeat][1],VehicleOffsets[PedSeat][2],0.0),PedSeat
    end

    ::finish::
    return { 0.0,0.0 },false
end

--- HSV to RGB.
---@param h number
---@param s number
---@param v number
---@return number,number,number
function HSVToRGB(h,s,v)
    local r,g,b

    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)

    i = i % 6

    if i == 0 then
        r,g,b = v,t,p
    elseif i == 1 then
        r,g,b = q,v,p
    elseif i == 2 then
        r,g,b = p,v,t
    elseif i == 3 then
        r,g,b = p,q,v
    elseif i == 4 then
        r,g,b = t,p,v
    else
        r,g,b = v,p,q
    end

    return math.floor(r * 255),math.floor(g * 255),math.floor(b * 255)
end

--- Draws the text in 3D.
---@param x number
---@param y number
---@param z number
---@param text string
---@return void
function DrawTopText3D(x,y,z,text)
    local onScreen,_x,_y = World3dToScreen2d(x,y,z)

    if onScreen then
        SetTextScale(0.35,0.35)
        SetTextFont(4)
        SetTextDropShadow(1,0,0,0,255)
        SetTextOutline()
        SetTextProportional(1)
        SetTextColour(255,255,255,215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

--- Draws the text in 3D.
--- @param x number
--- @param y number
--- @param z number
--- @param text string
--- @param Distance number
function DrawBottomText3D(x,y,z,text,Distance)
    local Newz = 0.22
    if Distance > 10 then
        Newz = 0.35
        Newz = Newz + (Distance / 100)
    end
    local onScreen,_x,_y = World3dToScreen2d(x,y,z - Newz)

    if onScreen then
        SetTextScale(0.35,0.35)
        SetTextFont(4)
        SetTextDropShadow(1,0,0,0,255)
        SetTextOutline()
        SetTextProportional(1)
        SetTextColour(255,255,255,215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

RegisterCommand("cwall",function(_,args)
    SetNuiFocus(true,true)
    SendNUIMessage({ action = "show" })
end)

--- Close the NUI
---@return void
RegisterNuiCallback("HideWall",function(Data,Callback)
    SetNuiFocus(false,false)
    SendNUIMessage({ action = "hide" })
    Callback("ok")
end)

--- Get status of options in wall
---@return void
RegisterNuiCallback("GetStatus",function(Data,Callback)
    local Payload = {
        id = WallConfig["Passport"],
        source = WallConfig["Source"],
        names = WallConfig["Names"],
        jobs = WallConfig["Jobs"],
        health = WallConfig["Health"],
        vehicle = WallConfig["Vehicle"],
        lines = WallConfig["Lines"],
        maxDistance = MaxDistance
    }

    Callback(Payload)
end)

--- Update status of options in wall
---@return void
RegisterNuiCallback("UpdateStatus",function(Data,Callback)
    WallConfig["Passport"] = Data["id"]
    WallConfig["Source"] = Data["source"]
    WallConfig["Names"] = Data["names"]
    WallConfig["Jobs"] = Data["jobs"]
    WallConfig["Health"] = Data["health"]
    WallConfig["Vehicle"] = Data["vehicle"]
    WallConfig["Lines"] = Data["lines"]
    MaxDistance = parseInt(Data["maxDistance"])

    SetNuiFocus(false,false)
    SendNUIMessage({ action = "hide" })

    Callback("ok")
end)