
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
	json = {
		code: 'success'
		error: false
	}

	if not fs.existsSync errorFileDir
		json.code = 'empty'
		return res.serve.json json

	if req.GET.purge
		fs.unlink errorFileDir, (err) ->
			if err
				error = lirc.error {
					type: 'warning'
					scope: 'router.GET /errors?purge=1 fs.unlink'
					error: err
				}
				json.code	= 'failed'
				json.error	= error.text
				return res.serve.json json

			res.serve.json json

	else
		fs.readFile errorFileDir, 'utf8', (err, file) ->
			if err
				error = lirc.error {
					type: 'warning'
					scope: 'router.GET /errors/ fs.readfile'
					error: err
				}
				json.code	= 'failed'
				json.error	= error.text
				return res.serve.json json

			json.blocks = []

			for errorBlock in file.toString().split '/err/'
				errorBlock.replace /^\s+|\s+$/g, ''
				if errorBlock
					json.blocks.push errorBlock

			res.serve.json json




