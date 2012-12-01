
lirc = require 'lirc'
cluster = require 'cluster'

#console.log lirc

cfg = require './cfg'

console.log 'botty started', cluster.worker.id

lirc cfg
lirc.connect()
#lirc.web()
lirc.on 'data', (data) -> console.log 'data', data
#lirc.on '*', (name, arg) -> console.log name, arg

setInterval(
	() -> lirc.botnet.send { cmd: 'emit', args: ['BOTMSG', 'yep'] }
	10000
)

lirc.botnet.on '*', (data) ->
	console.log 'botty got a botnet', data

###
ircbot	= irc cfg
irc		= ircbot.emitter

#ircbot.connect()
ircbot.botnet.connect()
ircbot.web.start(5080)

irc.on('PRIVMSG', (msg) ->
	return false if ! msg.origin.match(/nuzz/i)
	
	if msg.words[0].match(/join/i) and msg.words[1]
		ircbot.join(msg.words[1..])
)
###

