
web = require '../web'

# socket.io events, to frontend, from lirc.emitter

module.exports = {
	msg: (msg) ->
		# could probably parse it as well, send seperate events - perhaps based on socketio "rooms"
		web.io.sockets.emit 'msg', msg

	data: (data) ->
		console.log data
		lines = data.split '\r\n'
		lines.pop()

		for line in lines
			web.io.sockets.emit 'data', line


	send: (msg) ->
		web.io.sockets.emit 'send', msg
}


