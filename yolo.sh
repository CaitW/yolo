#!/bin/bash

# Find our font before we do anything.
FONT_PATH="$(find $HOME/Library/Fonts/ -name 'Roboto-Bold.ttf')"
if [ "$FONT_PATH" == "" ]; then
  FONT_PATH="$(find /Library/Fonts/ -name 'Roboto-Bold.ttf')"
fi

contains () {
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}

usage () {
  if [ "$1" != "" ]; then
    echo -e "Error: $1\n" >&2
  fi
  echo "usage: $0 [options] <message>"
  echo
  echo "Options:"
  echo
  echo "  -h                Show this help message"
  echo
  echo "  -o <output.gif>   Path to output gif. Default: yolo.gif"
  echo
  echo "  -c <color>        Choose color set, valid options are:"
  echo "                    red, orange, yellow, green, blue, purple,"
  echo "                    pink, black, white.  Default: blue"
  echo
  echo " -w                 Force white text color"
  exit 1
}

if [ "$FONT_PATH" == "" ]; then
  usage "Could not find font. Is it installed?"
fi

VALID_COLORS=("red" "orange" "yellow" "green" "blue" "purple" "pink" "black" "white")
COLOR="blue"
OUTPUT="yolo.gif"
FORCE_WHITE_TEXT=0

while getopts ":c:o:hw" opt; do
  case $opt in
    h)
      usage
      ;;
    w)
      FORCE_WHITE_TEXT=1
      ;;
    c)
      if contains "$OPTARG" "${VALID_COLORS[@]}"; then
        COLOR="$OPTARG"
      else
        usage "Invalid color: $OPTARG"
      fi
      ;;
    o)
      OUTPUT="$OPTARG"
      ;;
    \?)
      usage "Invalid option: -$OPTARG"
      ;;
    :)
      usage "Option -$OPTARG requires an argument."
      exit 1
      ;;
  esac
done

shift $(($OPTIND - 1))

MESSAGE="$*"

if [ "$MESSAGE" == "" ]; then
  usage "A message is required."
fi

case $COLOR in
  red)
    BACKGROUND="#ffffff"
    FILL="#8c2738"
    ;;
  orange)
    BACKGROUND="#f47820"
    FILL="#8e4402"
    ;;
  yellow)
    BACKGROUND="#f0ce15"
    FILL="#947c00"
    ;;
  green)
    BACKGROUND="#51bb7b"
    FILL="#267048"
    ;;
  blue)
    BACKGROUND="#FFFFFF"
    FILL="#01516e"
    ;;
  purple)
    BACKGROUND="#8351a0"
    FILL="#4e2760"
    ;;
  pink)
    BACKGROUND="#e0368c"
    FILL="#851252"
    ;;
  black)
    BACKGROUND="#5d5e5e"
    FILL="#262727"
    ;;
  white)
    BACKGROUND="#ffffff"
    FILL="#000000"
    ;;
esac

if [ "$FORCE_WHITE_TEXT" == 1 ]; then
  FILL="#ffffff"
fi

# Make a "unique" prefix for this run
PREFIX="$(head -c 32 /dev/urandom  | shasum | cut -b 1-10)"

# Generate image from text input
convert -background "$BACKGROUND" -fill "$FILL" -font "$FONT_PATH" -density 200 -pointsize 100 "label:${MESSAGE}" "./tmp/${PREFIX}_label.png"

# Resize to 128px high
convert -resize x128 "./tmp/${PREFIX}_label.png" "./tmp/${PREFIX}_sized.png"

# Add white space to front and back for empty frames
WIDTH="$(identify -format "%[fx:w]" "./tmp/${PREFIX}_sized.png")"
CANVAS_SIZE=$(($WIDTH + 276)) # 128 PX in front, 148 in back
convert -size ${CANVAS_SIZE}x128 "xc:$BACKGROUND" "./tmp/${PREFIX}_canvas.png"

magick composite "./tmp/${PREFIX}_sized.png" "./tmp/${PREFIX}_canvas.png" -geometry +128+0 -colorspace RGB "./tmp/${PREFIX}_padded.png"

# Generate individual frames
OFFSET=0
I=0
LIMIT=$(($CANVAS_SIZE - 128))
while [ $OFFSET -lt $LIMIT ]; do
  convert "./tmp/${PREFIX}_padded.png" -crop "128x128+${OFFSET}+0!" "$(printf "./tmp/${PREFIX}_frame_%05d.png" $I)"
  I=$(($I + 1))
  OFFSET=$(($OFFSET + 10))
done

# Compile to gif
convert -delay 6 -loop 0 +repage "./tmp/${PREFIX}_frame_*.png" "$OUTPUT" 

# Smush it
gifsicle -bO --colors 256 "$OUTPUT"

# Clean up!
rm ./tmp/${PREFIX}_*.png