#!/bin/bash -e
# Copyright 2024 Michael Pozhidaev <msp@luwrain.org>
# The LUWRAIN Project, GPL v.3
# FIXME: must be E major
# Des major

INS=13

./melody.sh $INS 120 68 150 73 160 77 170 75 180 80 300 | csvmidi - > melody.midi
timidity -Ow melody.midi > /dev/null

sox -D -n -r 44100 -b 16 -c 2 harm.wav \
    synth 10 sin %-20 sin %-16 sin %-7 \
    fade t 0.4 2 1.5 gain -30

sox -D melody.wav harm.wav -m pre.wav

sox -D --norm=-0.1 pre.wav done.wav pad 0 0.5 reverb 65
rm -f *.midi melody.wav harm.wav pre.wav
