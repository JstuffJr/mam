% Media Assets Manager

# Introduction

The *Media Assets Manager* (**MAM** from now on), is a JavaScript library
created to assist programmers with the inclusion of publicly hosted media
assets in their programs for the [Khan Academy C.S.
environment](https://www.khanacademy.org/cs). It currently supports images
(and sprite extraction from images), audio elements and fonts.

MAM is currently under development and it is likely that its internal
details and programming interface change in the near future. If you would
like to help by testing it, please check this page regularly for changes.
Development occurs on [GitHub](https://github.com/lbv/mam).

This documentation assumes some knowledge of the JavaScript language and the
Khan Academy programming environment ---specifically, the
[Processing.js][pjs] model, and things like what the `draw` function does,
what a `PImage` is, and so on. If you're a beginner without too much
experience with the K.A. environment, it's recommended that you spend some
time exploring it and creating at least a few simple programs before trying
to use MAM.


## Change Log

*   *2013-05-25*

    **mam-pre3** release. Use CORS for images by default.

*   *2013-05-24*

    **mam-pre2** release. Now the configuration object contains the main
    callback and `draw` replacement as well, so `mamLoad` receives a single
    parameter, where all the configuration should be declared.

*   *2013-05-21*

    First release.


## Important Notice

Before using MAM, you should be aware of your responsibilities regarding the
use of creative works publicly available on the Internet or through other
mediums.

At the very least, you should inform yourself about the basic meaning of
terms like *copyright*, *trademark* and *publishing license*. These are
broad topics that go beyond the scope of this document, and it's highly
recommended that you invest a little time learning about them in case you
need to.

Here are some basic guidelines (please don't consider them exhaustive or a
substitute for valid legal advice):

*   Do not use any digital content (including pictures, images and audio
    files) for which you have not received an explicit permission to use and
    share. Content creators who want to publicly share their work usually do
    so by releasing their assets under a specific license which grants
    certain rights. Look for assets released under licenses such as those
    promoted by the [Creative Commons][cc] initiative.

*   The fact that you can find a file in a public website does *not*
    necessarily mean that you can use it freely, unless it comes with a
    license that grants you the appropriate rights. If you're unsure about
    the terms of use for a certain piece of content, it's better not to make
    any assumptions.

*   Even when you buy certain media files ---for example, songs from an
    online music store---, that usually grants you very restricted
    permissions, mainly for your own personal use. Again, this does not
    necessarily mean that you can then post those files online and share
    them freely. If you want to reuse and remix songs, always study the
    license under which you acquire your files.

*   Do not directly link to content hosted on websites maintained by others,
    unless you have received permission to do so. Store your media files in
    your own hosting servers whenever possible.

*   Avoid using the names and identities of popular video game characters or
    celebrities in your programs. They are typically covered by trademarks,
    and many video game companies and famous "celebrities" (such as singers,
    actors, and so on) work with law firms who actively go after people
    breaching said trademarks on the Internet. Try inventing your own
    characters for your own video--games and programs. Be creative!

In summary, try to always apply some common sense, and be respectful of
other people's rights. Strive to create your own assets as much as possible.
If you feel like you need a hand, no problem. Fortunately, the Internet is a
big place, and many people do share their works with permisive licenses. You
may find a few recommendations on [Appendix B](#appendix-b).


## Contact

If you have a suggestion or want to report a problem, please post a comment
in the *Tips & Feedback* section of the main [MAM Demo][mam-demo] program.
This program may be considered the authoritative reference on how to use
MAM, and it will always be kept up--to--date in relation to the latest
changes of the library.

If you try to use MAM in one of your programs and run into a problem, you're
welcome to ask for help. Please keep in mind that posting a message simply
stating *"it doesn't work"* is not very helpful. Make sure you have read
this documentation carefully, and try being as specific as you can in your
message, posting a link to your program if possible.


# Library Documentation

## Overview

A program using MAM should include the following elements:

*   The glue code. A short segment of code that imports the MAM library
    itself.

*   The definition of a *configuration object*. This specifies all the media
    assets that you want to use in your program, as well as a few other
    important details that connect your programs with those assets once they
    have been loaded.

*   Finally, a call to the `mamLoad` function. It simply receives the
    configuration object, and initiates the process of loading the assets.

These elements will be described in more detail in the following sections.

A good way to learn how MAM works is by playing with a few examples. You can
start by exploring the official [MAM Demo][mam-demo]. You can also find
shorter and more specific examples in [Appendix A](#appendix-a).


## The Glue Code

The first thing you need to do is place MAM's "glue" code in your program.
This is just a short snippet of Javascript code that will provide a bridge
between your program and the MAM library. This code simply defines a small
function called `mamLoad`, which you will have to call later on with a
configuration object.

This glue code is presented here:

<script src="https://gist.github.com/lbv/5621048.js"></script>

Just copy and paste it. It's probably a good idea to put it right at the top
of your program.

Notice that this code has been "minified" intentionally, to make it easy to
move around and paste into any JavaScript program. You don't need to
understand how it works in order to use MAM. If you're interested, though,
you can find this glue code in its original form
[here](https://github.com/lbv/mam/blob/master/src/mam-glue.js).


## The Configuration Object

To use MAM, you need to tell it what assets you want to load, and how your
program should behave after those assets have been loaded. This is done
through a plain JavaScript object, which can look something like this:

```javascript
// main configuration object
var config = {
    images: {
        // declare your images here..
    },

    sprites: {
        // declare your sprites here..
    },

    audio: {
        // declare your audio elements here..
    },

    fonts: [
        // declare your fonts here..
    ],

    onReady: function(media) {
        // this function will run immediately after the assets
        // have finished loading
    },

    draw: function() {
        // this will be the new `draw` function once the assets
        // are ready
    }
};

// start MAM
mamLoad(config);
```

All the properties shown in the code above are optional, so you don't *have*
to include them all. The following sections will go into more detail about
what each property does.

### Defining Images

You can define a group of images to be imported by declaring them in an
object under the `images` key of the main configuration object.

Each key of this object will be used as the identifier of an image, and its
value should be a string that specifies the URL where that image is being
hosted.

The following example defines two images, called `drawing` and `myPicture`
(you would have to make sure that the URLs are valid for your own images, of
course):

```javascript
var config = {
	images: {
		drawing: 'https://example.com/images/drawing.png',
		myPicture: 'http://www.example.com/myPicture.jpg'
	}
};
```

These images will be loaded and given back to you as objects of type
[`PImage`](http://processingjs.org/reference/PImage/) in the [main
callback](#main-callback).

**Important**: Because of security models that apply to the use of external images
on top of a HTML canvas, you should import your images from servers that
support a technology known as [CORS][cors] ---standing for *cross--origin
resource sharing*. Two free services that do support CORS are
[Dropbox][dropbox] and [Google Drive][google-drive], so you may try hosting
your images there.

You could also try importing images from a server without CORS support, but
doing so may result in technical problems for some users of your program. If
you want to try it anyway, you need to specify the `enableCORS` property in
your main configuration object, and set it to `false` (it's assumed to be
`true` by default). For example:

```javascript
var config = {
	images: {
		myPicture: 'http://server-without-cors.example.com/myPicture.jpg'
	},
    enableCORS: false
};
```

However, when your image is imported from a server without CORS, then once
you paint it into your canvas (using the `image` function, for example),
then the canvas becomes "tainted", which means that it becomes
*write--only* (it becomes impossible to read the state of its pixels), and
this could result in a situation where you can no longer save your program
in the Khan Academy, because part of the saving process involves obtaining
the picture from the canvas.

For more information on CORS and its implications, you may read [this
document][cors-more].


### Defining Sprites

For the purposes of this document, the term "sprite" will mean an image that
is "extracted" from another (probably larger) image.

For example, let's say that you have an image with a size of *300x200*
pixels, such that it's divided into four "panels" ---each panel covering a
corner from the main image, and with a size of *150x100* pixels. In order to
extract the four sprites from this larger image (we could call it a
*spritesheet*), first we need to define the sheet as a regular image:

```javascript
var config = {
	images: {
		panels: 'https://example.com/four_panels.png'
	}
};
```

With this in place, we can now specify sprites through the `sprites`
property of the main configuration object. The keys of this object will be
used as identifiers for the sprites, and the values must be objects that
declare the following keys:

*   `sheet` --- The name of the image (from the `images` property) from
    which the sprite(s) will be extracted.
*   `x` --- The *X* coordinate for the sprite inside the sheet.
*   `y` --- The *Y* coordinate.
*   `width` --- The width (in pixels) of the sprite.
*   `height` --- The height (in pixels) of the sprite.
*   `frames` --- *Optional*. An integer that indicates the number of sprites
    that should be extracted sequentially from the sheet. The sprites must
    be arranged horizontally, one after the other, and all must have the
    same size. If this property is used, then the corresponding object
    returned to you in the main callback will be an array of `PImage`
    objects, otherwise it will be a single `PImage`.

The following code specifies sprites for the four panels in our example. The
first two panels (from the top row) will be extracted as individual sprites,
while the two bottom panels will be extracted in an array of two elements:

```javascript
var config = {
	images: {
		panels: 'https://example.com/four_panels.png'
	},

	sprites: {
		topLeft: {
			sheet: 'panels',
			x: 0,
			y: 0,
			width: 150,
			height: 100
		},
		topRight: {
			sheet: 'panels',
			x: 150,
			y: 0,
			width: 150,
			height: 100
		},
		bottom: {
			sheet: 'panels',
			x: 0,
			y: 100,
			width: 150,
			height: 100,
			frames: 2
		}
	}
};
```

### Defining Audio Elements

Recent browsers have fairly good support for [HTML5
Audio](http://en.wikipedia.org/wiki/HTML5_Audio), a relatively recent
mechanism designed to manipulate audio content inside web documents.

With it, it's pretty straightforward to play sounds and music from your
programs. The main challenge at the moment is providing the audio in a
format that is supported by as many browsers as possible. It is recommended
that you choose files of type *audio/ogg* (typically with the file extension
`.ogg`), since that will probably work without too much trouble in all major
browsers supported by the Khan Academy environment.

MAM supports loading audio elements, and provides them as objects of type
[`HTMLAudioElement`](https://developer.mozilla.org/en-US/docs/Web/API/HTMLAudioElement)
in the main callback. Just specify the `audio` property in the main
configuration object, with an object where each key will be used as the
audio identifier, and its value is a string specifying the URL where the
audio file is hosted. You may also specify an array with one or more URLs,
in case you want to provide alternative formats for the same audio element.
Browsers will use the first audio file that it has support for.

An example:

```javascript
var config = {
	audio: {
		song: 'https://www.example.com/cool_song.ogg',
		boom: [
			'http://example.com/sounds/boom.mp3',
			'http://example.com/sounds/boom.wav'
		]
	}
};
```


### Defining Fonts

Displaying text is a very basic and important operation for many programs.
However, there is a common problem related to rendering text which is that
of *fonts*.

Usually when you choose a certain font for your program's text, it has to
belong to one of the very few widely available (or simply generic) font
families used in computing. Otherwise, there's a good chance that many users
who don't have the relevant font(s) installed in their systems will see your
program with a different, "fallback" font, and this could easily ruin the
layout of your interface or even make it altogether unusable.

Fortunately, there exist reasonable solutions to this problem nowadays. In
the context of web applications, for example, new fonts can be easily
imported using JavaScript and CSS. MAM provides support for loading fonts
released by the [Google Fonts](http://www.google.com/fonts/) project. You
may use any of the 600+ font families currently in their collection.

Simply define the `fonts` key in the main configuration object, setting its
value to an array of font family names. Just make sure the names correspond
to valid font family names from Google Fonts. For example:

```javascript
var config = {
	fonts: [ 'Roboto Slab', 'Milonga' ]
};
```

The previous example loads two font families, called *Roboto Slab* and
*Milonga*. Visit the Google Fonts website for more details about these and
other available fonts.

The fonts are given back to you in the main callback as objects of type
[`PFont`](http://processingjs.org/reference/PFont/), which you can then use
with the regular `textFont` and `text` functions.


### The Main Callback {#main-callback}

All the previous properties were used to declare which assets to import.
Now, in order to use them, you need to react in some way to the event that
is fired when all the assets have been loaded.

The first way in which you can react to that event is by specifying the
`onReady` property in the main configuration object. This should be set to a
function that will be called one time (and only one time) right after your
assets are ready. The `onReady` property acts as a *callback*, and it
receives a single parameter, which will be an object filled with all the
assets for your program. The structure of this object will mirror the way
you declared your assets in the main configuration object. For example, if
you declare an image as `config.images.myImage`, then you can refer to that
asset as `media.images.myImage` (provided that you use the name `media` for
the single argument to `onReady`).

Here's a short example:

```javascript
var config = {
	images: {
		somePicture: 'http://www.example.com/pic.jpg'
	},

	onReady: function(media) {
		background(255, 255, 255);
		image(media.images.somePicture, 0, 0);
	}
};

mamLoad(config);
```


### The `draw` Replacement

The example in the previous section illustrated how to display a static
image, by painting it one time inside the main callback. However, you might
want to use your assets in a more dynamic program. For this purpose, MAM can
replace your program's main `draw` function once the assets are ready.
Simply declare your `draw` replacement as the `draw` property inside the
main configuration object.

Example:

```javascript
var media;

var config = {
	images: {
		somePicture: 'http://www.example.com/pic.jpg'
	},

	onReady: function(loadedMedia) {
		media = loadedMedia;
	},

	draw: function() {
		background(255, 255, 255);
		image(media.images.somePicture, mouseX, mouseY);
	}
};

var draw = function() {
	background(255, 255, 255);
	textAlign(CENTER, CENTER);
	text("loading ...", 200, 200);
};

mamLoad(config);
```

As you can see, this approach allows you to use a regular `draw` function
(outside the configuration object), which will work as usual while the
assets are being loaded, so you can display a relevant message there, and
then the main actions for your program will occur in the new `draw` function
you declare inside the configuration object.


# Appendices

## Appendix A: Full Examples {#appendix-a}

### Importing Images

This example illustrates a simple way to draw a couple of images.

<script src="https://gist.github.com/lbv/5621644.js?file=mam-example-images.js"></script>

### Importing Images Without CORS

In this example, an image is imported from [Flickr][flickr]. However, since
their servers don't support CORS, the program has to disable it explicitly
by setting `enableCORS` to `false` in the configuration object.

This causes the canvas to be "tainted" once the image is drawn, so the only
chance to save this program reliably is to do it before the `image` function
is used to put the picture on the canvas. For this purpose, this program
uses the `draw` replacement, and displays a warning message before showing
the image.

<script
src="https://gist.github.com/lbv/5621644.js?file=mam-example-no-cors.js"></script>

### Importing Sprites

Extracts sprites from a single sheet. It illustrates defining a single
sprite, as well as a group of frames, that are then used in an animation.

<script src="https://gist.github.com/lbv/5621644.js?file=mam-example-sprites.js"></script>

### Importing Audio

Reproduces two sounds, one in OGG format and one in WAV format. It also
illustrated the use of the `loop` property in a `HTMLAudioElement` object.

<script src="https://gist.github.com/lbv/5621644.js?file=mam-example-audio.js"></script>

### Importing Fonts

Illustrates how to import a couple of different fonts.

<script src="https://gist.github.com/lbv/5621644.js?file=mam-example-fonts.js"></script>


## Appendix B: Places to Find Public Works {#appendix-b}

First of all, you may want to spend some time doing a little research with
your favourite web search tool. By choosing your search terms carefully,
according to your needs and preferences, you will probably find sites that
will be much more relevant to you.

Having said that, here's a few recommendations:

*   If you're looking primarily for material for video--games, a good place
    to start is this: [Art asset resources][art-resources] from
    FreeGameDevWiki.

*   In terms of music, there are many so--called "independent" artists that
    share their music with permissive licenses that you could use in your
    programs. A few good places to check out are
    [Jamendo](http://www.jamendo.com/),
    [SoundCloud](https://soundcloud.com/) and
    [Bandcamp](http://bandcamp.com/).

*   There are many places where you can find works that are considered in
    the *public domain*. A few good places to visit are: [the Library of
    Congress][loc], [Great Images in NASA][grin], [the New York Public
    Library][nypl], and [Wikimedia Commons][wikicommons], among many others.


## Appendix C: General Tips

*   Use sprites whenever it makes sense ---for example, if you have
    a series of images for a single animation, or a group of related and
    similar drawings. In practice, extracting sprites from a single sheet
    tends to be much more efficient than loading many individual images from
    an external host.

*   If possible, try not to make your program too dependant on the
    availability of your media assets. For example, it could happen that
    sounds in certain formats (like MP3, for example) do not work reliably
    in many browsers, so if you're providing your audio files in MP3 format
    only, then keep in mind that many users may not hear any sounds at all;
    adjust your program accordingly.

*   Do not go overboard importing assets. Not everyone connects to the
    Internet through fast lines, and not everyone uses computers or devices
    with particularly good processors (think of tablets or netbooks, for
    example). Also consider that, depending on the terms of service from
    your hosting provider, using large files may also result in larger bills
    or poor availability (if you're subject to bandwidth limits or similar
    restrictions). Be reasonable and aim for efficient use of all of your
    resources.

*   Related to the previous point, try to compress your assets as much as
    possible. Consider that for most casual programs, you don't really need
    very high quality sound or graphics. Discussing effective compression
    techniques is beyond the scope of this document, but it's certainly a
    very good idea to look into it if you plan to use media assets
    frequently in your programs.

*   It also might be worth your time to learn the basics of *computer system
    usability* and *user experience*. This is a big topic by itself, but
    here's a few tips: Try to avoid "busy" designs where you try to fill
    every pixel of your canvas with strong visuals. Be consistent in your
    style. Don't start playing sounds or music at the very beginning of your
    program without user intervention. If possible, try to guide your design
    decisions by how people actually use your program, as opposed to how you
    imagine they should use your program.


## Appendix D: This Tool and the K.A.

As a user of the Khan Academy for some time, I've had the opportunity to
notice a number things pertaining its community and the behaviour of
different types of users of the Computer Science section. I'm aware of the
potential misuse that a tool like MAM could represent in this context.

I've repeatedly considered this situation from many different angles, and my
conclusion (at least for the time being) is that I do think that exploring
previously untapped aspects of the programming environment is useful in
itself and, although it could be subject to some degree of abuse (like any
other type of technology), I lean towards trusting the current mechanisms in
place to moderate the content generated by Khan Academy users.

I realize that when a new tool comes along that provides a greater degree of
flexibility for the creation of public creative works, there can be concerns
regarding security as well as social behaviour behind it. I'm fully prepared
to contribute in any way I can to provide the most secure as well as
useful and beginner--friendly tool possible. It's perfectly possible that
new restrictions might be considered for the programming environment as a
result of something like MAM. Nevertheless, it's my intention to advocate
for a responsible use from day one, and it is my hope that, as the saying
goes, the baby is not thrown out along with the bath water.

In case these issues interest you, I have written more about this topic in
the following document: [The Khan Academy C.S.
Sandbox](http://lbv.github.io/ka-cs-programs/other/sandbox.html).

I recently came across [a message][jimbo-message] from [Jimmy Wales][jimbo]
that I think sums up nicely my take on these issues:

> Rather than make it hard for users to do what they want to do, on the
> (very valid) assumption that some of them will do bad things, or things they
> don't really want to do, it is better to make it easy for users to recover
> from those mistakes, and for others to recover easily from any side effects
> of those mistakes.

- - -

[art-resources]: http://freegamedev.net/wiki/Free_3D_and_2D_art_and_audio_resources
[cc]: http://creativecommons.org/
[cors]: http://en.wikipedia.org/wiki/Cross-origin_resource_sharing
[cors-more]: https://developer.mozilla.org/en-US/docs/HTML/CORS_Enabled_Image
[dropbox]: https://www.dropbox.com/
[flickr]: http://www.flickr.com/
[google-drive]: https://drive.google.com/
[grin]: http://grin.hq.nasa.gov/
[jimbo]: http://en.wikipedia.org/wiki/Jimmy_Wales
[jimbo-message]: http://ask.slashdot.org/comments.pl?sid=3782789&cid=43813915
[loc]: http://www.loc.gov/
[mam-demo]: http://www.khanacademy.org/cs/mam-demo/1663711308
[nypl]: http://digitalgallery.nypl.org/nypldigital/
[pjs]: http://processingjs.org/
[wikicommons]: http://commons.wikimedia.org/wiki/Main_Page
