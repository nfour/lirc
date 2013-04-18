
events	= require 'events'
lirc	= require './lirc'
cluster	= require 'cluster'

{typeOf, toArray} = lirc.utils

lirc.emitter = new events.EventEmitter()

lirc.on = () ->
	if typeof arguments[0] is 'string'
		arguments[0] = [arguments[0]]

	for val in arguments[0]
		args	= toArray arguments
		val		= val.toLowerCase()
		args[0]	= val

		lirc.emitter.on.apply lirc.emitter, args

lirc.emit = () ->
	args = toArray arguments

	if typeOf( args[0] ) is 'array' and args.length is 1
		args = args[0]
	
	args[0] = args[0].toLowerCase()

	if args[0] isnt '*'
		arguments.callee '*', args

	lirc.emitter.emit.apply lirc.emitter, args

lirc.emitter._events = {}

