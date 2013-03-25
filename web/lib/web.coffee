
io		= require 'socket.io'
lirc	= require '../../lib/lirc'
lance	= require 'lance'
cluster	= require 'cluster'

{merge, clone} = Object
{type} = Function

defaultCfg = require '../cfg/web'

module.exports =
lirc.web =
web = (newCfg = {}) ->
	web.cfg = merge merge( {}, defaultCfg ), newCfg

	require './routing'
	web.server = server = lance.createServer()
	server.listen web.cfg.server.port, web.cfg.server.host

	console.log 'Server up,', web.cfg.server.port, web.cfg.server.host

	web.io = io = io.listen web.server, web.cfg.io

	io.sockets.on 'connection', (socket) ->
		console.log '[WEB] New user'

		web.clients.push socket # todo: remove from client list on disconnect or timeout
		console.log lirc.botnet.bots
		web.emit 0, ['botinfo', web.getBotNames()]

		socket.emit 'input', ' - Connected' # change this to event "sys" or something
		lirc.bind web.listeners.input, socket

	lirc.bind web.listeners.web, web

	return web

web.getBotNames = () ->
	botNames = []
	for key, bot of lirc.botnet.bots
		botNames.push bot.name or key

	return botNames

web.start = web

web.clients	= []
web.io		=
web.cfg		= undefined

web.listeners = {
	input	: require './listeners/input'
	web		: require './listeners/web'
}

require './emitter'

lance.init require '../cfg/lance'

lance.templating.locals.site = require('../cfg/web').site
