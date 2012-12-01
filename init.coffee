
lirc	= require 'lirc'
cluster	= require 'cluster'
http	= require 'http'

if cluster.isMaster
	lirc {
		server: {
			host: 'localhost'
			port: 8765
		}
	}

	lirc.web()

	lirc.botnet.spawn 'botty'
	lirc.botnet.spawn 'derpy'
else
	lirc.botnet.run()
