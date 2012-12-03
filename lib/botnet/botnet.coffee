
path	= require 'path'
fs		= require 'fs'
cluster	= require 'cluster'
lirc	= require '../lirc'

{type} = Function

module.exports	=
botnet			= () ->

botnet.bots = {}
botnet.cfg = {
	botsDir: path.join path.dirname( process.mainModule.filename ), '/bots'
}

botnet.spawn = (botPath) ->
	worker = cluster.fork { lirc_botPath: botPath }

	botnet.bots[worker.id] = worker

	if cluster.isMaster
		lirc.bind botnet.listeners.master, worker

botnet.run = (botPath) ->
	if not botPath
		if process.env.lirc_botPath?
			botPath = process.env.lirc_botPath
		else
			return lirc.error 'Error', 'botnet -> bot', 'Cant find bot to run'

	dir = path.join botnet.cfg.botsDir, botPath

	if fs.existsSync dir
		require dir

botnet.send = () ->
	obj = botnet.send.parseArgs arguments

	if cluster.isMaster
		for key, worker of botnet.bots
			workerId = obj.workerId.toString() or 0 

			if key isnt workerId
				worker.send obj
	else
		botnet.send.master obj

botnet.send.parseArgs = (args) ->
	if type( args[0] ) is 'object' then return args[0]

	obj = {
		cmd	: args[0]
		args: args[1]
	}

	if 2 of args then obj.workerId = args[2]

	return obj


botnet.send.master = () ->
	return false if not 'send' of process

	obj = botnet.send.parseArgs arguments

	obj.workerId = cluster.worker.id
	process.send obj


botnet.send.worker = () -> # have this take worker obj or worker id



botnet.listeners = {
	master: require './listeners/master'
	worker: require './listeners/worker'
}

require './emitter'

if cluster.isWorker
	lirc.bind botnet.listeners.worker, process


lirc.botnet		=
module.exports	= botnet