
lirc = require '../../lirc'

{type} = Function

# cluster events, emitted to the master

module.exports = {
	message: (message) ->
		return false if type( message ) isnt 'object'

		# change this so that there is a "masterOnly" var in obj, which would simplify the below cmds

		if message.cmd.match /^([^\.]+.)?emit\b/
			return false if not message.args

			name = message.args[0] or ''

			switch message.cmd
				when 'emit::master'
					lirc.emit.apply lirc, message.args

				when 'emit'
					lirc.emit.apply lirc, message.args

					lirc.botnet.send message

				when 'botnet.emit::master'
					lirc.botnet.emit.apply lirc.botnet, message.args

				when 'botnet.emit'
					lirc.botnet.emit.apply lirc.botnet, message.args

					lirc.botnet.send message

				when 'web.emit::master'
					lirc.web.emit name, message

				when 'web.emit'
					lirc.web.emit name, message

					lirc.botnet.send message

		else
			switch message.cmd
				when 'relay'
					lirc.botnet.send.worker message

				when 'botinfo'
					id = message.workerId or message.args[2]

					if id of lirc.botnet.bots
						lirc.botnet.bots[id].name	= message.args[0] or id
						lirc.botnet.bots[id].cfg		= message.args[1] or {}

}
