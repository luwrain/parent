#!/bin/bash -e
# Copyright 2024 Michael Pozhidaev <msp@luwrain.org>
# The LUWRAIN Project, GPL v.3
# As major

INS=96
DUR=20

. config.sh

./melody.sh $INS 120 75 $DUR 80 $DUR 84 $DUR | csvmidi - > melody.midi && timidity -Ow melody.midi > /dev/null
mv melody.wav .melody-src.wav
sox -D .melody-src.wav -r $RATE -c 1 -b 16 .melody1.wav treble -5
sox -D .melody1.wav -c 2 .melody.wav pad 0 1

sox -D -n -r $RATE -b 16 -c 2 .harm.wav \
    synth 10 sin %-13 sin %-9 sin %-6 \
    fade t 0.2 1.3 1 gain -25

sox -D .melody.wav .harm.wav -m .pre.wav
sox -D --norm=-0.1 .pre.wav marked-list-item.wav reverb 65 fade t 0 2 2
rm -f *.midi .*.wav
