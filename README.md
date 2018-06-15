# ElasticSearch Stacks

ElasticSearch is based on [Apache Lucene](https://lucene.apache.org/):

> Elasticsearch is a distributed, RESTful search and analytics engine capable of solving a growing number of use cases. As the heart of the Elastic Stack, it centrally stores your data so you can discover the expected and uncover the unexpected.

ElasticSearch  is generally bundled with a data processing pipeline and a Web UI. These three products make a **stack**. The *de facto* standard is Elastic's own **ELK stack**, consisting of open source [ElasticSearch](https://www.elastic.co/products/elasticsearch), [Logstash](https://www.elastic.co/products/logstash) and [Kibana](https://www.elastic.co/products/kibana). Since the introduction of [Beats](https://www.elastic.co/products/beats) the **ELK stack** has been renamed as the **Elastic Stack**. The current Docker scripts install the [Filebeats](https://www.elastic.co/products/beats/filebeat) also.

In the so-called **EFK stack** [Fluentd](https://www.fluentd.org/) replaces ElasticSearch's own **Logstash** in the well-known **ELK stack**:

>Fluentd is an open source data collector for unified logging layer.

In each [efk](./src/efk) and [elk](./src/elk) directories you can find all configuration file's originals, with **.orig** extension, and the modified versions, so that easy differentiation is possible.

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
efk-server/app      0.0.6               1b212fcf1d8f        48 seconds ago      1.43GB
efk-server/base     0.0.6               b677a93f36a7        9 minutes ago       1.14GB
ubuntu              16.04               5e8b97a2a082        35 hours ago        114MB
```

Docker containers can be listed and removed with **docker container** family commands.
For more information check its manual pages or its [Docker Docs](https://docs.docker.com/engine/reference/commandline/container/) page.

```
$ man docker-container
$ man docker-container-ls
$ man docker-container-rm

$ docker container ls
CONTAINER ID        IMAGE                  COMMAND                  CREATED              STATUS              PORTS                                                                                                                    NAMES
66667978a228        efk-server/app:0.0.6   "sh -c /${DIR_PROJEC…"   About a minute ago   Up About a minute   0.0.0.0:5601->5601/tcp, 0.0.0.0:8888->8888/tcp, 0.0.0.0:9200->9200/tcp, 0.0.0.0:24224->24224/tcp, 0.0.0.0:2222->22/tcp   efk
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

$ ./docker.sh efk
. . .
++ 'base' image is ready   : elastic/base:0.0.1

++ 'stack' image is missing: elastic/efk:0.0.1

Building efk
Step 1/25 : ARG arg_base_tag
Step 2/25 : FROM "elastic/base:${arg_base_tag}"
 ---> cf7a3d9677c3
Step 3/25 : ARG arg_dir_project=EFK
 ---> Running in e97dd3fcfd51
Removing intermediate container e97dd3fcfd51
. . .
efk     | -- started
efk     |
efk     | [2018-06-14T20:49:38,619][INFO ][o.e.c.s.MasterService    ] [t-An6Kj] zen-disco-elected-as-master ([0] nodes joined), reason: new_master {t-An6Kj}{t-An6KjeRtWVd5BOPA5qPQ}{F0y1rY8eQLm210Q8-Pyabg}{127.0.0.1}{127.0.0.1:9300}
efk     | [2018-06-14T20:49:38,623][INFO ][o.e.c.s.ClusterApplierService] [t-An6Kj] new_master {t-An6Kj}{t-An6KjeRtWVd5BOPA5qPQ}{F0y1rY8eQLm210Q8-Pyabg}{127.0.0.1}{127.0.0.1:9300}, reason: apply cluster state (from master [master {t-An6Kj}{t-An6KjeRtWVd5BOPA5qPQ}{F0y1rY8eQLm210Q8-Pyabg}{127.0.0.1}{127.0.0.1:9300} committed version [1] source [zen-disco-elected-as-master ([0] nodes joined)]])
```

The running containers can be stopped with CTRL+C:

```
^CGracefully stopping... (press Ctrl+C again to force)
Stopping efk ...
Killing efk ... done
```

The **ubuntu:16:04** is the where **elastic/base** is derived from, and in turn the **elastic/efk**  and **elastic/elk** image is derived from this base image.

The containers can be stopped and/or removed with the script's **down** option:

```
$ ./docker.sh down
++ stopping and removing containers

++ IMAGE LIST:
REPOSITORY          TAG                 IMAGE ID            CREATED              SIZE
elastic/efk         0.0.1               9579db15cf1e        About a minute ago   1.44GB
elastic/elk         0.0.1               f72ddb4f4570        3 hours ago          1.47GB
elastic/base        0.0.1               cf7a3d9677c3        3 hours ago          1.14GB
ubuntu              16.04               5e8b97a2a082        8 days ago           114MB

++ CONTAINER LIST:
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES

Removing efk ... done
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
$ ./docker.sh efk det
STACK   : efk
DETACHED: true

++ IMAGE LIST:
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
elastic/efk         0.0.1               9579db15cf1e        4 minutes ago       1.44GB
elastic/elk         0.0.1               f72ddb4f4570        3 hours ago         1.47GB
elastic/base        0.0.1               cf7a3d9677c3        3 hours ago         1.14GB
ubuntu              16.04               5e8b97a2a082        8 days ago          114MB

++ CONTAINER LIST:
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES

++ 'base' image is ready   : elastic/base:0.0.1

++ 'stack' image is ready  : elastic/efk:0.0.1

Creating network "src_default" with the default driver
Creating efk ... done

++ CONTAINER LIST:
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                  PORTS                                                                                            NAMES
4700b1bc7ada        elastic/efk:0.0.1   "sh -c /${DIR_PROJEC…"   1 second ago        Up Less than a second   0.0.0.0:5601->5601/tcp, 0.0.0.0:8888->8888/tcp, 0.0.0.0:24224->24224/tcp, 0.0.0.0:2222->22/tcp   efk

$ ./docker.sh down
```
&nbsp;

## Testing

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

root@efk:~# cd /EFK/
root@efk:/EFK# ls -1
common.sh
efk.sh
elasticsearch-6.2.4
kibana-6.2.4-linux-x86_64
```
