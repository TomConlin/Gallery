gallery.sh
==========
Scripts to generate static web galleries.

Derived from:
  - https://github.com/Cyclenerd/gallery_shell
  - https://github.com/wavexx/fgallery

  Thanks!

Each had some features I wanted and others I do not need.
My use case is specifically targeted towards documenting
"things" built; a visual log on the web without much front end effort.


Workflow
---------

 - Make something and take pictures as you go.
 - Place the images you think are relevant in a directory somewhere.

 If you want to include text blurbs for the images:
 you could just open a text editor (not word processor) and type out a file
 for each and save with the same base name as the image and a '.txt' extension.
 Only the simplest subset of printable ascii characters will be accepted so,
 no point in getting too fancy.

 If that seems tedious and you can tolerate python, use the helper script.

 From *this* directory enable your python virtual environment & run `./fcaption.py``

 Apologies if this is your first introduction to [python](https://xkcd.com/1987/)

   - perhaps install pipenv or whatever flavor you get support for
   cross your parts, and try:

   `pipenv run caption`

  aside: Since the QT graphics library automatically adjusts for your screen resolution ...
  I include a `.env`  file here that lets us over ride their choice of font size.

  Navigate to the directory the images you want to caption are and caption them.
  has the advantage of keeping the image & text together when working on it
  and being able to navigate back and forth between sequential images.
  (if you are me you will need to run the generated text through a spellchecker)

With (or without) blurbs in place.
Over in the directory the images are in (not launched from this one).
run the `gallery.sh`  script

Usage
-----

	gallery.sh [-t <title>] [-d <thumbdir>] [-h]:
		[-t <title>]	 sets the title (default: Gallery)
		[-d <thumbdir>]	 sets the thumbnail directory (default: __thumbs)
		[-h]		 displays help (this message)

Example: `gallery.sh`  or `gallery.sh -t "My Photos" -d "thumbs"`
`gallery.sh` works in the **current** directory.

Just load the resulting index.html in a browser see the output.

The directory should contain a bunch of JPEG (.jpeg or .jpg  of any case) files.
It does __not__ run recursively.




Requirements
------------
* ImageMagick (http://www.imagemagick.org/) for the `convert` utility.

* Bootstrap (bundled)  bootstrap.min.js  version 4.5.0 at this time
		- css   (https://getbootstrap.com/docs/4.5/getting-started/download/)

- exif (http://www.sourceforge.net/projects/libexif)

These should be fetch-able via any reasonable package management system.

Overview
--------
`gallery.sh` is simple bash shell script which generates static html thumbnail (image, photo) galleries using the `convert` and `exif` command-line utilities.
It requires no special server-side script to run to view image galleries because everything is pre-rendered.
It offers several features:
* Responsive layout
* Thumbnails which fill the browser efficiently
* View/Fetch the original image file
* Simple Bootstrap CSS layout
* Locally previewable galleries by accessing images locally (e.g. file:///home/nils/pics/gallery/index.html)
* Auto-rotation of vertical images
* Chronological display order
* Optional inclusion of a text blurb

This combination of features is sufficient for the efficient presentation of
my various projects.

All you need is a place to host your plain html/css and image files.


Differences
----------

This version differs from the original in a number of ways.

  - Does not discourage spiders/robots or indexing (I put stuff up to be found)
  - Does not output camera metadata other than when the picture was taken.
  - Does not support movies and downloads (just pictures)
  - Clicking on gallery images get you to the full original image.
  	- Save that as you will for downloading
  - Display order is strictly chronological.
  - Include a `.txt` file with same base-name as the image for a description blurb.

  - Things I wish I had remained blissfully unaware of such as
  	- javascript framework versions numbers
  	- supported glyficon fonts v.s. svg icons


Demo
----
[Laser cut Sudiball](https://ix.cs.uoregon.edu/~tomc/Hobbies/Astronomy/ATM/SudiBall/RoguesGallery/OSP_2019)


License
-------
GNU Public License version 3.
Please feel free to fork and modify this on GitHub
 - Original:   https://github.com/Cyclenerd/gallery_shell
 - This Fork:  https://github.com/TomConlin/Gallery
