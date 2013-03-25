
lirc	= require '../../lirc'
cluster	= require 'cluster'

{botnet, web} = lirc

{type} = Function

# cluster events, emitted to workers

module.exports = {
	message: (message) ->
		return false if type( message ) isnt 'object'

		# message is { cmd: '', args: [] }

		switch message.cmd
			when 'emit'
				lirc.emit message.args

			when 'emit.botnet'
				botnet.emit.local message.args

			when 'botnet.info.get'
				botnet.emit.master {
					cmd: 'botnet.info'
					args: {
						name: lirc.session.me
						cfg	: lirc.cfg
						id	: cluster.worker.id
					}
				}
}