#!/bin/bash -e
# Copyright 2024 Michael Pozhidaev <msp@luwrain.org>
# The LUWRAIN Project, GPL v.3


cat <<EOF
0, 0, Header, 1, 2, 480
1, 0, Start_track
1, 0, Title_t, "Sound icon"
1, 0, Text_t, "LUWRAIN sound icon"
1, 0, Copyright_t, "The LUWRAIN Project"
1, 0, Time_signature, 4, 2, 24, 8
1, 0, Tempo, 500000
1, 0, End_track
2, 0, Start_track
2, 0, Instrument_name_t, "MIDI instrument $1"
2, 0, Program_c, 1, $1
EOF

VOL="$2"
shift
shift
p=0
while [ -n "$1" ]; do
n="$1"
d="$2"
((pp=p+d))
cat <<EOF
2, $p, Note_on_c, 1, $n, $VOL
2, $pp, Note_off_c, 1, $n, 0
EOF
p="$pp"
shift
shift
done

cat <<EOF
2, $p, End_track
0, 0, End_of_file
EOF
