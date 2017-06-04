#!/usr/bin/env bash

set -e

function stop {
	kill $(ps -C ts3server -o pid= | awk '{ print $1; }')
	exit
}

trap stop INT
trap stop TERM

# create directory for teamspeak files
test -d /data/files || mkdir -p /data/files && chown teamspeak:teamspeak /data/files

# create directory for teamspeak logs
test -d /data/logs || mkdir -p /data/logs && chown teamspeak:teamspeak /data/logs

# create symlinks for all files and directories in the persistent data directory
cd ${TS_DIRECTORY}
for i in $(ls /data)
do
	ln -sf /data/${i}
done

# remove broken symlinks
find -L ${TS_DIRECTORY} -type l -delete

# create symlinks for static files
STATIC_FILES=(
	query_ip_whitelist.txt
	query_ip_blacklist.txt
	ts3server.ini
	ts3server.sqlitedb
	ts3server.sqlitedb-shm
	ts3server.sqlitedb-wal
)
for i in ${STATIC_FILES[@]}
do
	ln -sf /data/${i}
done

export LD_LIBRARY_PATH=".:$LD_LIBRARY_PATH"
exec /tini -- ./ts3server createinifile = 1 $@

RUN sed -i "s|default_voice_port=1337|default_voice_port=10000 |g" /opt/teamspeak/ts3server.ini
  sed -i "s|query_port=10011|query_port=10001 |g" /opt/teamspeak/ts3server.ini
  sed -i "s|filetransfer_port=30033|filetransfer_port=10002 |g" /opt/teamspeak/ts3server.ini
