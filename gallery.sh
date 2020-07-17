#!/bin/bash

# gallery.sh
#
# Forked from: Nils Knieling - https://github.com/Cyclenerd/gallery_shell
# Inspired by: Shapor Naghibzadeh - https://github.com/shapor/bashgal

#########################################################################################
#### Configuration Section
#########################################################################################

height_small=187
height_large=768
quality=85
thumbdir="__thumbs"
htmlfile="index.html"
parentpage="../index.html"  # navigation Up from the top level page created
title="${PWD##*/}"          # name of the current directory as default
footer='Created with gallery.sh'

# Use convert from ImageMagick
convert="/usr/bin/convert"
# Use JHead for EXIF Information
exif="/usr/bin/exif"
# exif="/usr/bin/jhead"

# Bootstrap (currently 4.5.0)
# use local cache for css
# check https://getbootstrap.com/docs/4.5/getting-started/download/
# for latest

stylesheet="css/bootstrap.min.css"

# Debugging output
# true=enable, false=disable
debug=true

# The cloned git reposity this script is in to copy the css dir from
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)"
#########################################################################################
#### End Configuration Section
#########################################################################################

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)"
me=$(basename "$0")
datetime=$(date -u "+%Y-%b-%d %H:%M:%S")
datetime+=" UTC"

function usage {
	returnCode="$1"
	echo -e "Usage: $me [-t <title>] [-d <thumbdir>] [-h]:
	[-t <title>]\\t sets the title (default: $title)
	[-d <thumbdir>]\\t sets the thumbdir (default: $thumbdir)
	[-h]\\t\\t displays help (this message)"
	exit "$returnCode"
}

function reformat_date(){
	date -d $(exif -m -t DateTime "$1"|cut -c1-10|tr ':' '-') "+%Y %b %d"
}

function debugOutput(){
	if [[ "$debug" == true ]]; then
		echo "$1" # if debug variable is true, echo whatever's passed to the function
	fi
}

function getFileSize(){
	# Be aware that BSD stat doesn't support --version and -c
	if stat --version &>/dev/null; then
		# GNU
		myfilesize=$(stat -c %s "$1" | awk '{$1/=1000000;printf "%.2fMB\n",$1}')
	else
		# BSD
		myfilesize=$(stat -f %z "$1" | awk '{$1/=1000000;printf "%.2fMB\n",$1}')
	fi
	echo "$myfilesize"
}

while getopts ":t:d:h" opt; do
	case $opt in
	t)
		title="$OPTARG"
		;;
	d)
		thumbdir="$OPTARG"
		;;
	h)
		usage 0
		;;
	*)
		echo "Invalid option: -$OPTARG"
		usage 1
		;;
	esac
done

debugOutput "- $me : $datetime"

### Check Commands
command -v $convert >/dev/null 2>&1 || { echo >&2 "!!! $convert it's not installed.  Aborting."; exit 1; }
command -v $exif >/dev/null 2>&1 || { echo >&2 "!!! $exif it's not installed.  Aborting."; exit 1; }

### Create Folders
[[ -d "$thumbdir" ]] || mkdir "$thumbdir" || exit 2
# keep resources local

