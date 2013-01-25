
cluster = require 'cluster'

module.exports = {
	msgBuffer	: null
	me			: ''
	server		: {
		host: ''
		port: 6667
		pass: ''

		user: {
			nick: '', username: '', realname: '', pass: '',
			hostname: '', servername: ''
		}

		chans: {}
		motd: ''
		secure			: false
		useExpiredCert	: true
		selfSigned		: false
	}
	servers	: []
}

if cluster.isMaster
	module.exports.me = 'master'