root = exports ? this

MAM_VERSION = 'pre5p1'
GOOGLE_FONTS = '//ajax.googleapis.com/ajax/libs/webfont/1/webfont.js'

checkAudio = ->
	audio = $ '<audio />'
	_.isFunction audio[0].play

checkCORS = ->
	img = $ '<img />'
	img[0].crossOrigin?

hasAudio = checkAudio()
hasCORS  = checkCORS()

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
		@debug  = !!config.debug
		@media  = {}
		@pjs    = pjs
		@task   = new Task

		@print "version #{MAM_VERSION}"

		@media.support =
			audio: hasAudio
			cors: hasCORS

		@print "support: #{JSON.stringify @media.support}"

		if config.images?
			@print "loading images"
			@media.images = {}
			@imgTags = {}
			@imgTask = new Task
			for id, url of config.images
				@loadImage id, url

		if config.sprites?
			@print "loading sprites"
			@media.sprites = {}
			for id, spec of config.sprites
				@loadSprite id, spec

		if config.fonts?
			@print "loading fonts"
			@media.fonts = []
			@loadFonts config.fonts

		if config.audio? and hasAudio
			@print "loading audio"
			@media.audio = {}
			for id, urls of config.audio
				@loadAudio id, urls

		@print "pending #{@task.pending} tasks"
		@promise = @task.dfd.promise()
		@task.dfd.resolve @media if @task.pending is 0

	loadAudio: (id, urls) ->
		urls = [ urls ] if _.isString urls
		mam = @

		fn = ->
			sources = ''
			for url in urls
				type = ''
				ext = url.substr -4
				if ext is '.mp3' or ext is '.mpg'
					type = 'audio/mpeg'
				else if ext is '.ogg'
					type = 'audio/ogg'
				else if ext is '.wav'
					type = 'audio/wav'
				else
					console.log "Unknown audio type for #{url}"
					continue
				sources += "<source src=\"#{url}\" type=\"#{type}\">"

			audioElem = $ '<audio preload="auto"></audio>'
			audioElem.on 'canplay', ->
				mam.print "audio #{id} can be played"
				audio = @
				mam.media.audio[id] = audio

			audioElem.html sources
			$('body').append audioElem

		setTimeout fn, 0

	loadFonts: (families) ->
		familiesNormal = []
		familiesNormal.push(f.replace /\s/g, '+') for f in families
		@task.add()

		root.WebFontConfig =
			google:
				families: familiesNormal
			active: =>
				@print "fonts have been loaded"
				for font in families
					@media.fonts.push @pjs.createFont font
				@task.sub @media

		$.getScript GOOGLE_FONTS

	loadImage: (id, url) ->
		@task.add()
		@imgTask.add()

		fn = =>
			img = $ "<img />"
			img.on 'load', =>
				@print "image #{id} has been loaded"
				if img[0].src.substr(0, 4) is 'blob'
					root.URL.revokeObjectURL img[0].src
				pimg = @pjs.createImage img.width(), img.height(), @pjs.ARGB
				pimg.sourceImg.getContext('2d').drawImage img[0], 0, 0

				@media.images[id] = pimg
				@imgTags[id]      = img[0]

				@task.dfd.notify 'image', id
				@task.sub @media
				@imgTask.sub()

			cors = @config.enableCORS ? true
			if cors and hasCORS
				img.attr 'crossOrigin', 'anonymous'
				img.attr 'src', url
			else if not cors
				img.attr 'src', url
			else
				xhr = new XMLHttpRequest()
				xhr.open 'GET', url, true
				xhr.responseType = 'arraybuffer'
				xhr.onload = ->
					return unless @status is 200
					mime = @getResponseHeader 'Content-Type'
					view = new Uint8Array @response
					try
						blob = new Blob [ view ], type: mime
						img.attr 'src', root.URL.createObjectURL blob
					catch
						str = ''
						str += String.fromCharCode code for code in view
						b64 = root.btoa str
						dataURI = "data:#{mime};base64,#{b64}"
						img.attr 'src', dataURI

				xhr.send()

			$('body').append img

		setTimeout fn, 0

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

	print: (msg) ->
		console.log "MAM: #{msg}" if @debug

	run: () ->
		@promise.fail (reason) =>
			@print "Loading of assets failed: #{reason}"

		@promise.done (media) =>
			@print "loading of assets done"

			@config.onReady media if _.isFunction @config.onReady
			@pjs.draw = @config.draw if _.isFunction @config.draw
