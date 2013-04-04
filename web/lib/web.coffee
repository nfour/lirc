
io		= require 'socket.io'
lirc	= require '../../lib/lirc'
lance	= require 'lance'
cluster	= require 'cluster'

{merge, clone} = Object
{type} = Function

defaultCfg = require '../cfg/web'

module.exports	=
lirc.web		=
web				= (newCfg = {}) ->
	web.cfg = merge merge( {}, defaultCfg ), newCfg

	require './routing'
	web.server = server = lance.createServer()
	server.listen web.cfg.server.port, web.cfg.server.host

	web.io = io = io.listen web.server, web.cfg.io

	io.sockets.on 'connection', (socket) ->
		web.emit 'lirc', 'New web user connected'
		web.emit 'botinfo', web.getBotNames()

		lirc.bind web.listeners.input, socket

	return web

web.getBotNames = () ->
	botNames = []
	for key, bot of lirc.botnet.bots
		botNames.push bot.name or key

	return botNames

web.clients	= []
web.io		=
web.cfg		= undefined

web.listeners = {
	input: require './listeners/input'
}

require './buffer'
require './emitter'

lance.init require '../cfg/lance'

lance.templating.locals.site = require('../cfg/web').site
