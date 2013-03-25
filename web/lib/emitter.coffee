
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

web.emit = (workerId, args) ->
	if not web.io?.sockets?
		return lance.error 'warn', "web.emit(), web.io.sockets undefined, can't send"

	args = web.emit.parseArgs workerId, args

	web.emit.io args

web.emit.local = () ->
	args = Array::slice.call arguments

	if type( args[0] ) is 'array' and args.length is 1
		args = args[0]

	args[0] = args[0].toLowerCase()

	if args[0] isnt '*'
		arguments.callee '*', args

	web.emitter.emit.apply web.emitter, args

web.emit.io = (args = []) ->
	web.io.sockets.emit.apply web.io.sockets, args

web.emit.parseArgs = (workerId = 0, args = []) ->
	botName = workerId

	if lirc.botnet.bots[ workerId ]?.name?
		botName	= lirc.botnet.bots[ workerId ].name

	eventName	= args[0] or null
	args		= if 1 of args then args[1..] else []

	if not eventName or not botName?
		return false 

	return [eventName, botName].concat args

web.emitter._events = {}
