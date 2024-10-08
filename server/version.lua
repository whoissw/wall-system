--- Reads the local version from the version.txt file.
---@return string|nil The local version or nil if the file cannot be read.
function readLocalVersion()
    local file = io.open("version.txt","r")
    if not file then
        return nil
    end
    local version = file:read("*a")
    file:close()
    return version:match("^%s*(.-)%s*$")
end

--- URL of the remote version file on GitHub.
---@type string
local remoteVersionUrl = "https://raw.githubusercontent.com/whoissw/wall-system/main/version.txt"

--- The local version read from the version.txt file.
---@type string|nil
local localVersion = readLocalVersion()
if not localVersion then
    print("Erro ao ler a versão local.")
    return
end

--- Compares the local and remote versions and prints the result.
---@param localVersion string The local version.
---@param remoteVersion string The remote version.
---@return void
function compareVersions(localVersion,remoteVersion)
    if localVersion == remoteVersion then
        print("O sistema está atualizado. Versão: "..localVersion)
    else
        print("O sistema está desatualizado. Versão local: "..localVersion..", Versão remota: "..remoteVersion)
    end
end

--- Performs an HTTP request to get the remote version and compares it with the local version.
---@return void
PerformHttpRequest(remoteVersionUrl,function(statusCode,response,headers)
    if statusCode == 200 then
        local remoteVersion = response:match("^%s*(.-)%s*$")
        compareVersions(localVersion,remoteVersion)
    else
        print("Erro ao obter a versão remota. Status code: "..statusCode)
    end
end,"GET","",{ ["Content-Type"] = "text/plain" })