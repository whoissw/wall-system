game "gta5"
fx_version "cerulean"
version "1.0.1"
author "swervin_"
description "A simple script that allows you view all players in the server."

ui_page "web-side/index.html"

server_scripts {
    "@vrp/lib/utils.lua",
    "server/*"
}

client_scripts {
    "@vrp/lib/utils.lua",
    "client/*"
}

files {
    "web-side/*"
}