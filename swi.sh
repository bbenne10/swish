#!/usr/bin/env bash
# swi.sh: Suckless-ish web framework
# or "Man I really wish bash had real multiline strings"
BODY_TMPL=$(cat <<EOF
  <!doctype html>
  <html>
    <head>
      <meta charset=\"UTF-8\">
      <meta http-equiv="Content-Type" content="text/html;charset=UTF-8" />
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

TITLE="title"
SUBTITLE="subtitle"
BL=""
STYLE="style.css "

swish_filter() {
  for b in $BL; do
    [ "$b" = "$1" ] && return 0
  done
}

swish_style() {
  cwd=$PWD
  pushd "$(dirname "$1")" >/dev/null|| return
  cd "$(dirname "$1")" || return
  rel_cwd=$(realpath --relative-to="$PWD" "$cwd")

  rel_style=$(find "$rel_cwd" -maxdepth 1 -name "$STYLE")
  minify --type css "$rel_style" -o "$rel_style"

  if [ "$rel_style" ]; then
    echo "<link rel=\"stylesheet\" type=\"text/css\" href=\"$rel_style\">"
  fi
  popd >/dev/null|| return
}

swish_menu() {
  if [[ "$IMPLICIT_INDEX_LINKING" == 1 ]]; then
    echo "<li><a href=\"/\">Home</a></li>"
  else 
    echo "<li><a href=\"./index.html\">Home</a></li>"
  fi
  dname=$(dirname "$1")
  while read -r file; do
    swish_filter "$file" && continue
    NAME="${file//_/ /}"  # underscores to spaces
    NAME="${NAME%.md}"    # Remove .md suffix
    NAME="${NAME%/index}" # Remove "index" suffix (if exists)
    NAME="${NAME#\./}"    # Remove "./" prefix
    if [[ $(basename "$file") == "index.md" ]]; then
      # This is a folder index of some sort.
      if [[ $(dirname "$file") == "." ]]; then
        continue
      elif [[ "$IMPLICIT_INDEX_LINKING" == 1 ]]; then
        file=${file%index.md}
      fi
    fi
    file=${file//.md/.html}
    echo "<li><a href=\"$file\">$NAME</a></li>"
  done < <(find "$dname" -iname '*.md')
}

swish_body() {
    comrak --gfm "$1" | minify --type html
}

swish_page() {
    style=$(swish_style "$1")
    menu=$(swish_menu "$1")
    # shellcheck disable=SC2059
    nav=$(printf "$NAV_TMPL" "$menu")
    body=$(swish_body "$1")
    # shellcheck disable=SC2059
    printf "$BODY_TMPL" "$TITLE" "$style" "$TITLE" "$SUBTITLE" "$nav" "$body"
}

if [ "$#" != 1 ]; then
  >&2 echo  "Usage: $0 [dir]"
  exit 1
fi

# Set input dir
IDIR="${1%/}"
if [ -z "$IDIR" ] || [ ! -d "$IDIR" ]; then
  >&2 echo  "Usage: $0 [dir]"
  exit 1
fi

# Load config file
if [ ! -f "$PWD/swish.conf" ]; then
  >&2 echo "ERROR: Cannot find swish.conf in current directory"
  exit 1
fi

# Override previous definitions (top of file)
# disable shellcheck here since we already have definitions
# shellcheck disable=SC1091
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
  echo "* $CDIR/$STYLE -> $(realpath --relative-to="$CDIR" "$ODIR")/$STYLE"
  cp "$CDIR/$STYLE" "$ODIR/$STYLE"
fi

# Parse files
pushd "$IDIR" >/dev/null || exit
while read -r file; do
  b="$ODIR/${file%.md}.html"
  echo "* $file -> $(realpath --relative-to="$CDIR" "$b")"
  swish_page "$file" > "$b"
done < <(find . -iname '*.md' | sed -e 's,^\./,,')
popd >/dev/null|| exit

exit 0
