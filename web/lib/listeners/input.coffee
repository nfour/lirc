
web		= require '../web'
lirc	= require '../../../lib/lirc'

# socket.io events, from frontend

module.exports	=
listeners		= {
	input: (text) ->
		return false if not text

		web.emit 'input', text

		words = text.split ' '

		return false if not words[0]

		cmd = words[0].toLowerCase().replace /^\./, ''
		
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
						time: new Date().getTime()
					}

			when 'restartall'
				for id, bot of lirc.botnet.bots
					continue if not bot.name
					lirc.botnet.kill bot.name
					lirc.botnet.spawn bot.name

					web.emit 'lirc', {
						text: 'Restarted bot ' + bot.name
						time: new Date().getTime()
					}

			when 'spawn'
				return false if not name = words[1]

				if lirc.botnet.spawn name
					web.emit 'lirc', {
						text: 'Spawned bot ' + name
						time: new Date().getTime()
					}

			when 'kill'
				return false if not name = words[1]

				if lirc.botnet.kill name
					web.emit 'lirc', {
						text: 'Killed bot ' + name
						time: new Date().getTime()
					}

			when 'bots'
				bots = []
				for id, bot of lirc.botnet.bots
					bots.push bot.name or id

				web.emit 'lirc', {
					text: 'Bots: ' + bots.join ', '
					time: new Date().getTime()
				}

			when 'buffer'
				web.emit 'buffer', web.buffer.buffer

	disconnect: () ->
		console.log 'Web, user disconnected'
		delete this
	
}


