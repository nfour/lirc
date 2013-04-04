
Path	= require 'path'
Fs		= require 'fs'
cluster	= require 'cluster'
lirc	= require '../lirc'

{type} = Function

module.exports	=
lirc.botnet		=
botnet			= () ->

botnet.bots = {}
botnet.cfg = {
	botsDir: Path.join Path.dirname( process.mainModule.filename ), '/bots'
}

botnet.kill = (name = '') ->
	return false if not name

	for id, bot of lirc.botnet.bots
		if bot.name and name.toLowerCase() is bot.name.toLowerCase()
			bot.process.kill()
			delete lirc.botnet.bots[id]

			return true

	return false

botnet.restart = (name = '') ->
	return false if not name

	for id, bot of lirc.botnet.bots
		if bot.name and name.toLowerCase() is bot.name.toLowerCase()
			bot.process.kill()
			delete lirc.botnet.bots[id]
			botnet.spawn name

			return true

	return false

botnet.spawn = (botPath) ->
	if cluster.isMaster
		if (
			Fs.existsSync( botPath ) or
			Fs.existsSync( Path.join botnet.cfg.botsDir, botPath )
		)
			worker = cluster.fork { lirc_botPath: botPath }

			botnet.bots[worker.id] = worker

			lirc.bind botnet.listeners.master, worker

		return true

	return false

botnet.run = (botPath = '') ->
	if not botPath
		if process.env.lirc_botPath?
			botPath = process.env.lirc_botPath
		else
			lirc.error 'err', "botnet.run(), cant find bot to run"

	dir = Path.join botnet.cfg.botsDir, botPath

	if Fs.existsSync dir
		require dir
	else
		if cluster.isWorker
			cluster.worker.kill()

botnet.listeners = {
	master: require './listeners/master'
	worker: require './listeners/worker'
}

require './emitter'

if cluster.isWorker
	lirc.bind botnet.listeners.worker, process

lirc.botnet		=
module.exports	= botnet