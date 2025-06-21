#!/bin/bash -e
# Copyright 2024 Michael Pozhidaev <msp@luwrain.org>
# The LUWRAIN Project, GPL v.3
# Ges major

DRUM_VOL=-2
DRUM_DELAY=0.3
HARM_DELAY=0.42
HARM_VOL=-10
BASS=7

NOTE=30

INST=11
DUR=300

NOTE1_VOL=-15
NOTE2_VOL=-18

cat <<EOF | csvmidi > drum.midi
0, 0, Header, 1, 4, 480
1, 0, Start_track
1, 0, Title_t, "Sound icon"
1, 0, Text_t, "LUWRAIN sound icon"
1, 0, Copyright_t, "The LUWRAIN Project"
1, 0, Time_signature, 4, 2, 24, 8
1, 0, Tempo, 500000
1, 0, End_track
2, 0, Start_track
2, 0, Instrument_name_t, "MIDI instrument"
2, 0, Program_c, 1, 118
2, 0, Note_on_c, 1, $NOTE, 120
2, 300, Note_off_c, 1, $NOTE, 0
2, 300, End_track
3, 0, Start_track
3, 0, Instrument_name_t, "MIDI instrument"
3, 0, Program_c, 1, 117
3, 0, Note_on_c, 1, $NOTE, 60
3, 300, Note_off_c, 1, $NOTE, 0
3, 300, End_track
4, 0, Start_track
4, 0, Instrument_name_t, "MIDI instrument"
4, 0, Program_c, 1, 55
4, 0, Note_on_c, 1, 66, 20
4, 300, Note_off_c, 1, 66, 0
4, 300, End_track
0, 0, End_of_file
EOF

timidity -Ow drum.midi > /dev/null
mv drum.wav _drum1.wav
sox --norm=$DRUM_VOL _drum1.wav -r 48000 -c 1 _drum2.wav pad $DRUM_DELAY 5 bass $BASS
sox _drum2.wav -c 2 _drum.wav reverb 80 50 100 100 50 5

sox -D -n -r 48000 -c 2 -b 16 _harm1.wav \
    synth 10 sin %1 sin %4 sin %9 \
    fade t 0.4 2 1.5 pad $HARM_DELAY 3 \
    gain $HARM_VOL
sox -D _harm1.wav _harm.wav reverb 100 100 100 100 20 5

./melody.sh $INST 120 90 $DUR | csvmidi - > _note1-1.midi
timidity -Ow _note1-1.midi > /dev/null
sox -D --norm=$NOTE1_VOL _note1-1.wav -r 48000 _note1.wav \
    gain -10 \
    pad 0.95 3 \
    reverb 100 50 100 100 0 10

./melody.sh $INST 120 97 $DUR | csvmidi - > _note2-1.midi
timidity -Ow _note2-1.midi > /dev/null
sox -D --norm=$NOTE2_VOL _note2-1.wav -r 48000 _note2.wav \
    pad 1.7 3 \
    reverb 100  50 100 100 0 10

sox -D -n -r 48000 -c 1 -b 16 _noise1.wav \
    synth 1 br synth 0.6 sin fmod %-39-%-15 bass 30 \
    fade t 0.32 0.52 0.2
sox -D _noise1.wav -c 2 _noise.wav

LONG=110
./melody.sh 9 120 \
	    75 $LONG 90 $LONG 101 $LONG 119 $LONG 85 $LONG 98 $LONG 93 $LONG 80 $LONG 101 $LONG 95 $LONG 120 $LONG 104 $LONG 87 $LONG 91 $LONG 89 $LONG | csvmidi - > _high1.midi
timidity -Ow _high1.midi > /dev/null
sox -D --norm=-30 _high1.wav -r 48000 _high.wav pad 0.5 \
    REVERB 100 100 100 100 50 10 \
fade l 0 7 7

sox -D _drum.wav _harm.wav _noise.wav _high.wav _note1.wav _note2.wav -m _startup.wav
sox -D --norm=-0.1 _startup.wav -r 44100 startup.wav fade q 0 4.3 4
rm -f *.midi _*.wav
