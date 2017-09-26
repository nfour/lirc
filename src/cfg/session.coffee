
cluster = require 'cluster'

module.exports = {
	msgBuffer	: null
	me			: ''
	localAddress: ''
	server		: {
		host: ''
		port: 6667
		pass: ''
		
		user: {
			nick: '', altnick: '', username: '', realname: '', pass: '',
			hostname: '', servername: ''
		}

		chans: {}
		motd: ''
		secure			: false
		useExpiredCert	: true
		selfSigned		: false

		certKeyFile: ''
		certFile: ''
	}
	servers	: []
}

if cluster.isMaster
	module.exports.me = 'master'