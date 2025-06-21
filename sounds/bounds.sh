#!/bin/bash -e
# Copyright 2024 Michael Pozhidaev <msp@luwrain.org>
# The LUWRAIN Project, GPL v.3
# As major

NOTE1=56
NOTE2=60
NOTE3=65

BASS=5
VOL=80
INST=12
REVERB=65

cat <<EOF | csvmidi > bounds.midi
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
2, 0, Program_c, 1, $INST
2, 0, Note_on_c, 1, $NOTE1, $VOL
2, 300, Note_off_c, 1, $NOTE1, 0
2, 300, End_track
3, 0, Start_track
3, 0, Instrument_name_t, "MIDI instrument"
3, 0, Program_c, 1, $INST
3, 0, Note_on_c, 1, $NOTE2, $VOL
3, 300, Note_off_c, 1, $NOTE2, 0
3, 300, End_track
4, 0, Start_track
4, 0, Instrument_name_t, "MIDI instrument"
4, 0, Program_c, 1, $INST
4, 0, Note_on_c, 1, $NOTE3, $VOL
4, 300, Note_off_c, 1, $NOTE3, 0
4, 300, End_track
0, 0, End_of_file
EOF

timidity -Ow bounds.midi > /dev/null
mv bounds.wav .bounds.wav
sox -D --norm=-0.1 .bounds.wav -r 48000 -c 1 bounds.wav bass $BASS
sox -D .bounds.wav -c 2 bounds.wav reverb $REVERB fade t 0 2 2
rm -f *.midi .*.wav

