root = exports ? this

MAM_VERSION = 'pre3'
GOOGLE_FONTS = '//ajax.googleapis.com/ajax/libs/webfont/1/webfont.js'

mamPrint = (msg) ->
	console.log "MAM #{MAM_VERSION} - #{msg}"

class Task
	constructor: ->
		@dfd     = $.Deferred()
		@pending = 0

	add: ->
		++@pending

	sub: (resolveData) ->
		if --@pending == 0
			@dfd.resolve resolveData

root.MAM = class MAM
	constructor: (config, pjs) ->
		@config = config
		@media  = {}
		@pjs    = pjs
		@task   = new Task

		if config.images?
			@media.images = {}
			@imgTags = {}
			@imgTask = new Task
			for id, url of config.images
				@loadImage id, url

		if config.sprites?
			@media.sprites = {}
			for id, spec of config.sprites
				@loadSprite id, spec

		if config.fonts?
			@media.fonts = []
			@loadFonts config.fonts

		if config.audio?
			@media.audio = {}
			for id, urls of config.audio
				@loadAudio id, urls

		@promise = @task.dfd.promise()

	loadAudio: (id, urls) ->
		@task.add()

		html = '<audio>'
		urls = [ urls ] if typeof urls is 'string'
		for url in urls
			type = ''
			ext = url.substr(-4)
			if ext is '.mp3' or ext is '.mpg'
				type = 'audio/mpeg'
			else if ext is '.ogg'
				type = 'audio/ogg'
			else if ext is '.wav'
				type = 'audio/wav'
			else
				console.log "Unknown audio type for #{url}"
				continue
			html += "<source src=\"#{url}\" type=\"#{type}\">"
		html += '</audio>'

		audioElem = $ html
		mam = @
		audioElem.on 'loadeddata', ->
			audio = @
			mam.task.dfd.notify 'audio', id
			mam.media.audio[id] = audio
			mam.task.sub mam.media

		$('body').append audioElem

	loadFonts: (families) ->
		familiesNormal = []
		familiesNormal.push(f.replace /\s/g, '+') for f in families
		@task.add()

		root.WebFontConfig =
			google:
				families: familiesNormal
			active: =>
				for font in families
					@media.fonts.push @pjs.createFont font
				@task.sub @media

		$.getScript GOOGLE_FONTS

	loadImage: (id, url) ->
		@task.add()
		@imgTask.add()

		cors = @config.enableCORS ? true

		img = $ "<img />"
		img.attr 'crossOrigin', 'anonymous' if cors
		img.attr 'src', url

		img.on 'load', =>
			pimg = @pjs.createImage img.width(), img.height(), @pjs.ARGB
			pimg.sourceImg.getContext('2d').drawImage img[0], 0, 0

			@media.images[id] = pimg
			@imgTags[id]      = img[0]

			@task.dfd.notify 'image', id
			@task.sub @media
			@imgTask.sub()

		$('body').append img

	loadSprite: (id, spec) ->
		unless @imgTask?
			@task.dfd.reject 'No images specified'
			return

		@task.add()
		fn = =>
			@imgTask.dfd.done =>
				unless @media.images[spec.sheet]?
					@task.dfd.reject "No image named #{spec.sheet}"
					return

				src = @imgTags[spec.sheet]
				if spec.frames?
					frames = []
					for i in [0 ... spec.frames]
						x = spec.x + spec.width*i
						pimg = @pjs.createImage(
							spec.width, spec.height, @pjs.ARGB)
						pimg.sourceImg.getContext('2d').drawImage(
							src, x, spec.y, spec.width, spec.height,
							0, 0, spec.width, spec.height)
						frames.push pimg
					@media.sprites[id] = frames	
				else
					pimg = @pjs.createImage spec.width, spec.height, @pjs.ARGB
					pimg.sourceImg.getContext('2d').drawImage(
						src, spec.x, spec.y, spec.width, spec.height,
						0, 0, spec.width, spec.height)
					@media.sprites[id] = pimg

				@task.dfd.notify 'sprite', id
				@task.sub @media

		setTimeout fn, 0

	run: () ->
		@promise.fail (reason) ->
			mamPrint "Loading of assets failed: #{reason}"

		@promise.done (media) =>
			mamPrint "Loading of assets done"

			@config.onReady media if typeof @config.onReady is 'function'
			@pjs.draw = @config.draw if typeof @config.draw is 'function'
