
lirc = require '../../lirc'

{botnet, web} = lirc

# cluster events, emitted to the master

module.exports = {
	message: (message) ->
		if typeof message isnt 'object' or not message?.cmd
			return false

		# ordered from percieved most frequent, descending
		switch message.cmd
			when 'emit.web'
				lirc.web.emit message

			when 'emit.botnet'
				botnet.emit.local message.args[0], message
				botnet.emit message

			when 'emit.botnet.workers'
				botnet.emit message

			when 'emit.botnet.master'
				botnet.emit.local message.args

			when 'emit'
				lirc.emit message.args
				lirc.botnet.emit message

			when 'emit.workers'
				lirc.botnet.emit message

			when 'emit.master'
				lirc.emit message.args

			when 'relay'
				lirc.botnet.emit.worker message

			when 'restart'
				return false if not name = message.args?[0]

				if lirc.botnet.restart name
					lirc.web.emit 'lirc', {
						text: 'Restarted bot ' + name
						time: new Date().getTime()
					}

			when 'botnet.info'
				{id, name, cfg} = message.args

				if id of botnet.bots
					botnet.bots[id].name	= name or id
					botnet.bots[id].cfg		= cfg or {}

}
