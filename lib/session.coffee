
require './format'

lirc = require './lirc'

{merge, clone} = Object

# session remains a plain object for ease of use
session =
lirc.session = require '../cfg/session'

defaultSession = clone session

session.build = (cfg) ->
	return session if not cfg

	merge session, defaultSession # overwrites values to defaults

	# servers

	if cfg.server
		merge session.server, cfg.server

		session.servers.push session.server

	else if cfg.servers
		# iterate over specified servers, replacing values from defaults for each server
		for obj in cfg.servers
			session.servers.push merge merge( {}, defaultSession.server ), obj

		# sets first server in array to the "current" session.server
		session.server = session.servers[0]

	# user

	user = cfg.user or {}

	for key, val of session.server.user
		if val then user[key] = val

	if not user.username
		user.username = user.nick.replace /[\#\?]/g, ''

	user.realname = user.realname or user.username

	user.nick = lirc.format.nick user.nick

	session.server.user	= user
	session.me			= cfg.me or user.username


	session.built = true

	return session





