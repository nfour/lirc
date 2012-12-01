var connect = require('connect')

var dir = __dirname + '/../files'
var files = connect.static(dir)

var http = require('http')
var server = new http.Server

server.addListener('request', function(req, res) {
    files(req, res, function() {
        res.writeHead(404)
        res.end()
    })
})

server.listen(8080)
