
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
				botnet.emit.local message.args[0], message

			when 'botnet.info.get'
				botnet.emit.master {
					cmd: 'botnet.info'
					args: {
						name: lirc.session.me
						cfg	: lirc.cfg
						id	: cluster.worker.id
					}
				}

	exit: (worker) ->
		console.log 'worker exits, with suicide: ' + worker.suicide
		if not worker.suicide and worker.name
			lirc.botnet.spawn worker.name
}