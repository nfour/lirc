
lirc = require '../lirc'

# Matches one array, in order. Indexes to the callbacks are cached on match.

module.exports = [
	[
		'JOIN'
		(msg) ->
			msg.chan = msg.args or msg.text
			msg.mask = lirc.parse.mask msg.origin

			delete msg.args
	]
	[
		'MODE'
		(msg) ->
			args = msg.args.split ' '

			msg.target	= args[0]
			msg.flags	= msg.text or args[1] or ''

			msg.text = "#{msg.target} #{msg.flags}"

			delete msg.args
	]
	[
		# args: <target>
		/// ^ (
			PRIVMSG
		|	NOTICE
		) $ ///
		(msg) ->
			msg.target	= msg.args
			msg.mask	= lirc.parse.mask msg.origin

			msg.reply = (text = '') ->
				lirc.send.privmsg msg.target, text

			delete msg.args
	]
	[
		# args: <target>
		/// ^
			RPL_(
				MOTD
			|	MOTDSTART
			|	ENDOFMOTD
			)
		$ ///
		(msg) ->
			msg.target	= msg.args
			msg.text	= msg.text.replace /^\-\s?/, ''

			delete msg.args
	]
	[
		# args: <target> <chan>
		/// ^ (
			RPL_(
				ENDOFNAMES
			)
		) $ ///
		(msg) ->
			args = msg.args.split ' '

			msg.target	= args[0] or ''
			msg.chan	= args[1] or ''

			delete msg.args
	]
	[
		# args: <target> [@*=] <chan>
		/// ^ (
			RPL_(
				NAMREPLY
			)
		) $ ///
		(msg) ->
			args = msg.args.split ' '

			msg.target	= args[0] or ''
			msg.mode	= args[1] or ''
			msg.chan	= args[2] or ''
			msg.names	= msg.text.split ' '

			delete msg.args
	]
]
