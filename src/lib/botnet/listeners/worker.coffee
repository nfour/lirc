
lirc	= require '../../lirc'
cluster	= require 'cluster'

{botnet, web} = lirc

# cluster events, emitted to workers

module.exports = {
	message: (message) ->
		if typeof message isnt 'object' or not message?.cmd
			return false

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
		console.log "Worker #{worker.id} exits. Suicide: " + worker.suicide
}