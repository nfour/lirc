
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

web.emit = (message) ->
	if not web.io?.sockets?
		return lance.error 'warn', "web.emit(), web.io.sockets undefined, can't send"

	if args = web.emit.parseArgs message
		web.io.sockets.emit.apply web.io.sockets, args

web.emit.local = () ->
	args = Array::slice.call arguments

	if type( args[0] ) is 'array' and args.length is 1
		args = args[0]

	args[0] = args[0].toLowerCase()

	if args[0] isnt '*'
		arguments.callee '*', args

	web.emitter.emit.apply web.emitter, args

# expecting message from proccess.send()
# { cmd: '', workerId: 0, args: [] }
web.emit.parseArgs = (message) ->
	eventName	= message.args[0]
	args		= message.args[1]

	botName	= lirc.botnet.bots[ message.workerId or 0 ]?.name or ''

	if not eventName
		return false

	return [eventName, botName].concat args or []

web.emitter._events = {}
