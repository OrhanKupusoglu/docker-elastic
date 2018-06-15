#!/bin/bash

#set -ex

DIR_RUN="$(cd "$(dirname "$0")" && pwd)"
cd $DIR_RUN

# Important System Configuration
# https://www.elastic.co/guide/en/elasticsearch/reference/current/system-config.html

# man fstab
# man limits.conf
# ulimit -a
# man sysctl.conf
# sysctl -a

### Disable swapping:
#swapoff -a
### File Descriptors:
#ulimit -n 65536
### Virtual memory:
#sysctl -w vm.max_map_count=262144
### Number of threads:
#ulimit -u 4096

# Before Installing Fluentd
# https://docs.fluentd.org/v1.0/articles/before-install

chown -R elasticsearch:elasticsearch $DIR_RUN

su elasticsearch << EOF
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
