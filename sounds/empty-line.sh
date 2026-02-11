#!/bin/bash -e
# SPDX-License-Identifier: BUSL-1.1
# Copyright 2026 Michael Pozhidaev <msp@luwrain.org>
# As major

#INS=53
INS=58
# es'
NOTE=63
DUR=75

./melody.sh $INS 120 $NOTE $DUR | csvmidi - > melody.midi
timidity -Ow melody.midi > /dev/null
mv melody.wav .melody-src.wav
sox -D .melody-src.wav  -r 48000 -c 1 -b 16 .melody.wav bass 5

sox -D --norm=-0.1 .melody.wav -c 2 empty-line.wav reverb 65 fade t 0 1 1
rm -f .*.midi .*.wav
