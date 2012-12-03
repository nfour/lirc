
lirc = require '../lirc'

###
	One of these will be called (in order) if the msg.cmd
	matches via regexp or a string comparison
###

module.exports = [
	[
		'PRIVMSG'
		(msg) ->
			# if the PRIVMSG is from a channel, emit as an event
			# may want to only do this ONLY if there is already a listener for it
			if msg.to
				if msg.to[0].match /[\#&]/
					lirc.emit 'CHANMSG', msg				# emits CHANMSG
					lirc.emit msg.to, msg
				else
					lirc.emit 'USERMSG', msg
	
	]
	[
		'PING'
		(msg) ->
			lirc.send "PONG #{ msg.from }"
	]
	[
		'RPL_MOTDSTART'
		(msg) ->
			str = msg.words.join(' ') + '\r\n'
			lirc.session.server.motd = str
	]
	[
		'RPL_ENDOFMOTD'
		(msg) ->
			lirc.emit 'MOTD', lirc.session.server.motd
	]
	[
		'RPL_MOTD'
		(msg) ->
			str = msg.words.join(' ') + '\r\n'
			lirc.session.server.motd += str
	]
]
