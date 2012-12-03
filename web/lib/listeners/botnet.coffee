
web = require '../web'

# socket.io events, to frontend, from lirc.botnet.emitter

module.exports = {
	# sends everything
	'*': (msg) ->
		web.io.sockets.emit 'botmsg', msg
}


