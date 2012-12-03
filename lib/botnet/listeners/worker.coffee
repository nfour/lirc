
lirc = require '../../lirc'

{type} = Function

# cluster events, emitted to workers

module.exports = {
	message: (message) ->
		return false if type( message ) isnt 'object'

		# message is { cmd: '', args: [] }

		switch message.cmd
			when 'emit'
				lirc.emit.apply lirc, message.args

			# emit to lirc.botnet
			when 'botnet.emit'
				lirc.botnet.emit.apply lirc.botnet, message.args

			# emit to lirc.web

			when 'web.emit'
				lirc.web.emit.apply lirc.web, message.args

}