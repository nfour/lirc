
lirc = require '../../lirc'

{botnet, web} = lirc

{type} = Function

# cluster events, emitted to the master

module.exports = {
	message: (message) ->
		if type( message ) isnt 'object'
			return console.error "[WARN] botnet.listeners.master - Non-object vartype #{type( message )}"

		name = message.args[0] or ''

		switch message.cmd
			when 'emit'
				lirc.emit message.args
				lirc.botnet.emit message

			when 'emit.workers'
				lirc.botnet.emit message

			when 'emit.master'
				lirc.emit message.args

			when 'emit.botnet'
				botnet.emit.local message.args
				botnet.emit message

			when 'emit.botnet.workers'
				botnet.emit message

			when 'emit.botnet.master'
				botnet.emit.local message.args

			when 'emit.web'
				lirc.web.emit name, message # MAKE CHANGES TO WEB.EMIT()
				lirc.botnet.emit message

			when 'emit.web.workers'
				lirc.botnet.emit message

			when 'emit.web.master'
				lirc.web.emit name, message

			when 'relay'
				lirc.botnet.emit.worker message

			when 'botnet.info'
				{id, name, cfg} = message.args

				if id of botnet.bots
					botnet.bots[id].name	= name or id
					botnet.bots[id].cfg		= cfg or {}

}
