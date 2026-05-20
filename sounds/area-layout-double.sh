#!/bin/bash -e
# SPDX-License-Identifier: BUSL-1.1
# Copyright 2026 Michael Pozhidaev <msp@luwrain.org>
# Des major

INS1=108
INS2=72
NOTE1=49
NOTE2=61
VOLUME=100
DUR=90

./melody.sh $INS1 $VOLUME $NOTE1 $DUR 68 $DUR | csvmidi - > melody.midi && timidity -a -C 8 -s 256000   -Ow melody.midi > /dev/null && mv melody.wav .melody-src.wav
sox .melody-src.wav  -e float -c 1 .melody-pre.wav bass 5
sox --norm=-0.1 .melody-pre.wav -c 2 .melody.wav reverb 50  fade t 0 2.5 2.5

./melody.sh $INS2 120 $NOTE2 120 | csvmidi - > melody.midi && timidity -a -C 8 -s 256000 -Ow melody.midi > /dev/null && mv melody.wav .high-src.wav
sox .high-src.wav  -e float -c 1 .high-pre.wav
sox --norm=-5  .high-pre.wav -c 2 .high.wav reverb 70  fade t 0 1.5 1.5

sox -n -r 256000 -e float -c 2 .harm.wav \
    synth 10 sin %-20 sin %-16 sin %-13 gain -25  pad 0.10 \
    fade t 0.1 1.4 1.3 

sox .melody.wav .high.wav .harm.wav -m .pre.wav
sox --norm=-0.1 .pre.wav area-layout-double.wav  pad 0 1
rm -f .*.midi .*.wav
