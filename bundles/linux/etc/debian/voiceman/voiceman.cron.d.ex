#
# Regular cron jobs for the voiceman package
#
0 4	* * *	root	[ -x /usr/bin/voiceman_maintenance ] && /usr/bin/voiceman_maintenance
