#!/usr/bin/env bash
scrot ./tmp/screen.png
TMPBG=./tmp/screen.png
convert $TMPBG -scale 10% -scale 1000% $TMPBG
dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Stop
i3lock -i $TMPBG