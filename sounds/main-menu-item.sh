#!/bin/bash -e
# Copyright 2024 Michael Pozhidaev <msp@luwrain.org>
# The LUWRAIN Project, GPL v.3
# Des major

. config.sh

INS=98
DUR=20

./melody.sh $INS 120 73 $DUR 77 $DUR 68 $DUR | csvmidi - > melody.midi && timidity -Ow melody.midi > /dev/null
mv melody.wav .melody-src.wav
sox -D .melody-src.wav -r $RATE -c 1 -b 16 .melody1.wav treble -5
sox -D .melody1.wav -c 2 .melody.wav pad 0 3

sox -D -n -r $RATE -b 16 -c 2 .harm.wav \
    synth 10 sin %-20 sin %-16 sin %-13 \
    fade t 0.2 2 1.8 gain -25

sox -D .melody.wav .harm.wav -m .pre.wav
sox -D --norm=-0.1 .pre.wav main-menu-item.wav reverb 75 fade t 0 2 2
rm -f *.midi .*.wav
