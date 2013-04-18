
events	= require 'events'
cluster	= require 'cluster'
lirc	= require '../lirc'
botnet	= require './botnet'

{typeOf} = lirc.utils

module.exports	=
botnet.emitter	= new events.EventEmitter()

botnet.on = ->
	if typeof arguments[0] is 'string'
		arguments[0] = [arguments[0]]

	for val in arguments[0]
		args	= Array::slice.call arguments
		val		= val.toLowerCase()
		args[0]	= val

		botnet.emitter.on.apply lirc.botnet.emitter, args

botnet.emit = ->
	obj = botnet.emit.parseArgs arguments

	if cluster.isMaster
		for key, worker of botnet.bots
			workerId = 0
			if obj.workerId? then workerId = obj.workerId.toString()

			if key isnt workerId
				worker.send obj
	else
		botnet.emit.master obj

botnet.emit.local = ->
	args = Array::slice.call arguments

	if typeOf( args[0] ) is 'array' and args.length is 1
		args = args[0]

	args[0] = args[0] or '*'
	args[0] = args[0].toLowerCase()

	if args[0] isnt '*'
		arguments.callee '*', args

	botnet.emitter.emit.apply botnet.emitter, args

botnet.emit.master = () ->
	if 'send' not of process
		return lirc.error 'warn', "botnet.send.master(), can't use process.send()"

	obj = botnet.emit.parseArgs arguments

	process.send obj

botnet.emit.worker = () ->
	# have this take worker obj or worker id

botnet.emit.parseArgs = (args) ->
	args = Array::slice.call args

	if typeOf( args[0] ) is 'object'
		if not args[0].workerId
			args[0].workerId = cluster.worker?.id or 0

		return args[0]

	return {
		cmd			: 'emit.botnet'
		args		: args
		workerId	: cluster.worker?.id or 0
	}

botnet.emitter._events = {}

