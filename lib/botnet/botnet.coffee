
path	= require 'path'
fs		= require 'fs'
cluster	= require 'cluster'
lirc	= require '../lirc'

{type} = Function

module.exports	=
lirc.botnet		=
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

botnet.run = (botPath = '') ->
	if not botPath
		if process.env.lirc_botPath?
			botPath = process.env.lirc_botPath
		else
			return lirc.error 'err', "botnet.run(), cant find bot to run"

	dir = path.join botnet.cfg.botsDir, botPath

	if fs.existsSync dir
		require dir

botnet.listeners = {
	master: require './listeners/master'
	worker: require './listeners/worker'
}

require './emitter'

if cluster.isWorker
	lirc.bind botnet.listeners.worker, process

lirc.botnet		=
module.exports	= botnet