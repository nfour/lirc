
events = require 'events'

lirc	= require '../../lib/lirc'
web		= require './web'

{type} = Function

module.exports	=
web.emitter		= new events.EventEmitter()

web.on = () -> 
	if type( arguments[0] ) is 'array'
		for val in arguments[0]
			args	= Array::slice.call arguments
			args[0]	= val

			web.emitter.on.apply web.emitter, args
	else
		web.emitter.on.apply web.emitter, arguments

web.emit = (name) ->
	args = Array::slice.call arguments

	if name isnt '*'
		arguments.callee '*', args

	web.emitter.emit.apply web.emitter, args

web.emitter._events = {}
