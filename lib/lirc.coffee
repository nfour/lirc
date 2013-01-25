
net		= require 'net'
tls		= require 'tls'
crypto	= require 'crypto'
path	= require 'path'
lance	= require 'lance'
cluster = require 'cluster'

{merge, clone} = Object
{type, empty} = Function

defaultCfg = require '../cfg/lirc'

module.exports	=
lirc			= (newCfg = {}, doConnect = false) ->
	lirc.cfg = merge clone( defaultCfg ), newCfg

	lirc.session.build lirc.cfg

	if doConnect
		return lirc.connect()

	if cluster.isWorker
		lirc.botnet.send.master 'botinfo', [lirc.session.me, lirc.cfg, cluster.worker.id]

	return lirc

lirc.cfg = null

lirc.error = (type, scope = '', msg...) ->
	if arguments.length >= 3
		result = "!! #{type} in #{scope}: #{ msg.join ' ' }"
	else if arguments.length is 2
		result = "!! #{arguments[0]} in #{scope}"
	else if arguments.length is 1
		result = "!! #{arguments[0]}"
	
	console.error result
	
	return result

lirc.connect = (newCfg) ->
	if not lirc.cfg
		if type( newCfg ) is 'object'
			lirc newCfg
		else
			return lirc.error 'Error', 'Lirc.connect', 'Lirc not initialized'

	{cfg, session} = lirc

	# normal connection
	if not cfg.server.secure
		lirc.session.conn	=
		conn				= net.createConnection cfg.server

		conn.setTimeout cfg.timeout
		conn.setEncoding cfg.encoding
		conn.setKeepAlive true, cfg.keepAlive

	# secure connection
	else
		{port, host} = cfg.server

		keygen = require('ssl-keygen').createKeyGen()

		console.log 'keygen{{'
		console.log keygen
		console.log '}}'

		keygen.createKey 'ssl_key', (key) ->
			console.log 'key', key
			keygen.createCert 'ssl_key', (cert) ->
				console.log 'key', cert
		return 1
		creds = crypto.createCredentials()
		console.log 'key', key
		console.log 'cert', cert
		console.log 'creds', creds
		lirc.session.conn	=
		conn				= tls.connect port, host, creds, () ->

			console.log 'authorized', conn.authorized
			console.log 'authorizationError', conn.authorizationError

			# fix the session variable and config merging for selfSigned etc.

			if not conn.authorized
				if cfg.server.selfSigned and (
					conn.authorizationError is 'DEPTH_ZERO_SELF_SIGNED_CERT' or
					conn.authorizationError is 'UNABLE_TO_VERIFY_LEAF_SIGNATURE'
				)
					lirc.auth()

				else if not cfg.server.useExpiredCert and conn.authorizationError is 'CERT_HAS_EXPIRED'
					throw lirc.error 'Error', 'lirc.connect tls', 'SSL connection failure, CERT_HAS_EXPIRED,', conn.authorizationError
				else
					throw lirc.error 'Error', 'lirc.connect tls', 'SSL connection failure', conn.authorizationError
		
			lirc.emit 'connect'

		conn.connected = true
		conn.setTimeout cfg.timeout
		conn.setEncoding cfg.encoding
		conn.setKeepAlive true, cfg.keepAlive
	
	lirc.bind lirc.listeners.irc, conn

	return conn

lirc.auth = (user) ->
	{user} = lirc.session.server if not user

	userStr = [
		user.username
		user.hostname or user.username
		user.server or user.username
		':' + user.realname
	].join ' '

	if user.pass
		lirc.send 'PASS', user.pass

	lirc.send 'NICK', user.nick
	lirc.send 'USER', userStr

# Extend lirc

lirc.listeners = {
	irc: require './listeners/irc'
}

lirc.mappings = {
	parsing			: require './mappings/parsing'
	actions			: require './mappings/actions'
}

# Each module below extends lirc on it own

require './format'
require './parse'
require './emitter'
require './session'
require './commands'
require './botnet/botnet'
require '../web' if cluster.isMaster

module.exports = lirc







