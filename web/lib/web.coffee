
io		= require 'socket.io'
lirc	= require '../../lib/lirc'
lance	= require 'lance'
cluster	= require 'cluster'
fs		= require 'fs'

{merge, clone, typeOf} = lirc.utils

module.exports	=
lirc.web		=
web				= (newCfg = {}) ->
	web.cfg = cfg = merge web.cfg, newCfg

	# sets up routes
	require './routing'

	if cfg.server.method is 'socket' and not cfg.server.socket
		cfg.method = 'port'

	if cfg.server.method is 'port'
		cfg.server.url.root			= "http://#{cfg.server.host}:#{cfg.server.port}" if not cfg.server.url.root
		cfg.server.url.static		= cfg.server.url.root + '/static' if not cfg.server.url.static

	cleanSocket()

	web.server	=
	server		= lance.createServer()

	if cfg.server.method is 'socket'
		lance.listen cfg.server.socket
	else
		lance.listen cfg.server.port, cfg.server.host

	server.on 'listening', ->
		if cfg.server.method is 'socket' and cfg.server.socketPerms
			fs.chmod cfg.server.socket, cfg.server.server.socketPerms
		
		str = if cfg.server.method is 'socket' then cfg.server.socket else "#{cfg.server.host}:#{cfg.server.port}"
		console.log ">> Listening on [ #{str} ]"

	web.io = io.listen web.server, cfg.io

	# for each new web user this is called
	web.io.sockets.on 'connection', (socket) ->
		web.emit.client socket, 'botinfo', web.getBotNames()

		web.emit 'lirc', {
			time: new Date().getTime()
			text: "New web user [ #{socket.id} ] connected"
		}

		lirc.bind web.listeners.input, socket

	return web

web.cfg = require '../cfg/web'

web.utils = lirc.utils

web.getBotNames = () ->
	botNames = []
	for key, bot of lirc.botnet.bots
		continue if not bot.name
		botNames.push bot.name

	return botNames

web.clients	= []
web.io		= undefined

web.listeners = {
	input: require './listeners/input'
}

cleanSocket = ->
	cfg = web.cfg.server
	return false if cfg.method isnt 'socket'

	if fs.existsSync cfg.socket
		fs.unlinkSync cfg.socket

		console.log ">> Socket cleaned [ #{cfg.socket} ]"

		return true

require './buffer'
require './emitter'

lance require '../cfg/lance'

lance.templating.locals = require('../cfg/web')

module.exports = web
