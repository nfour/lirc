var lactate = require('lactate')

var dir = __dirname + '/../files'
var files = lactate.dir(dir, {
    cache:true,
    expires:'two days'
})

var http = require('http')
var server = new http.Server()

server.addListener('request', function(req, res) {
    return files.serve(req, res) 
})

server.listen(8080)
