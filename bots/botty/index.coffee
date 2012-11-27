
lirc = require 'lirc'


#console.log lirc

cfg = {
	user		:
		nick		: 'Botty????'
		username	: 'Botty'
		realname	: 'Mr BotVille'

	server:
		host		: 'irc.freenode.com'
		port		: 6667
		pass		: ''
}

console.log 'botscope'
console.log lirc

lirc cfg
lirc.connect()
lirc.web()
lirc.on 'data', (data) -> console.log 'data', data
#lirc.on '*', (name, arg) -> console.log name, arg



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

