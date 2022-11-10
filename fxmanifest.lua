fx_version 'cerulean'

game 'gta5' shared_script '@renzu_shield/init.lua'
ui_page {
    'html/index.html',
}
client_scripts {
	'config.lua',
	'client/main.lua'
}

server_scripts {
	'config.lua',
	'server/main.lua'
}