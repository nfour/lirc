
lirc = require '../../lirc'

{type} = Function

# cluster events, emitted to the master

module.exports = {
	message: (message) ->
		return false if type( message ) isnt 'object'

		# message is { cmd: '', args: [], workerId: 0 }

		switch message.cmd
			# emit to lirc.emit

			when 'emit::master'
				lirc.emit.apply lirc, message.args

			when 'emit'
				lirc.emit.apply lirc, message.args

				lirc.botnet.send message

			# emit to lirc.botnet.emit

			when 'botnet.emit::master'
				lirc.botnet.emit.apply lirc.botnet, message.args

			when 'botnet.emit'
				lirc.botnet.emit.apply lirc.botnet, message.args

				lirc.botnet.send message

			# emit to lirc.web.emit

			when 'web.emit::master'
				lirc.web.emit.apply lirc.web, message.args

			when 'web.emit'
				lirc.web.emit.apply lirc.web, message.args

				lirc.botnet.send message

			when 'relay'
				lirc.botnet.send.worker message

			# TODO: switch 'emit' and 'emit.botnet' around. extend argument count of all "emit" functions
			# complete the "relay" send to worker shit. perhaps rename from relay to "toWorker" or something more obvious
			# import color formatting, irc code pairs, vastly enhance "msg" accuracy
			# done-ish! this would be a v0.5 release
			# create working scripts, extend functionality where obviously required - the core seems fleshed




	exit: (data) ->
		lirc.emit 'botexit', lirc.parse.data data
	
}
