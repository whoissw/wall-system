--- Logs a message with a specific type and color.
---@param _type string The type of the log message ("success" or "error").
---@param log string The log message to print.
function VersionLog(_type,log)
    local color = _type == "success" and "^2" or "^1"
    print(("^8[wall]%s %s^7"):format(color,log))
end

--- Checks the current version of the menu against the latest version available on GitHub.
---@return void
function CheckMenuVersion()
    local url = "https://raw.githubusercontent.com/whoissw/wall-system/main/version.txt"
    PerformHttpRequest(url,function(err,text,headers)
        local currentVersion = GetResourceMetadata(GetCurrentResourceName(),"version")

        if not text then
            VersionLog("error","Currently unable to run a version check.")
            return
        end

        VersionLog("success",("Current Version: %s"):format(currentVersion))
        VersionLog("success",("Latest Version: %s"):format(text))

        if text:gsub("%s+","") == currentVersion:gsub("%s+","") then
            VersionLog("success","You are running the latest version.")
        else
            VersionLog("error",("You are currently running an outdated version: %s"):format(text))
        end
    end)
end

-- Initiates the version check.
CheckMenuVersion()