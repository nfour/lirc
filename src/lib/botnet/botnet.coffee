
path	= require 'path'
fs		= require 'fs'
cluster	= require 'cluster'
lirc	= require '../lirc'

module.exports	=
lirc.botnet		=
botnet			= {}

botnet.bots = {}
botnet.cfg = {
	botsDir: path.join path.dirname( process.mainModule.filename ), '/bots'
}

botnet.kill = (name = '') ->
	return false if not name

	for id, bot of lirc.botnet.bots
		continue if not bot.name

		if name.toLowerCase() is bot.name.toLowerCase()
			bot.process.kill()
			delete lirc.botnet.bots[id]

			return true

	return false

botnet.restart = (name = '') ->
	return false if not name

	for id, bot of lirc.botnet.bots
		continue if not bot.name

		botName = bot.name.toLowerCase()

		if name.toLowerCase() is botName
			bot.process.kill()
			delete lirc.botnet.bots[id]
			botnet.spawn name

			return true

	return false

botnet.spawn = (botPath) ->
	botPathLower = botPath.toLowerCase()
	if cluster.isMaster
		if (
			fs.existsSync( botPath ) or
			fs.existsSync( path.join botnet.cfg.botsDir, botPath ) or
			useLower = fs.existsSync( path.join botnet.cfg.botsDir, botPathLower )
		)
			botPath	= botPathLower
			worker	= cluster.fork { lirc_botPath: botPath }

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

	dir = path.join botnet.cfg.botsDir, botPath

	if fs.existsSync dir
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