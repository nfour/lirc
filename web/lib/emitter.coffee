
events = require 'events'

lirc	= require '../../lib/lirc'
web		= require './web'

{type} = Function

web.emitter = new events.EventEmitter()

web.on = () -> 
	if type( arguments[0] ) is 'array'
		for val in arguments[0]
			args	= Array::slice.call arguments
			args[0]	= val

			web.emitter.on.apply web.emitter, args
	else
		web.emitter.on.apply web.emitter, arguments

web.emit = () ->
	if not web.io?.sockets?
		return lirc.error 'warn', "web.emit(), web.io.sockets undefined, can't send"

	if args = web.emit.parseArgs arguments
		web.io.sockets.emit.apply web.io.sockets, args

		if args[0] isnt 'buffer'
			web.buffer.add args

web.emit.client = (socket) ->
	args = Array::slice.call arguments
	args = args[1..]

	if args = web.emit.parseArgs args
		socket.emit.apply socket, args

		if args[0] isnt 'buffer'
			web.buffer.add args

# expecting message from proccess.send()
# { cmd: '', workerId: 0, args: [] }
web.emit.parseArgs = (args) ->
	if args[0] and typeof args[0] is 'string'
		args = Array::slice.call args
		return args
	else
		message		= args[0]
		eventName	= message.args[0]

		args = []
		args = args.concat message.args[1]

		botName	= lirc.botnet.bots[ message.workerId or 0 ]?.name or ''

		if message.fromWorkerId
			fromBotName = lirc.botnet.bots[ message.fromWorkerId or 0 ]?.name or ''
			args.push fromBotName

		if not eventName
			return false

		return [eventName, botName].concat args

web.emit.local = () ->
	args = Array::slice.call arguments

	if type( args[0] ) is 'array' and args.length is 1
		args = args[0]

	args[0] = args[0].toLowerCase()

	if args[0] isnt '*'
		arguments.callee.apply '*', args

	web.emitter.emit.apply web.emitter, args

web.emitter._events = {}
