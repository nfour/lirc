
path = require 'path'
rootDir		= path.dirname __dirname

url			= {}

server = {
	method		: 'socket'
	socket		: path.join rootDir, '/unix.socket' # ... /web/unix.socket
	socketPerms	: 0o0666

	port		: 1339
	host		: '10.0.0.7'
	
	url			: url
}

# lets just use ports for a predictable url
server.method	= 'port'
url.root		= "http://#{server.host}:#{server.port}"
url.static		= url.root + '/static'

module.exports = server