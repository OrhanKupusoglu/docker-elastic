#!/bin/bash

#set -ex

DIR_RUN="$(cd "$(dirname "$0")" && pwd)"
cd $DIR_RUN

#chown -R elasticsearch:elasticsearch $DIR_RUN

su elasticsearch << EOF
source ./common.sh

print_ver

run_elastic_kibana $DIR_RUN
EOF

printf "\n++ starting Fluentd\n\n"

/etc/init.d/td-agent restart
/etc/init.d/td-agent status

printf "\n++ started\n\n"

# ssh daemon
/usr/sbin/sshd -D
