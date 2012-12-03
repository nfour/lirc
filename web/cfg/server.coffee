
path = require 'path'

platform	= process.platform
rootDir		= path.dirname __dirname

url			= {}
url.root	= ''
url.static	= url.root + '/static'

server = {
	workerLimit	: 1
	method		: 'socket'

	socket		: path.join rootDir, '/unix.socket' # ~/project/web/unix.socket
	socketPerms	: 0o0666

	port		: 8765
	host		: '127.0.0.1'
	
	url			: url
}

if platform is 'win32'
	server.method	= 'port'
	url.root		= "http://#{server.host}:#{server.port}"
	url.static		= url.root + '/static'


module.exports = server