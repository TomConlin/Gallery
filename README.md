gallery.sh
==========

[![Build Status](https://travis-ci.org/Cyclenerd/gallery_shell.svg?branch=master)](https://travis-ci.org/Cyclenerd/gallery_shell)

Derived from https://travis-ci.org/Cyclenerd/gallery_shell (Thanks!)


Bash Script to generate static web galleries.

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

This combination of features is sufficient for the efficient presentation of my various projects.

All you need is a place to host your plain html/css and image files.



Usage
-----

	gallery.sh [-t <title>] [-d <thumbdir>] [-h]:
		[-t <title>]	 sets the title (default: Gallery)
		[-d <thumbdir>]	 sets the thumbdir (default: __thumbs)
		[-h]		 displays help (this message)

Example: `gallery.sh` or `gallery.sh -t "My Photos" -d "thumbs"`

`gallery.sh` works in the **current** directory.  Just load the index.html in a browser see the output.

The directory should contain a bunch of JPEG (.jpeg or .jpg  of any case) files. It does not work recursively.


Differences
----------

This version differs from the original in a number of ways.

  - Does not discourage spiders/robots or indexing (I put stuff up to be found)
  - Does not output camera metadata other than when the picture was taken.
  - Does not support movies and downloads (just pictures)
  - Clicking on gallery images get you to the full original image.
  	- Save that as you will for downloading
  - Display order is strictly chronological.
  - Include a text file with same base-name as the image for a description blurb. 
 
  - Things I wish I had remained blissfully unaware of such as 
  	- javascript framework versions numbers
  	- supported glyficon fonts v.s. svg icons  


Demo (of the original version nor this one)
----

https://www.nkn-it.de/gallery_shell_demo/

Screenshots
-----------

![Gallery](http://i.imgur.com/TOxgphm.jpg)

![Image](http://i.imgur.com/iqQzst2.jpg)

License
-------
GNU Public License version 3.
Please feel free to fork and modify this on GitHub (https://github.com/Cyclenerd/gallery_shell).