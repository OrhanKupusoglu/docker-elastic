# ElasticSearch Stacks

ElasticSearch is based on [Apache Lucene](https://lucene.apache.org/):

> Elasticsearch is a distributed, RESTful search and analytics engine capable of solving a growing number of use cases. As the heart of the Elastic Stack, it centrally stores your data so you can discover the expected and uncover the unexpected.

ElasticSearch  is generally bundled with a data processing pipeline and a Web UI. These three products make a **stack**. The *de facto* standard is Elastic's own **ELK stack**, consisting of open source [ElasticSearch](https://www.elastic.co/products/elasticsearch), [Logstash](https://www.elastic.co/products/logstash) and [Kibana](https://www.elastic.co/products/kibana). Since the introduction of [Beats](https://www.elastic.co/products/beats) the **ELK stack** has been renamed as the **Elastic Stack**. The current Docker scripts install the [Filebeats](https://www.elastic.co/products/beats/filebeat) also.

In the so-called **EFK stack** [Fluentd](https://www.fluentd.org/) replaces ElasticSearch's own **Logstash** in the well-known **ELK stack**:

>Fluentd is an open source data collector for unified logging layer.

In each [efk](./src/efk) and [elk](./src/elk) directories you can find all configuration file's originals, with **.orig** extension, and the modified versions, so that easy differentiation is possible.

&nbsp;

## Docker

Docker is a [containerization](https://docs.docker.com/get-started/) tool. The free [Community Edition](https://www.docker.com/community-edition) is easy to [install](https://docs.docker.com/install/). The optional [post-installation steps](https://docs.docker.com/install/linux/linux-postinstall/) enable running Docker commands without root privileges.

```
$ sudo groupadd docker
$ sudo usermod -aG docker $USER
```
Logout-login is required.

Refer to the [Docker Get Started](https://docs.docker.com/get-started/) page for conceptual background.

### Docker Commands

Docker images can be listed and removed with **docker image** family commands.
For more information check its manual pages or its [Docker Docs](https://docs.docker.com/engine/reference/commandline/image/) page.

```
$ man docker-image
$ man docker-image-ls
$ man docker-image-rm

$ docker image ls
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
elastic/elk         0.0.3               db7d5112c74c        9 minutes ago       2.4GB
elastic/efk         0.0.3               12c207e79905        15 minutes ago      2.22GB
elastic/stack       0.0.3               cfee2b6d2e57        16 minutes ago      1.74GB
elastic/base        0.0.3               18f4d876e57b        7 hours ago         1.14GB
ubuntu              16.04               5e8b97a2a082        11 days ago         114MB
```

Docker containers can be listed and removed with **docker container** family commands.
For more information check its manual pages or its [Docker Docs](https://docs.docker.com/engine/reference/commandline/container/) page.

```
$ man docker-container
$ man docker-container-ls
$ man docker-container-rm

$ docker container ls
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                                                                                                      NAMES
fcc7931971f2        elastic/elk:0.0.3   "sh -c /${DIR_STACK}…"   27 seconds ago      Up 26 seconds       0.0.0.0:5601->5601/tcp, 0.0.0.0:8888->8888/tcp, 0.0.0.0:12345->12345/tcp, 0.0.0.0:12345->12345/udp, 0.0.0.0:2222->22/tcp   elk
```
&nbsp;

## Docker Compose

[Docker Compose](https://docs.docker.com/compose/install/) uses [YAML](https://en.wikipedia.org/wiki/YAML) to define and run containers.

Without Docker Compose lengthy **docker build** and **docker run** commands must be issued. Another improvement is using arguments in the Dockerfile scripts. The important [FROM](https://docs.docker.com/engine/reference/builder/#from) instruction can contain references to arguments. See the scripts in the [src/](./src) directory.

The [.env](./src/.venv) file contains variables, all starting with **X_**, which are then used in the [docker-compose.yml](./src/docker-compose.yml) script.

```
$ docker-compose help
$ docker-compose images
$ docker-compose ps
```

### Build Script

The application can be built and run with a shell script, [docker.sh](./src/docker.sh).

```
$ cd src
$ ./docker.sh help
USAGE: enter #1: a stack, and #2: optionally detached mode
    elk | efk   -- #1: stack is ELK = ElasticSearch + Logstash + Kibana
                -- #1: stack is EFK = ElasticSearch + Fluentd + Kibana
    d | det     -- #2: optional - detached mode: run containers in the background
or:
    down        -- stop and remove containers
    help        -- print this help
EXAMPLE:
    ./docker.sh elk det
    ./docker.sh down

$ ./docker.sh elk
. . .
++ 'base' image is ready      : elastic/base:0.0.3

++ 'stack' image is ready     : elastic/stack:0.0.3

++ 'elk' image is missing     : elastic/elk:0.0.3

Building elk
Step 1/21 : ARG arg_tag_stack
Step 2/21 : FROM "elastic/stack:${arg_tag_stack}"
 ---> cfee2b6d2e57
. . .
elk      | ++ started
elk      | 
elk      | Sending Logstash's logs to /ELASTIC/logstash-6.3.0/logs which is now configured via log4j2.properties
```

The running containers can be stopped with CTRL+C:

```
^CGracefully stopping... (press Ctrl+C again to force)
Stopping elk ... 
Killing elk ... done
```

The **ubuntu:16:04** is the where **elastic/base** is derived from, and in turn the **elastic/efk**  and **elastic/elk** image is derived from this base image.

The containers can be stopped and/or removed with the script's **down** option:

```
$ ./docker.sh down
++ stopping and removing containers

++ IMAGE LIST:
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
elastic/elk         0.0.3               db7d5112c74c        17 minutes ago      2.4GB
elastic/efk         0.0.3               12c207e79905        22 minutes ago      2.22GB
elastic/stack       0.0.3               cfee2b6d2e57        23 minutes ago      1.74GB
elastic/base        0.0.3               18f4d876e57b        7 hours ago         1.14GB
ubuntu              16.04               5e8b97a2a082        11 days ago         114MB

++ CONTAINER LIST:
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES

Removing elk ... done
Removing network src_default

++ CONTAINER LIST ALL:
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
```

### Docker Compose Detached Mode

Docker Compose has a **detached mode**:

>  -d Detached mode: Run containers in the background
>

This is useful to run containers as services.

```
$ ./docker.sh elk det
STACK   : elk
DETACHED: true

++ IMAGE LIST:
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
elastic/elk         0.0.3               db7d5112c74c        17 minutes ago      2.4GB
elastic/efk         0.0.3               12c207e79905        23 minutes ago      2.22GB
elastic/stack       0.0.3               cfee2b6d2e57        24 minutes ago      1.74GB
elastic/base        0.0.3               18f4d876e57b        7 hours ago         1.14GB
ubuntu              16.04               5e8b97a2a082        11 days ago         114MB

++ CONTAINER LIST:
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES


++ 'base' image is ready      : elastic/base:0.0.3

++ 'stack' image is ready     : elastic/stack:0.0.3

++ 'elk' image is ready       : elastic/elk:0.0.3

Creating network "src_default" with the default driver
Creating elk ... done

++ CONTAINER LIST:
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                  PORTS                                                                                                                      NAMES
133d65d47802        elastic/elk:0.0.3   "sh -c /${DIR_STACK}…"   1 second ago        Up Less than a second   0.0.0.0:5601->5601/tcp, 0.0.0.0:8888->8888/tcp, 0.0.0.0:12345->12345/tcp, 0.0.0.0:12345->12345/udp, 0.0.0.0:2222->22/tcp   elk

$ ./docker.sh down
```

&nbsp;

## Testing

### ELK

The index **logstash-2018.06.14** can be discovered on [Kibana](http://localhost:5601) with field **@timestamp** as *Time Filter field name*.

```
$ curl -v -d '{"motor-glider": "Stemme S12", "airlifter": "Airbus C295"}'H "Content-Type: application/json" http://localhost:8888
* Rebuilt URL to: http://localhost:8888/
*   Trying 127.0.0.1...
* Connected to localhost (127.0.0.1) port 8888 (#0)
> POST / HTTP/1.1
> Host: localhost:8888
> User-Agent: curl/7.47.0
> Accept: */*
> Content-Type: application/json
> Content-Length: 58
> 
* upload completely sent off: 58 out of 58 bytes
< HTTP/1.1 200 OK
< Content-Type: text/plain
< Content-Length: 2
< 
* Connection #0 to host localhost left intact
ok
```
### EFK

The EFK stack can be tested with an HTTP request using the ubiquitous [curl](https://curl.haxx.se/). Here **input-logs** refers to the  match **input-logs** as set by the [td-agent.conf](./src/efk/td-agent.conf). There is a slight delay between log received and displayed.

The Elastic server is configured with time zone **Europe/Berlin**, which is currently *Time Zone CEST (Central European Summer Time) / UTC/GMT +2 hours*. Local time here is +3 hours, so this difference should be considered for.  Another option is to get the time stamp on a +0 time zone like **Atlantic/Reykjavik**.

On Kibana you may need to check  *Today* or *This Week*.

The index **fluentd** can be discovered on [Kibana](http://localhost:5601) with field **@timestamp** as *Time Filter field name*.

```
$ man curl

$ curl --help

$ TIMESTAMP=$(env TZ=Atlantic/Reykjavik date +"%Y-%m-%dT%H:%M:%S.%3NZ")
$ TIMESTAMP=$(date -d '3 hour ago' +"%Y-%m-%dT%H:%M:%S.%3NZ")
$ echo $TIMESTAMP 
2018-06-14T19:54:19.095Z

$ curl -v -d "json={\"@timestamp\":\"${TIMESTAMP}\",\"airliner\":\"Airbus A350\",\"helicopter\":\"Eurocopter EC175\"}" http://localhost:8888/input-logs
*   Trying 127.0.0.1...
* Connected to localhost (127.0.0.1) port 8888 (#0)
> POST /input-logs HTTP/1.1
> Host: localhost:8888
> User-Agent: curl/7.47.0
> Accept: */*
> Content-Length: 103
> Content-Type: application/x-www-form-urlencoded
>
* upload completely sent off: 103 out of 103 bytes
< HTTP/1.1 200 OK
< Content-Type: text/plain
< Connection: Keep-Alive
< Content-Length: 0
<
* Connection #0 to host localhost left intact
```

&nbsp;

## Important System Configuration

Kibana may give a warning:

```
elk      | [2018-06-16T23:51:26,504][WARN ][o.e.b.BootstrapChecks    ] [Jvu1Yt4] max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
```
This warning can only be suppressed by increasing **vm.max_map_count** to **262144** on the **host OS**, not on the container.

Either for the current session as root:
```
# sysctl -w vm.max_map_count=262144
```
Or permanently by **host OS's /etc/sysctl.conf** and restarting:
```
# echo "vm.max_map_count = 262144" >> /etc/sysctl.conf
```
See [Virtual Memory](https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html).

**Fluentd** for high load environments requires optimization of network kernel parameters. See [Before Installing Fluentd](https://docs.fluentd.org/v1.0/articles/before-install). Since these parameters are issued with **/etc/sysctl.conf**, this step requires modification on **host OS's /etc/sysctl.conf** and restart.

&nbsp;

## SSH

The container can be accessed via SSH on port **2222** by the **root** user with password **1234**.

```
$ ssh root@localhost -p 2222
The authenticity of host '[localhost]:2222 ([127.0.0.1]:2222)' can't be established.
ECDSA key fingerprint is SHA256:Mbx+h27hCg53i+8+cP92tnBmbnJrp7puZFGwYLL6TuA.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '[localhost]:2222' (ECDSA) to the list of known hosts.
root@localhost's password:
Welcome to Ubuntu 16.04.4 LTS (GNU/Linux 4.10.0-38-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

root@elk:~# cd /ELASTIC/
root@elk:/ELASTIC# ls -1F
common.sh*
elasticsearch-6.3.0/
elk.sh*
filebeat-6.3.0-amd64.deb
kibana-6.3.0-linux-x86_64/
log/
logstash-6.3.0/
```
