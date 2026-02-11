#!/bin/bash -e
# SPDX-License-Identifier: BUSL-1.1
# Copyright 2026 Michael Pozhidaev <msp@luwrain.org>
# A major

sox -D -n -b 32 -c 2 -r 256000 01.wav \
    synth 1 pl %-3 sin %-15 sin %-12 sin %-8 sin fmod %-1-%-25  gain -3 \
    fade t 0 0.2 0.1 treble -10 pad 0 2
sox -D 01.wav 02.wav reverb 85 100 35 50 50
sox -D --norm=-0.5 02.wav inaccessible.wav
rm -f 0?.wav

