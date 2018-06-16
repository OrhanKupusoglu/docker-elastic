#!/bin/bash

#set -ex

DIR_RUN="$(cd "$(dirname "$0")" && pwd)"
cd $DIR_RUN

if [[ ! -e /etc/filebeat/filebeat.yml.orig ]]
then
    mv /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.orig
    mv filebeat.yml /etc/filebeat/filebeat.yml
fi

#chown -R elasticsearch:elasticsearch $DIR_RUN

su elasticsearch << EOF
source ./common.sh

print_ver "elk"

run_elastic_kibana $DIR_RUN

run_logstash $DIR_RUN
EOF

printf "\n++ started\n\n"

# ssh daemon
/usr/sbin/sshd -D
