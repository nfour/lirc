
web		= require '../web'
lirc	= require '../../../lib/lirc'

# socket.io events, from frontend

module.exports	=
listeners		= {
	input: (text) ->
		return false if not text

		words = text.split ' '

		return false if not words[0]

		cmd		= words[0].toLowerCase().replace /^\./, ''
		socket	= this
		now		= new Date().getTime()

		web.emit 'input', text
		switch cmd
			#when 'privmsg'
			#	lirc.send.privmsg words[1], words[2] or ''

			#when 'join'
			#	lirc.join words[1], words[2] or ''

			#when 'part'
			#	lirc.part words[1]

			when 'restart'
				return false if not name = words[1]

				if lirc.botnet.restart name
					web.emit 'lirc', {
						text: 'Restarted bot ' + name
						time: now
					}

			when 'restartall'
				for id, bot of lirc.botnet.bots
					continue if not bot.name
					lirc.botnet.kill bot.name
					lirc.botnet.spawn bot.name

					web.emit 'lirc', {
						text: 'Restarted bot ' + bot.name
						time: now
					}

			when 'spawn'
				return false if not name = words[1]

				if lirc.botnet.spawn name
					web.emit 'lirc', {
						text: 'Spawned bot ' + name
						time: now
					}

			when 'kill'
				return false if not name = words[1]

				if lirc.botnet.kill name
					web.emit 'lirc', {
						text: 'Killed bot ' + name
						time: now
					}

			when 'bots'
				bots = []
				for id, bot of lirc.botnet.bots
					bots.push bot.name or id

				web.emit 'lirc', {
					text: 'Bots: ' + bots.join ', '
					time: now
				}

			when 'buffer'
				web.emit.client socket, 'buffer', web.buffer.buffer

	disconnect: () ->
		web.emit 'lirc', {
			time: new Date().getTime()
			text: "Web user [ #{this.id} ] disconnected"
		}
		delete this
	
}


