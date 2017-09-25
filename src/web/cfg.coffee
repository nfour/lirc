path = require 'path'

module.exports = 
    server:
        method		: 'port'
        socket		: path.join __dirname, '/unix.socket' # ... /web/unix.socket
        socketPerms	: 0o0666

        port		: 1339
        host		: 'localhost'
        
        url			: {}

	site:
		title: 'Lirc'
		url: server.url
	
	lactate: {}

	io:
        log: false

    lance:
        root: __dirname

        server: {}

        templater: 
            findIn: 'views'
            saveTo: 'static'
            
            watch: false

            templater: 
                ect: 
                    cache	: true
                    watch	: true
                    open	: '<<'
                    close	: '>>'
            

        

    
