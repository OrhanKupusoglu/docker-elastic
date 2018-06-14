#!/bin/bash

#set -ex

SLEEP_DURATION=3

JAVA_VERSION=($(java -version 2>&1))
NODE_VERSION=$(node --version)
NPM_VERSION=$(npm --version)
RUBY_VERSION=$(ruby --version)

SEP_LEN=80
SEP_CHAR="-"

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
