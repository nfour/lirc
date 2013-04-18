
path	= require 'path'
lance	= require 'lance'
lirc	= require '../../lib/lirc'
web		= require './web'
fs		= require 'fs'

staticDir		= path.join path.dirname( __dirname ), '/static'
errorFileDir	= path.join path.dirname( path.dirname __dirname ), 'error.log'

lactate = require('lactate').dir staticDir, web.cfg.lactate

{router} = lance

router.GET [ '/static/*', '/:file(favicon.ico)' ], 'static', (req, res) ->
	filePath = req.path.file or req.splats.join '.'
	lactate.serve filePath, req, res

router.GET '/', 'home', (req, res) ->
	res.serve 'home'

router.GET '/errors', 'errors', (req, res) ->
	if not fs.existsSync errorFileDir
		return res.serve.json false

	fs.readFile errorFileDir, 'utf8', (err, file) ->
		if err
			lirc.error { type: 'warning', error: err }
			res.serve.json false

		json = {
			errors: []
		}

		for errorBlock in file.toString().split '/err/'
			errorBlock.replace /^\s+|\s+$/g, ''
			if errorBlock
				json.errors.push errorBlock

		res.serve.json json




