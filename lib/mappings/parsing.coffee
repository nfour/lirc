
lirc = require '../lirc'

###
	One of these will be called (in order) if the msg.cmd
	matches via regexp or a string comparison
###

module.exports = [
	[
		///
			PRIVMSG
		|	NOTICE
		///
		(msg) -> # :Nick!~Ident@CPE-123-211-37-152.lnse3.cha.bigpond.net.au PRIVMSG #test5000 :hai
			if matches = msg.fulltext.match /^:(\S+) (\S+) (\S+) :(.*)/
				matches.shift()
				[
					msg.from
					msg.cmd
					msg.to
					msg.text
				] = matches

				msg.words = msg.text.split ' ' # temp
				msg.mask = lirc.parse.mask msg.from
	]
	[
		'PING'
		(msg) ->
			if matches = msg.fulltext.match /^(\S+) :(.+)/
				matches.shift()
				[
					msg.cmd
					msg.from
				] = matches
	]
	[
		'MODE'
		(msg) ->
			return msg if msg.words.length < 2

			msg.to			= msg.words[0]
			msg.modes		= msg.words[1] or ''
			msg.modeArg		= msg.words[2] or ''
	]
	[
		'RPL_NAMEREPLY'
		(msg) ->
			return msg if msg.words.length < 3
			# unfinished ################################
			#msg.users		= msg.users[0].replace /^:/, ''
			msg.to			= msg.words[1]
			#msg.users		= msg.words[2..]
	]
	[
		/RPL_(MOTD|MOTDSTART)/
		(msg) ->
			msg.words[0].replace /^\-/, ''
	]
	[
		'RPL_WELCOME'
		(msg) ->
			lirc.session.server.realhost = msg.from
	]

	[
		/\S/ # fallback, always called
		(msg) ->
			return msg if msg.words.length < 2

			msg.to			= msg.words[0]

			msg.words		= msg.words[1..]
			msg.words[0]	= msg.words[0].replace /^:/, ''
	]
]
