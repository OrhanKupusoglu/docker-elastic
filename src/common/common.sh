#!/bin/bash

#set -ex

SLEEP_DURATION=3

JAVA_VERSION=($(java -version 2>&1))
NODE_VERSION=$(node --version)
NPM_VERSION=$(npm --version)
RUBY_VERSION=$(ruby --version)

SEP_LEN=80
SEP_CHAR="+"

# before each session call as root
configure() {
    # Important System Configuration
    # https://www.elastic.co/guide/en/elasticsearch/reference/current/system-config.html

    # man fstab
    # man limits.conf
    # ulimit -a
    # man sysctl.conf
    # sysctl -a

    ### Disable swapping:
    swapoff -a
    ### File Descriptors:
    ulimit -n 65536
    ### Virtual memory:
    sysctl -w vm.max_map_count=262144
    # must be set on the host OS - otherwise:
    #sysctl: setting key "vm.max_map_count": Read-only file system
    ### Number of threads:
    ulimit -u 4096

    # Before Installing Fluentd
    # https://docs.fluentd.org/v1.0/articles/before-install
}

wait_here() {
    sleep $SLEEP_DURATION
}

print_sep() {
    printf "%0.s${SEP_CHAR}" $(seq 1 $SEP_LEN) ; echo
}

print_title() {
    print_sep
    echo "$1"
    print_sep
}

print_ver() {
    echo
    print_sep
    echo "Java version:  ${JAVA_VERSION[2]//\"/}"
    echo "Java home:     $JAVA_HOME"
    echo "Node version:  $NODE_VERSION"
    echo "NPM version:   $NPM_VERSION"
    echo "Ruby version:  $RUBY_VERSION"
    echo "ElasticSearch: ${VER_ELASTICSEARCH}"

    if [[ "$1" == "elk" ]]
    then
        echo "Logstash:      ${VER_LOGSTASH}"
        echo "Filebeat:      ${VER_FILEBEAT}"
    fi

    echo "Kibana:        ${VER_KIBANA}"
    print_sep
    echo
}

run_elastic_kibana() {
    DIR_INSTALL="$1"

    cd $DIR_INSTALL
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
    wait_here

    cd $DIR_INSTALL
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
    wait_here
}

run_logstash() {
    DIR_INSTALL="$1"

    cd $DIR_INSTALL
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
}
