
path	= require 'path'
rootDir	= path.dirname __dirname

url			= {}

server = {
	method		: 'port'
	socket		: path.join rootDir, '/unix.socket' # ... /web/unix.socket
	socketPerms	: 0o0666

	port		: 1339
	host		: 'localhost'
	
	url			: url
}

module.exports = server