 

fx_version 'cerulean'
game 'gta5'

author 'Ken Mondragon'
description 'DMV Driving School System V2 with Theory Tests and Multiple Vehicles'
version '2.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',  
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

 escrow_ignore {
    'config.lua',
 
}


lua54 'yes'

dependency '/assetpacks'