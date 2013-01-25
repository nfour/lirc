var static = require('node-static')

var dir = __dirname + '/../files'
var files = new static.Server(dir)

var http = require('http')
var server = new http.Server

server.addListener('request', function(req, res) {
    return files.serve(req, res)
})

server.listen(8080)
