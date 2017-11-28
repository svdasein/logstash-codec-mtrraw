#!/usr/bin/env bash

ORIGIN_NAME=$1
TARGET_NAME=$2
PING_COUNT=$3
TARGET_IP=$4
LOGSTASH_IP=$5
LOGSTASH_PORT=$6

if [ -z "$1" ] ; then
	echo "USAGE:"
	echo "$0 <ORIGIN_NAME> <TARGET_NAME> <PING_COUNT> <TARGET_IP> <LOGSTASH_IP> <LOGSTASH_PORT>"
	exit
fi

while true ; do echo -n '.'; (echo "s 0 $ORIGIN_NAME $TARGET_NAME $PING_COUNT";mtr --raw --no-dns  -c $PING_COUNT $TARGET_IP ) | awk '{printf $0";"}'  | nc $LOGSTASH_IP $LOGSTASH_PORT ; done

