
net		= require 'net'
tls		= require 'tls'
crypto	= require 'crypto'
path	= require 'path'
lance	= require 'lance'
cluster = require 'cluster'
fs		= require 'fs'

{merge, clone} = Object
{type, empty} = Function

defaultCfg = require '../cfg/lirc'

module.exports	=
lirc			= (newCfg = {}) ->
	lirc.cfg = merge clone( defaultCfg ), newCfg

	lirc.session.build lirc.cfg

	if cluster.isWorker
		lirc.botnet.emit.master {
			cmd: 'botnet.info'
			args: {
				name: lirc.session.me
				cfg	: lirc.cfg
				id	: cluster.worker.id
			}
		}

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

lirc.connect = (newCfg, done = ->) ->
	if not lirc.cfg
		if type( newCfg ) is 'object'
			lirc newCfg
		else
			return done 'Lirc not initialized', null

	{cfg, session} = lirc

	# normal connection
	if not cfg.server.secure
		lirc.session.conn	=
		conn				= net.createConnection cfg.server

		conn.on 'connect', () ->
			conn.connected = true
			lirc.auth()

		lirc.connect.configure conn
		lirc.bind lirc.listeners.irc, conn

		done null, conn
	# secure connection
	else
		keygen = require('ssl-keygen').createKeyGen()

		keygen.createKey 'ssl_key', (err, key) =>
			keygen.createCert 'ssl_key', (err, cert) =>

				key = fs.readFileSync '/home/node/lirc/certs/ssl_key.key', 'utf8'
				cert = fs.readFileSync '/home/node/lirc/certs/ssl_key.crt', 'utf8'

				creds = crypto.createCredentials {
					key: key
					cert: cert
				}

				lirc.session.conn	=
				conn				= tls.connect {
					port: cfg.server.port
					host: cfg.server.host
					key: creds.key
					passphrase: creds.passphrase or null
					pfx: creds.pfx
					ca: creds.ca
					cert: creds.cert

					rejectUnauthorized: false
				}, () =>
					if not conn.authorized and not (
						conn.authorizationError is 'DEPTH_ZERO_SELF_SIGNED_CERT' or
						conn.authorizationError is 'UNABLE_TO_VERIFY_LEAF_SIGNATURE'
					)
						return done 'Connection failed, unauthorized', null

					lirc.auth()

					conn.connected = true

					done null, conn

				lirc.connect.configure conn
				lirc.bind lirc.listeners.irc_secure, conn


lirc.connect.configure = (conn) ->
	conn.setTimeout lirc.cfg.timeout
	conn.setEncoding lirc.cfg.encoding
	conn.setKeepAlive true, lirc.cfg.keepAlive

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

lirc.listeners = {
	irc			: require './listeners/irc'
	irc_secure	: require './listeners/irc_secure'
}

lirc.mappings = {
	parsing	: require './mappings/parsing'
	actions	: require './mappings/actions'
}

# Each module below extends lirc on it own

require './format'
require './parse'
require './emitter'
require './session'
require './commands'
require './botnet/botnet'

if cluster.isMaster
	lirc.web = require '../web'
else
	# set up some worker relaying
	workerId = cluster.worker.id

	lirc.on 'raw', (data) ->
		lirc.botnet.emit.master {
			cmd	: 'emit.web'
			args: ['raw', [data]]
		}

	lirc.on 'msg', (msg) ->
		lirc.botnet.emit.master {
			cmd	: 'emit.web'
			args: ['msg', [msg]]
		}


module.exports = lirc







