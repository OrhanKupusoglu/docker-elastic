#!/bin/bash

#set -ex

DIR_RUN="$(cd "$(dirname "$0")" && pwd)"
cd $DIR_RUN

chown -R efk:efk $DIR_RUN

su efk << EOF
source ./common.sh

print_ver

cd $DIR_RUN
print_title "starting $VER_ELASTICSEARCH"
if [[ -e ${VER_ELASTICSEARCH}.tar.gz ]]
then
    tar -xzf ${VER_ELASTICSEARCH}.tar.gz
    rm -f ${VER_ELASTICSEARCH}.tar.gz
    cp -a ${VER_ELASTICSEARCH}/config/elasticsearch.yml ${VER_ELASTICSEARCH}/config/elasticsearch.yml.orig
    mv elasticsearch.yml ${VER_ELASTICSEARCH}/config/.
fi
cd ${VER_ELASTICSEARCH}/
./bin/elasticsearch &

cd $DIR_RUN
wait_here
print_title "starting $VER_KIBANA"
if [[ -e ${VER_KIBANA}.tar.gz ]]
then
    tar -xzf ${VER_KIBANA}.tar.gz
    rm -f ${VER_KIBANA}.tar.gz
    cp -a ${VER_KIBANA}/config/kibana.yml ${VER_KIBANA}/config/kibana.yml.orig
    mv kibana.yml ${VER_KIBANA}/config/.
fi
cd ${VER_KIBANA}/
./bin/kibana &

sleep $SLEEP_DURATION
EOF

printf "\n-- starting Fluentd\n\n"

/etc/init.d/td-agent restart
/etc/init.d/td-agent status

printf "\n-- started\n\n"

# ssh daemon
/usr/sbin/sshd -D
