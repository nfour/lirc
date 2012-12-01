
web		= require '../web'
lirc	= require '../../../lib/lirc'

# socket.io events, from frontend

module.exports = {
	input: (text) ->
		console.log 'web input', text

		web.io.sockets.emit 'input', text

		words	= text.split ' '
		cmd		= words[0][1..]

		if cmd is 'join' and words.length > 2
			lirc.join words[1], words[2] or ''

		# web.parse input, do things - such as emit to lirc, exposing input to scripts
		# calling lirc.join, etc.

	disconnect: () ->
		console.log 'Web, user disconnected'
	
}


