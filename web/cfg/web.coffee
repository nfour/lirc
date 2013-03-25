server = require './server'
module.exports = {
	server: server
	site: {
		title: ''
		url: server.url
	}
	lactate: {}
	io: { log: false }
}