#!/bin/bash -e
# Copyright 2024 Michael Pozhidaev <msp@luwrain.org>
# The LUWRAIN Project, GPL v.3
# Des major (needs to be checked)

INS=46
TEMPO=35
VOL=120

./melody.sh $INS $VOL \
	    65 $TEMPO 56 $TEMPO 63 $TEMPO 61 $TEMPO 75 45 77 50 85 300 | csvmidi - > _melody.midi
timidity -Ow _melody.midi > /dev/null
sox -D --norm=-0.1 _melody.wav _melody1.wav fade t 0 0.3 0.3

./melody.sh 16 120 61 200 | csvmidi - > _melody.midi
timidity -Ow _melody.midi > /dev/null
sox -D --norm=-5 _melody.wav _melody2.wav pad 0.161 3 \
    reverb 65 \
    fade t 0 0.5 0.5

sox -D -n -r 44100 -b 16 -c 2 _harm.wav \
    synth 10 sin %-20 sin %-16 sin %-13 \
    fade t 0.2 0.9 0.5 gain -20

sox -D _melody1.wav _melody2.wav _harm.wav -m _pre.wav
sox -D --norm=-0.1 _pre.wav main-menu.wav pad 0 2 reverb 65
rm -f _*.wav *.midi
