
net		= require 'net'
tls		= require 'tls'
crypto	= require 'crypto'
path	= require 'path'
lance	= require 'lance'
cluster = require 'cluster'
fs		= require 'fs'

module.exports	=
lirc			= (newCfg = {}) ->
	lirc.cfg = cfg = merge lirc.cfg, newCfg

	lirc.session.build cfg

	lirc.rootDir = path.dirname __dirname

	if cluster.isWorker
		lirc.botnet.emit.master {
			cmd: 'botnet.info'
			args: {
				name: lirc.session.me
				cfg	: cfg
				id	: cluster.worker.id
			}
		}

	if cfg.ascii and cluster.isMaster
		console.log """
			\       __          
			\      / /__________
			\     / / / ___/___/
			\    / / / / / /__  
			\   /_/_/_/  \\___/  
			\                   
		"""
	
	if cfg.catchUncaught
		process.on 'uncaughtException', lirc.error

	return lirc

lirc.cfg = require '../cfg/lirc'
lirc.utils = lance.utils

{merge, clone, typeOf, empty} = lirc.utils

lirc.error = () ->
	error = lance.error.parse arguments

	console.error error.text
	lance.error.write error.text, lirc.rootDir

	if error.severity is 'fatal'
		if cluster.isMaster
			lirc.web.emit 'lirc', {
				text: error.text.replace /\n/g, '<br/>'
				time: new Date().getTime()
			}

			lirc.web.emit 'lirc', {
				text: 'Master error, killing Lirc...'
				time: new Date().getTime()
			}

			setTimeout process.kill, 5000
		else
			lirc.botnet.emit.master {
				cmd	: 'emit.web'
				args: ['lirc', [{
					text: error.text.replace /\n/g, '<br/>'
					time: new Date().getTime()
				}]]
			}

			setTimeout (->
				lirc.botnet.emit.master {
					cmd: 'restart'
					args: [lirc.session.me]
				}
			), 5000

			setTimeout (-> cluster.worker.process.kill() ), 10000

lirc.connect = (newCfg, done = ->) ->
	if not lirc.cfg
		if typeOf( newCfg ) is 'object'
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
		if not cfg.server.certKeyFile || not cfg.server.certFile
			throw new Error("Missing cert configuration")
			
		keygen = require('ssl-keygen').createKeyGen()

		keygen.createKey 'ssl_key', (err, key) =>
			keygen.createCert 'ssl_key', (err, cert) =>

				key = fs.readFileSync cfg.server.certKeyFile, 'utf8'
				cert = fs.readFileSync cfg.server.certFile, 'utf8'

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
					localAddress: cfg.server.localAddress

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
				lirc.bind lirc.listeners.irc, conn

lirc.connect.configure = (conn) ->
	conn.setTimeout lirc.cfg.timeout
	conn.setEncoding lirc.cfg.encoding
	conn.setKeepAlive true, lirc.cfg.keepAlive

lirc.codes = require './format_codes'

lirc.listeners = {
	irc: require './listeners/irc'
}

lirc.mappings = {
	parsing	: require './mappings/parsing'
	actions	: require './mappings/actions'
}

# Each module below extends lirc on it own
require './build'
require './emitter'
require './commands'
require './botnet/botnet'
require './session'

if cluster.isMaster
	require '../web'

	cluster.on 'disconnect', (worker) ->
		console.log "Worker [ #{worker.id} ] died"
else
	lirc.on 'msg', (msg) ->
		lirc.botnet.emit.master {
			cmd	: 'emit.web'
			args: ['msg', [msg]]
		}

	lirc.botnet.on '*', (args = []) ->
		message = args[1]

		lirc.botnet.emit.master {
			cmd	: 'emit.web'
			args: ['botnet', {
				cmd: message.args[0]
				args: if message.args[1] then message.args[1..] else []
				time: new Date().getTime()
			}]
			fromWorkerId: message.workerId
		}

module.exports = lirc







