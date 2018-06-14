#!/bin/bash

#set -ex

DIR_RUN="$(cd "$(dirname "$0")" && pwd)"
cd $DIR_RUN

if [[ ! -e /etc/filebeat/filebeat.yml.orig ]]
then
    mv /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.orig
    mv filebeat.yml /etc/filebeat/filebeat.yml
fi

chown -R elk:elk $DIR_RUN

su elk << EOF
source ./common.sh

print_ver "elk"

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

# Dashboard requires Kibana
cd $DIR_RUN
wait_here
print_title "starting $VER_LOGSTASH"
if [[ -e ${VER_LOGSTASH}.tar.gz ]]
then
    tar -xzf ${VER_LOGSTASH}.tar.gz
    rm -f ${VER_LOGSTASH}.tar.gz
    cp -a ${VER_LOGSTASH}/config/logstash.yml ${VER_LOGSTASH}/config/logstash.yml.orig
    mv logstash.yml ${VER_LOGSTASH}/config/.
    cp -a ${VER_LOGSTASH}/config/pipelines.yml ${VER_LOGSTASH}/config/pipelines.yml.orig
    mv pipelines.yml ${VER_LOGSTASH}/config/.
    mv logstash.conf ${VER_LOGSTASH}/config/.
fi
cd ${VER_LOGSTASH}/
./bin/logstash -f ./config/logstash.conf &
./bin/logstash-plugin list --verbose

wait_here
EOF

printf "\n-- started\n\n"

# ssh daemon
/usr/sbin/sshd -D
