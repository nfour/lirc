
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

		web.clients.push socket # remove from client list on disconnect

		socket.emit 'input', ' - Connected' # change this to event "sys" or something
		lirc.bind web.listeners.input, socket

	lirc.bind web.listeners.lirc, lirc
	lirc.bind web.listeners.botnet, lirc.botnet

	return web

web.start	= web

web.clients	= []
web.io		=
web.cfg		= undefined

web.listeners = {
	input	: require './listeners/input'
	botnet	: require './listeners/botnet'
	lirc	: require './listeners/lirc'
}

require './emitter'

lance.init require '../cfg/lance'

lance.templating.locals = require '../cfg/site'

lirc.web		=
module.exports	= web