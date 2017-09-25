
server = require './server'

module.exports = {
	server: server
	site: {
		title	: 'Lirc'
		url		: server.url
	}
	lactate	: {}
	io		: { log: false }
}