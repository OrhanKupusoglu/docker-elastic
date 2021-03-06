#!/bin/bash

DIR_RUN="$(cd "$(dirname "$0")" && pwd)"
cd $DIR_RUN

# helper functions
help() {
    echo "USAGE: enter #1: a stack, and #2: optionally detached mode"
    echo "    elk | efk   -- #1: stack is ELK = ElasticSearch + Logstash + Kibana"
    echo "                -- #1: stack is EFK = ElasticSearch + Fluentd + Kibana"
    echo "    d | det     -- #2: optional - detached mode: run containers in the background"
    echo "or:"
    echo "    down        -- stop and remove containers"
    echo "    help        -- print this help"
    echo "EXAMPLE:"
    echo "    $0 elk det"
    echo "    $0 down"
}

find_image() {
    #echo "${FUNCNAME[0]}(): called with params - ${1} ${2}"
    if [ -z "${1}" ]; then
        echo "${FUNCNAME[0]}(): EMPTY REPO"
    elif [ -z "${2}" ]; then
        echo "${FUNCNAME[0]}(): EMPTY TAG"
    else
        image_tag=$(docker images --format "{{.Repository}}:{{.Tag}}" | sort -k1 | grep "$1:$2")
        found=$?
        echo $found
    fi
}

# args
DOWN_STACK=$1
DETACHED=$2

# if not 'down', 'stack' must be either 'elk' or 'efk'
case "$DOWN_STACK" in
    "help")
        help ; exit 0
        ;;

    "down")
        DETACHED=""
        ;;

    "elk")
        ;&  # fall-through
    "efk")
        echo "STACK   : $DOWN_STACK"
        ;;

    *)
        echo "ERROR - unknown stack: '$DOWN_STACK'" ; help ; exit 1
        ;;
esac

# if present, 'detached' must be either -d" | "d" | "--det" | "det"
if [[ "$DOWN_STACK" == "down" ]]
then
    echo "++ stopping and removing containers"
else
    case "$DETACHED" in
        "")
            echo "DETACHED: false"
            ;;

        "-d"|"d"|"--det"|"det")
            echo "DETACHED: true"
            DETACHED="det"
            ;;

        *)
            echo "ERROR - unknown mode: '$DETACHED'" ; help ; exit 2
            ;;
    esac
fi

printf "\n++ IMAGE LIST:\n"
docker image ls
printf "\n++ CONTAINER LIST:\n"
docker container ls
echo

# docker-compose build base
# docker-compose build stack
# docker-compose build elk
# docker-compose build efk

cd src/

if [[ "$DOWN_STACK" != "down" ]]
then
    # read tag
    source ".env"

    IMAGE_BASE="elastic/base"
    FOUND_BASE=$(find_image "$IMAGE_BASE" "$X_TAG_BASE")

    if [[ $FOUND_BASE -eq 0 ]]
    then
        printf "\n++ 'base' image is ready      : $IMAGE_BASE:$X_TAG_BASE\n\n"
    else
        printf "\n++ 'base' image is missing    : $IMAGE_BASE:$X_TAG_BASE\n\n"
        docker-compose build base
    fi

    IMAGE_ELASTIC="elastic/stack"
    FOUND_ELASTIC=$(find_image "$IMAGE_ELASTIC" "$X_TAG_STACK")

    if [[ $FOUND_ELASTIC -eq 0 ]]
    then
        printf "\n++ 'stack' image is ready     : $IMAGE_ELASTIC:$X_TAG_STACK\n\n"
    else
        printf "\n++ 'stack' image is missing   : $IMAGE_ELASTIC:$X_TAG_STACK\n\n"
        docker-compose build stack
    fi

    if [[ "$DOWN_STACK" == "efk" ]]
    then
        TAG_STACK="$X_TAG_EFK"
    else
        TAG_STACK="$X_TAG_ELK"
    fi

    IMAGE_STACK="elastic/$DOWN_STACK"
    FOUND_STACK=$(find_image "$IMAGE_STACK" "$TAG_STACK")

    if [[ $FOUND_STACK -eq 0 ]]
    then
        printf "\n++ '${DOWN_STACK}' image is ready       : $IMAGE_STACK:$TAG_STACK\n\n"
    else
        printf "\n++ '${DOWN_STACK}' image is missing     : $IMAGE_STACK:$TAG_STACK\n\n"
        docker-compose build "$DOWN_STACK"
    fi
fi

case "$DOWN_STACK" in
    "down")
        docker-compose down
        printf "\n++ CONTAINER LIST ALL:\n"
        docker ps -a
        ;;

    *)
        if [[ "$DETACHED" == "det" ]]
        then
            docker-compose up -d "$DOWN_STACK"
        else
            docker-compose up "$DOWN_STACK"
        fi
        ;;
esac


if [[ "$DETACHED" == "det" ]]
then
    printf "\n++ CONTAINER LIST:\n"
    docker container ls
fi
