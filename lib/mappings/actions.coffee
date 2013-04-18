
lirc = require '../lirc'

###
	One of these will be called (in order) if the msg.cmd
	matches via regexp or a === comparison
###

module.exports = [
	[
		'PRIVMSG'
		(msg) ->
			if msg.target.match /^[\#&]/
				lirc.emit 'CHANMSG', msg
				lirc.emit msg.target, msg
			else
				lirc.emit 'USERMSG', msg
	]
	[
		'PING'
		(msg) ->
			lirc.send 'PONG', msg.text
	]
	[
		'RPL_MOTDSTART'
		(msg) ->
			text = msg.text + '\r\n'
			lirc.session.server.motd = text
	]
	[

		'RPL_MOTD'
		(msg) ->
			text = msg.text + '\r\n'
			lirc.session.server.motd += text
	]
	[
		'RPL_ENDOFMOTD'
		(msg) ->
			lirc.emit 'MOTD', lirc.session.server.motd
	]
	[
		'ERR_NICKNAMEINUSE'
		(msg) ->
			lirc.session.server.user.nick = lirc.session.server.user.altnick
			lirc.auth()
	]
	[
		'RPL_WELCOME'
		(msg) ->
			lirc.session.server.realhost = msg.origin
			lirc.emit 'connected'
	]
]
