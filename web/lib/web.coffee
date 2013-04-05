
io		= require 'socket.io'
lirc	= require '../../lib/lirc'
lance	= require 'lance'
cluster	= require 'cluster'
fs		= require 'fs'

{merge, clone} = Object
{type} = Function

defaultCfg = require '../cfg/web'

module.exports	=
lirc.web		=
web				= (newCfg = {}) ->
	web.cfg	= merge clone( defaultCfg ), newCfg
	cfg		= web.cfg.server

	# sets up routes
	require './routing'

	if cfg.method is 'socket' and not cfg.socket
		cfg.method = 'port'

	cleanSocket()

	web.server	=
	server		= lance.createServer()

	if cfg.method is 'socket'
		lance.listen cfg.socket
	else
		lance.listen cfg.port, cfg.host

	server.on 'listening', ->
		if cfg.method is 'socket' and cfg.socketPerms
			fs.chmod cfg.socket, cfg.socketPerms
		
		str = if cfg.method is 'socket' then cfg.socket else "#{cfg.host}:#{cfg.port}"
		console.log ">> Listening on [ #{str} ]"

	web.io = io.listen web.server, web.cfg.io

	# for each new web user this is called
	web.io.sockets.on 'connection', (socket) ->
		web.emit.client socket, 'botinfo', web.getBotNames()

		web.emit 'lirc', {
			time: new Date().getTime()
			text: "New web user [ #{socket.id} ] connected"
		}

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

cleanSocket = ->
	cfg = web.cfg.server
	return false if cfg.method isnt 'socket'

	if fs.existsSync cfg.socket
		fs.unlinkSync cfg.socket

		console.log ">> Socket cleaned [ #{cfg.socket} ]"

		return true
