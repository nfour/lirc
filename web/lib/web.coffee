
io		= require 'socket.io'
lirc	= require '../../lib/lirc'
lance	= require 'lance'
cluster	= require 'cluster'

{merge, clone} = Object
{type} = Function

defaultCfg = require '../cfg/web'

module.exports	=
web				= (newCfg = {}) ->
	web.cfg = merge merge( {}, defaultCfg ), newCfg

	require './routing'
	web.server = server = lance.createServer()
	server.listen web.cfg.server.port, web.cfg.server.host

	console.log 'Server up,', web.cfg.server.port, web.cfg.server.host

	# socket.io, connection to the frontend

	web.io = io = io.listen web.server, web.cfg.io

	io.sockets.on 'connection', (socket) ->
		console.log 'Web, new user'

		web.clients.push socket # todo: remove from client list on disconnect or timeout

		web.send.botinfo()

		socket.emit 'input', ' - Connected' # change this to event "sys" or something
		lirc.bind web.listeners.input, socket

	lirc.bind web.listeners.web, web

	return web

web.start	= web

web.send = (workerId, args) ->
	return false if not web.io?.sockets?

	args = web.send.parseArgs workerId, args

	if args
		web.io.sockets.emit.apply web.io.sockets, args

web.send.parseArgs = (workerId = 0, args = []) ->
	botName = workerId

	if lirc.botnet.bots[ workerId ]?.name?
		botName	= lirc.botnet.bots[ workerId ].name

	eventName	= args[0]
	args		= if 1 of args then args[1..] else []

	return false if not eventName or not botName?

	return [eventName, botName].concat args

web.send.botinfo = () ->
	botNames = []
	for key, bot of lirc.botnet.bots
		botNames.push bot.name or key

	args = ['botinfo', botNames]

	web.send 0, args

web.clients	= []
web.io		=
web.cfg		= undefined

web.listeners = {
	input	: require './listeners/input'
	web		: require './listeners/web'
}

require './emitter'

lance.init require '../cfg/lance'

lance.templating.locals = require '../cfg/site'

lirc.web		=
module.exports	= web