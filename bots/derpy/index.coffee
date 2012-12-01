
cluster = require 'cluster'
lirc = require 'lirc'
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
console.log 'derpy started', cluster.worker.id

lirc cfg

lirc.on 'BOTMSG', (data) ->
	console.log 'derpy got a botnet', data

