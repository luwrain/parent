# Copyright 2022 Michael Pozhidaev <msp@luwrain.org>

export PATH=~/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export LANG=ru_RU.UTF-8
export VOICEMAN_EMACSPEAK_RATE_FRACTION=2
#export PULSE_SERVER=/run/pulse/native
#export VOICEMAN_LIBAO_DRIVER=alsa

#pulseaudio -D ||:
pactl set-sink-volume 0 80%

if ! [ -e /tmp/voiceman.socket ]; then
    /usr/bin/voicemand -d
fi

#setxkbmap -layout "us,ru"
#setxkbmap -option "grp:caps_toggle,grp_led:scroll"

exec dwm-luwrain
