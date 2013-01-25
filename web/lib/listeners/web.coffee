
web = require '../web'

# socket.io events, to frontend, from lirc.emitter

module.exports = {
	msg: (message) ->
		web.send message.workerId, message.args

	send: (message) ->
		web.send message.workerId, message.args
}


