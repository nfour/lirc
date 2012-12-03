
events = require 'events'
lirc	= require './lirc'
cluster	= require 'cluster'

{type} = Function

module.exports	=
lirc.emitter	= new events.EventEmitter()

lirc.on = () ->
	if type( arguments[0] ) is 'array'
		for val in arguments[0]
			args	= Array::slice.call arguments
			args[0]	= val

			lirc.emitter.on.apply lirc.emitter, args
	else
		lirc.emitter.on.apply lirc.emitter, arguments

lirc.emit = (name) ->
	args = Array::slice.call arguments

	if name isnt '*'
		arguments.callee '*', args

	lirc.emitter.emit.apply lirc.emitter, args

lirc.emitter._events = {}

