#!/bin/bash -e
# Copyright 2024 Michael Pozhidaev <msp@luwrain.org>
# The LUWRAIN Project, GPL v.3
# Des major

NOTE1=73
NOTE2=61
INS1=102
INS2=81
VOLUME=100
DUR=50

./melody.sh $INS1 $VOLUME $NOTE1 $DUR | csvmidi - > melody.midi && timidity -Ow melody.midi > /dev/null && mv melody.wav .melody-src.wav
sox .melody-src.wav  -r 256000 -c 1 -b 16 .melody-pre.wav bass 5
sox -D --norm=-1 .melody-pre.wav -c 2 .melody.wav reverb 65  fade t 0 1.5 1.5

./melody.sh $INS2 80 $NOTE2 50 | csvmidi - > melody.midi && timidity -Ow melody.midi > /dev/null && mv melody.wav .high-src.wav
sox .high-src.wav  -r 256000 -c 1 -b 16 .high-pre.wav
sox -D --norm=-5  .high-pre.wav -c 2 .high.wav reverb 70  fade t 0 1.5 1.5

sox -D -n -r 256000 -b 16 -c 2 .harm.wav \
    synth 10 sin %-20 sin %-17 sin %-13 gain -25  pad 0.10 \
    fade t 0.1 1.4 1.3 

sox -D .melody.wav .high.wav  .harm.wav -m .pre.wav
sox -D --norm=-1 .pre.wav area-layout.wav
rm -f .*.midi .*.wav
