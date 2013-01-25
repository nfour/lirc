
events	= require 'events'
cluster	= require 'cluster'
lirc	= require '../lirc'
botnet	= require './botnet'

{type} = Function

module.exports	=
botnet.emitter	= new events.EventEmitter()

botnet.on = () ->
	if type( arguments[0] ) is 'array'
		for val in arguments[0]
			args	= Array::slice.call arguments
			args[0]	= val

			botnet.emitter.on.apply lirc.botnet.emitter, args
	else
		botnet.emitter.on.apply botnet.emitter, arguments

botnet.emit = (name) ->
	args = Array::slice.call arguments

	if name isnt '*'
		arguments.callee '*', args
		newArgs = args.slice()
		newArgs[0] = 'BOTMSG'
		lirc.emit.apply lirc.emitter, newArgs

	botnet.emitter.emit.apply botnet.emitter, args

botnet.emitter._events = {}

