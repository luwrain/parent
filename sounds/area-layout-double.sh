#!/bin/bash -e
# Copyright 2024 Michael Pozhidaev <msp@luwrain.org>
# The LUWRAIN Project, GPL v.3
# Des major

INS1=108
INS2=82
NOTE1=61
NOTE2=61
VOLUME=100
DUR=90

./melody.sh $INS1 $VOLUME $NOTE1 $DUR 68 $DUR | csvmidi - > melody.midi && timidity -Ow melody.midi > /dev/null && mv melody.wav .melody-src.wav
sox -D .melody-src.wav  -r 256000 -c 1 -b 32 .melody-pre.wav bass 5
sox -D --norm=-0.1 .melody-pre.wav -c 2 .melody.wav reverb 50  fade t 0 2.5 2.5

./melody.sh $INS2 120 $NOTE2 120 | csvmidi - > melody.midi && timidity -Ow melody.midi > /dev/null && mv melody.wav .high-src.wav
sox -D .high-src.wav  -r 256000 -b 32 -c 1 -b 16 .high-pre.wav
sox -D --norm=-5  .high-pre.wav -c 2 .high.wav reverb 70  fade t 0 1.5 1.5

sox -D -n -r 256000 -b 32 -c 2 .harm.wav \
    synth 10 sin %-20 sin %-17 sin %-13 gain -25  pad 0.10 \
    fade t 0.1 1.4 1.3 

sox -D .melody.wav .high.wav .harm.wav -m .pre.wav
sox -D .pre.wav area-layout-double.wav  pad 0 1
rm -f .*.midi .*.wav
