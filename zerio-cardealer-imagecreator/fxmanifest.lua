-- THIS IS ORIGINALLY MADE BY RENZUZU ALTHOUGH REWORKED BY ZERIO
fx_version 'cerulean'
games {'gta5'}

server_scripts {
	'@mysql-async/lib/MySQL.lua',	
	'config.lua',
	'server/server.lua'
}

client_scripts {		
	'client/client.lua'
}

dependency 'screenshot-basic'