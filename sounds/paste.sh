#!/bin/bash -e
# Copyright 2024 Michael Pozhidaev <msp@luwrain.org>
# The LUWRAIN Project, GPL v.3
# G major

sox -D -n -r 48000 -c 2 -b 32 01-1.wav \
    synth 5 sin D5 sin D6 sin fmod D5 fade l 0 1 1 gain -1 trim 0 0.1
sox -D -n -r 48000 -c 2 -b 32 01-2.wav \
    synth 5 sin D2 synth 5 sin fmod D1 fade l 0 1 1 gain -10 trim 0 0.1
sox -D 01-1.wav 01-2.wav -m 01.wav

sox -D -n -r 48000 -c 2 -b 32 02-1.wav \
    synth 5 sin G5 sin G6 sin fmod G5 fade l 0 1 1 gain -1 trim 0 1
sox -D -n -r 48000 -c 2 -b 32 02-2.wav \
    synth 5 pluck G4 sin fmod G5 gain -30 fade t 0 1 1 trim 0 1
sox -D 02-1.wav 02-2.wav -m 02.wav

sox -D 01.wav 02.wav 03.wav
sox -D 03.wav 04.wav pad 0 1 REVERB 65 100 100 100 10
sox --norm=-0.5 04.wav -c 2 -b 16 -r 44100 paste.wav
rm -f 0?.wav 0?-?.wav
