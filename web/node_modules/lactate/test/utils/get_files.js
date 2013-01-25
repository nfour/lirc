
/*
 * As zlib's functions are necessarily
 * asynchronous, I have pre-gzipped
 * all of the files and included them
 * in ./files directory.
 */

var fs = require('fs')
,   map = module.exports

var dir = __dirname + '/../files/'

fs.readdirSync(dir)
.filter(function(file) {
    return /\.gz$/.test(file)
})
.forEach(function(file) {
    var fileName = file.substring(0, file.length-3)
    var file = fs.readFileSync(dir+file)
    map[fileName] = file.toString()
})

return map