[[ -d css ]] || mkdir css && rsync -r "$REPO"/css/* css|| exit 2

heights[0]=$height_small
heights[1]=$height_large
for res in ${heights[*]}; do
	[[ -d "$thumbdir/$res" ]] || mkdir -p "$thumbdir/$res" || exit 3
done

#### Create Startpage
debugOutput "$htmlfile"
cat > "$htmlfile" << EOF
<!DOCTYPE HTML>
<html lang="en">
<head>
	<meta charset="utf-8">
	<title>$title</title>
	<meta name="viewport" content="width=device-width">
	<link rel="stylesheet" href="$stylesheet">
	<base href="./">
</head>
<body>
<div class="container">
	<div class="row">
		<div class="col-xs-2"><a href="$parentpage">Up..&nbsp;</a></div>
		<div class="col-xs-10">
			<div class="page-header"><h1>$title</h1></div>
		</div>
	</div>
EOF

### Photos (JPG)

if [[ $(find . -maxdepth 1 -type f -iname "*.[jJ][pP]*[gG]" | wc -l) -gt 0 ]]; then
echo '<div class="row">' >> "$htmlfile"
## Generate Images
numfiles=0

# order chronologicaly (by date camera thought it was)
# ... might want to split this out into its own fx
# 0x001d GPS Date  
# 0x0132 Date and Time  
# 0x9003 Date and Time (Original) 
# 0x9004 Date and Time (Digitized) 
# ----------------------------------
# composite-term    derived from
# --------------    ------------

#DateCreated 	 	Kodak:YearCreated
#					Kodak:MonthDayCreated

#DateTimeCreated 	IPTC:DateCreated
#					IPTC:TimeCreated 	 

#DateTimeOriginal 	DateTimeCreated
#					DateCreated
#					TimeCreated

#DateTimeOriginal 	ID3:RecordingTime
# 					ID3:Year
#					ID3:Date
#					ID3:Time 	 
 
# DigitalCreationDateTime 	IPTC:DigitalCreationDate
#							IPTC:DigitalCreationTime
# ----------------------------------
# GPSDateTime 	GPS:GPSDateStamp
#   			GPS:GPSTimeStamp 	 
# GPSDateTime	Parrot:GPSLatitude
# 				SampleTime

SNAPS=$(for img in *.[jJ][pP]*[gG] ; do
	echo -e "$img" "\t" $(exif -m -t DateTimeOriginal "$img")
done | sort -k2d | tr -s ' ' |cut -f1 -d ' ' | tr '\n' ' ')

for filename in $SNAPS ; do
	filelist[$numfiles]=$filename

	(( numfiles++ ))
	for res in ${heights[*]}; do
		if [[ ! -s $thumbdir/$res/$filename ]]; then
			debugOutput "$thumbdir/$res/$filename"
			$convert -auto-orient -strip -quality $quality -resize x$res "$filename" "$thumbdir/$res/$filename"
		fi
	done
	cat >> "$htmlfile" << EOF
<div class="col-md-3 col-sm-12">
	<p>
		<a href="$thumbdir/$filename.html"><img src="$thumbdir/$height_small/$filename" alt="" class="img-responsive"></a>
		<div class="hidden-md hidden-lg"><hr></div>
	</p>
</div>
EOF

[[ $((numfiles % 4)) -eq 0 ]] && echo '<div class="clearfix visible-md visible-lg"></div>' >> "$htmlfile"
done
echo '</div>' >> "$htmlfile"

## Generate the HTML Files for Images in thumbdir
file=0
while [[ $file -lt $numfiles ]]; do
	filename=${filelist[$file]}
	prev=""
	next=""
	[[ $file -ne 0 ]] && prev=${filelist[$((file - 1))]}
	[[ $file -ne $((numfiles - 1)) ]] && next=${filelist[$((file + 1))]}
	imagehtmlfile="$thumbdir/$filename.html"
	snapdate=$(reformat_date "$filename")
	filesize=$(getFileSize "$filename")
	debugOutput "$imagehtmlfile"
	cat > "$imagehtmlfile" << EOF
<!DOCTYPE HTML>
<html lang="en">
<head>
<meta charset="utf-8">
<title>$filename $snapdate</title>
<meta name="viewport" content="width=device-width">
<link rel="stylesheet" href="../$stylesheet">
</head>
<body>
<div class="container">
<div class="row">
	<div class="col-xs-12">
		<div class="page-header"><h2>
			<span class="text-muted">$filename&nbsp;&nbsp;&nbsp;&nbsp;$snapdate </span>
		</h2></div>
	</div>
</div>
EOF

	# Pager
	{	echo '<div class="row">' ;
		if [[ $prev ]]; then 
			echo '<div class="col-sm-4"><a href="'"$prev"'.html">&#x21D0; Previous</a></div>' ;
		else
			echo '<div class="col-sm-4"><a href=""></a></div>' ;
		fi
		echo "<div class=\"col-sm-4\"><a href=\"../$htmlfile\">&#x21D1;$title&#x21D1;</a></div>" ;
		[[ $next ]] && echo '<div class="col-sm-4"><a href="'"$next"'.html">Next &#x21D2;</a></div>' ;
		echo '</div>' ;
	} >> "$imagehtmlfile"

	if [[ -e ${filename%.*}.txt ]]; then
		# not perfect; only passed simple words & standard punctionation
		blurb="$( tr -s '/' '_'  < ${filename%.*}.txt | tr -cd '[:alnum:][:space:][:punct:]' )"
		echo -e "BLURB for $filename is \n$blurb"
    else
		blurb=""
	fi

	cat >> "$imagehtmlfile" << EOF
<div class="row">
	<div class="col-xs-6">
		<p><a href="../$filename"><img src="$height_large/$filename" class="img-responsive" alt=""></a></p>
	</div>
	<div class="col-xs-6">
		<pre>
	Name:  $filename
	Date:  $snapdate
	Size:  $filesize
	----------------

$blurb

		</pre>
	</div>
</div>
EOF

	# Footer
	cat >> "$imagehtmlfile" << EOF
</div>
</body>
</html>
EOF
	(( file++ ))
done

fi

### Footer
cat >> "$htmlfile" << EOF
<hr>
<footer>
	<p>$footer</p>
	<p class="text-muted">$datetime</p>
</footer>
</div> <!-- // container -->
</body>
</html>
EOF

debugOutput "= done :-)"

