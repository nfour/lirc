
path	= require 'path'
lance	= require 'lance'
web		= require './web'

# Static file serving
lactate		= require 'lactate'
staticDir	= path.join path.dirname( __dirname ), '/static'
lactate		= lactate.dir staticDir, web.cfg.lactate

{route} = lance

route.get [ '/static/*', '/:file(favicon.ico)' ], 'static', (req, res) ->
	filePath = req.path.file or req.splats.join '.'
	lactate.serve filePath, req, res

route.get '/', 'home', (req, res) ->
	res.serve req, res, 'home'



