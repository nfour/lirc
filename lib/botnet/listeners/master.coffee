
lirc = require '../../lirc'

{botnet, web} = lirc

{type} = Function

# cluster events, emitted to the master

module.exports = {
	message: (message) ->
		if type( message ) isnt 'object'
			return lance.error 'warn', "botnet.listeners.master - Non-object vartype #{type( message )}"

		# ordered from percieved most frequent, descending
		switch message.cmd
			when 'emit.web'
				lirc.web.emit message

			when 'emit.botnet'
				botnet.emit.local message.args
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

			when 'botnet.info'
				{id, name, cfg} = message.args

				if id of botnet.bots
					botnet.bots[id].name	= name or id
					botnet.bots[id].cfg		= cfg or {}

}
