#!/bin/bash -e
# Copyright 2024 Michael Pozhidaev <msp@luwrain.org>
# The LUWRAIN Project, GPL v.3
# E major

INS=13

./melody.sh $INS 120 \
	    76 50 80 50 71 300 | csvmidi - > melody.midi
timidity -Ow melody.midi > /dev/null
sox melody.wav -r 256000 .melody.wav && rm -f melody.wav

sox -D -n -r 256000 -b 16 -c 2 .harm.wav \
    synth 10 sin %-17 sin %-13 sin %-10 \
    fade t 0.4 2 1.5 gain -30

sox -D .melody.wav .harm.wav -m .pre.wav
sox -D .pre.wav .reverb.wav pad 0 0.5 reverb 65
sox -D --norm=-0.1 .reverb.wav message.wav
rm -f *.midi .*.wav
