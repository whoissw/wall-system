----------------------------------------------------------------------------------------------------
-- vRP
----------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

vCLIENT = Tunnel.getInterface("wall")

src = {}
Tunnel.bindInterface("wall",src)

-----------------------------------------------------------------------------------------------------
-- Wall
-----------------------------------------------------------------------------------------------------
RegisterCommand("wall",function(source)
    local Passport = vRP.getUserId(source)

    if Passport and vRP.hasGroup(Passport,"Admin") then
        if Player(source)["state"]["_wallStatus"] then
            Player(source)["state"]:set("_wallStatus",false,true)
            TriggerClientEvent("Notify",source,"warning","Sistema de <b>wall</b> desativado.","Wall",8000)
        else
            Player(source)["state"]:set("_wallStatus",true,true)
            TriggerClientEvent("Notify",source,"success","Sistema de <b>wall</b> ativado.","Wall",8000)
        end

        vCLIENT.ToogleWall(source,Player(source)["state"]["_wallStatus"])
    end
end)

print("^2[SUCCESS]^7 Wall system loaded successfully.")