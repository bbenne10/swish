#!/bin/sh
# sw - suckless webframework - 2012 - MIT License - nibble <develsec.org>

sw_filter() {
	for b in $BL; do
		[ "$b" = "$1" ] && return 0
	done
}

sw_main() {
	$MDHANDLER $1
}

sw_menu() {
	echo "<ul>"
	[ -z "`echo $1 | grep index.md`" ] && echo "<li><a href=\"index.html\">.</a></li>"
	[ "`dirname $1`" != "." ] && echo "<li><a href=\"../index.html\">..</a></li>"
	FILES=`ls \`dirname $1\` | sed -e 's,.md$,.html,g'`
	for i in $FILES ; do
		sw_filter $i && continue
		NAME=`echo $i | sed -e 's/\..*$//' -e 's/_/ /g'`
		[ -z "`echo $i | grep '\..*$'`" ] && i="$i/index.html"
		echo "<li><a href=\"$i\">$NAME</a></li>"
	done
	echo "</ul>"
}

sw_page() {
	# Header
	cat << _header_
<!doctype html>
<html>
<head>
<title>${TITLE}</title>
<link rel="icon" href="/favicon.png" type="image/png">
<meta charset="UTF-8">
_header_
	# Stylesheet
	sw_style
	cat << _header_
</head>
<body>
<div class="wrapper">
<header>
<h1 class="header_title">
<a href="`echo $1 | sed -e 's,[^/]*/,../,g' -e 's,[^/]*.md$,index.html,g'`">${TITLE}</a> <span class="headerSubtitle">${SUBTITLE}</span>
</h1>
</header>
<div class="content">
_header_
    # Menu
    echo "<div class=\"side_bar\">"
    sw_menu $1
    echo "</div>"
    # Body
    echo "<div class=\"main\">"
    sw_main $1
    echo "</div>"
    # Footer
    cat << _footer_
<footer>
<div class="right"><a href="https://github.com/bbenne10/sw">Powered by sw</a></div>
</footer>
</div>
</div>
</body>
</html>
_footer_
}

sw_style() {
    if [ $STYLE ]; then
        echo '<link rel="stylesheet" type="text/css" href="'$STYLE'">'
	fi
}

# Set input dir
IDIR="`echo $1 | sed -e 's,/*$,,'`"
if [ -z "$IDIR" ] || [ ! -d $IDIR ]; then
	echo "Usage: sw [dir]"
	exit 1
fi

# Load config file
if [ ! -f $PWD/sw.conf ]; then
	echo "Cannot find sw.conf in current directory"
	exit 1
fi
. $PWD/sw.conf

# Setup output dir structure
CDIR=$PWD
IDIR=`readlink -f $IDIR`
ODIR="$CDIR/`basename $IDIR`.static"

rm -rf $ODIR
mkdir -p $ODIR
find $IDIR \( -path "$IDIR/.git*" -o -path "$ODIR" -o -path "$IDIR/sw.conf" \) -prune -o -not -path $IDIR -exec cp -r '{}' $ODIR \;

rm -f `find $ODIR -type f -iname '*.md'`
if [ -f $CDIR/$STYLE ]; then
   cp $CDIR/$STYLE $ODIR/$STYLE
fi

# Parse files
cd $IDIR
FILES=`find . -iname '*.md' | sed -e 's,^\./,,'`
for a in $FILES; do
	b="$ODIR/`echo $a | sed -e 's,.md$,.html,g'`"
	echo "* $a"
	sw_page $a > $b;
done

exit 0
