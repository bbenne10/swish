#!/usr/bin/env bash
# swi.sh: Suckless-ish web framework
# or "Man I really wish bash had real multiline strings"
BODY_TMPL=$(cat <<EOF
  <!doctype html>
  <html>
    <head>
      <meta charset=\"UTF-8\">
      <title>%s</title>
      <link rel=\"icon\" href=\"/favicon.png\" type=\"image/png\">
      %s
    </head>
    <body>
      <header>
       <h1>%s</h1>
       <h2>%s</h2>
      </header>
      %s
      <main>
        %s
      </main>
      <footer>
        <a href="https://github.com/bbenne10/swish">Powered by swish</a>
      </footer>
    </body>
  </html>
EOF
)
NAV_TMPL=$(cat <<EOF
  <nav>
    <ul>
      %s
    </ul>
  </nav>
EOF
)

swish_filter() {
	for b in $BL; do
		[ "$b" = "$1" ] && return 0
	done
}

swish_style() {
  # TODO: Can this be simplified with:
  #  cp *.css $ODIR
  #  find $ODIR -name "*.css" -printf "<a...href="...""?
  # difficulty will be making path relative to $ODIR, so maybe just pushd first?
  cwd=$PWD
  cd `dirname $1`
  rel_cwd=$(realpath --relative-to=$PWD $cwd)

  rel_style=$(find "$rel_cwd" -maxdepth 1 -name "$STYLE")

  if [ $rel_style ]; then
    echo '<link rel="stylesheet" type="text/css" href="'$rel_style'">'
  fi
  cd $cwd
}

swish_menu() {
  if [[ "$IMPLICIT_INDEX_LINKING" == 1 ]]; then
    echo "<li><a href=\"/\">Home</a></li>"
  else 
    echo "<li><a href=\"./index.html\">Home</a></li>"
  fi
  dname=$(dirname $1)
  readarray -d '' FILES < <(find "$dname" -name "*.md")

  for i in $FILES; do
		swish_filter "$i" && continue
    NAME="${i//_/ /}"  # underscores to spaces
    NAME="${NAME%.md}"    # Remove .md suffix
    NAME="${NAME%/index}" # Remove "index" suffix (if exists)
    NAME="${NAME#\./}"    # Remove "./" prefix
    if [[ $(basename "$i") == "index.md" ]]; then
      # This is a folder index of some sort.
      if [[ $(dirname "$i") == "." ]]; then
        continue
      elif [[ "$IMPLICIT_INDEX_LINKING" == 1 ]]; then
        i=${i%index.md}
      fi
    fi
    i=${i//.md/.html}
		echo "<li><a href=\"$i\">$NAME</a></li>"
	done
}

swish_body() {
	comrak --gfm $1
}

swish_page() {
    style=$(swish_style "$1")
    menu=$(swish_menu "$1")
    nav=$(printf "$NAV_TMPL" "$menu")
    body=$(swish_body "$1")
    printf "$BODY_TMPL" "$TITLE" "$style" "$TITLE" "$SUBTITLE" "$nav" "$body"
}

# Set input dir
IDIR="${1%/}"
if [ -z "$IDIR" ] || [ ! -d "$IDIR" ]; then
  echo "Usage: sw [dir]"
  exit 1
fi

# Load config file
if [ ! -f "$PWD/swish.conf" ]; then
  echo "Cannot find swish.conf in current directory"
  exit 1
fi
. "$PWD/swish.conf"

# Setup output dir structure
CDIR=$PWD
IDIR=$(readlink -f "$IDIR")
ODIR="$CDIR/out"

rm -rf "$ODIR"
mkdir -p "$ODIR"
find "$IDIR" \( -path "$IDIR/.git*" -o -path "$ODIR" -o -path "$IDIR/swish.conf" \) \
     -prune -o -not -path "$IDIR" \
     -exec cp -r '{}' "$ODIR" \;

find "$ODIR" -type f -iname '*.md' -exec rm '{}' \;
if [ -f "$CDIR/$STYLE" ]; then
  echo "* $CDIR/$STYLE -> $(realpath --relative-to=$CDIR $ODIR)/$STYLE"
  cp "$CDIR/$STYLE" "$ODIR/$STYLE"
fi

# Parse files
pushd "$IDIR" >/dev/null || exit
FILES=$(find . -iname '*.md' | sed -e 's,^\./,,')
for a in $FILES; do
  b="$ODIR/${a%.md}.html"
  echo "* $a -> $(realpath --relative-to=$CDIR $b)"
  swish_page "$a" > "$b"
done
popd || exit

exit 0
