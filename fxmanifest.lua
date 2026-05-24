fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'

description 'snow_goldpan'
version '0.0.1'
author 'Snow-Customs'

client_scripts {
	'client/client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
	'server/server.lua',
}

shared_scripts {
    'shared/keys.lua',
    'shared/locale.lua',
    'config.lua',
    'languages/*.lua',
}

dependency 'vorp_core'

lua54 'yes'
