![](logo.jpg?raw=true)

## Architecture overview

Client-server, REST; with SPA [AngularJS](https://angularjs.org/)

## Links

 - Task tracker [trello](https://trello.com/b/EdfoGUUe/biqasoft-com-dev-public) 

## Microservices
They can run independently

Common all microservices technologies

### backend
 - Java 8 & [spring](https://spring.io/) [Spring Boot](http://projects.spring.io/spring-boot/)
 - [Swagger](http://swagger.io/) generated from Spring MVC
 - [MongoDB](https://www.mongodb.com/) - database
 - multitenancy (db for every domainDto)

## microservices
All run on different port, by default, so you can run on local machine for development. All have [docker packages on docker hub](https://hub.docker.com/r/biqasoft/)

 - [auth](https://github.com/biqasoft/auth-microservie)
 - [databasebackup](https://github.com/biqasoft/databasebackup)
 - [data-source](https://github.com/biqasoft/data-source-microservice)
 - [manage](https://github.com/biqasoft/manage-microservices)
 - [notification](https://github.com/biqasoft/notification-microservice)
 - [exporter-excel](https://github.com/biqasoft/exporter-excel-microservice)
 - [exporter](https://github.com/biqasoft/exporter-microservice)
 - [gateway](https://github.com/biqasoft/gateway-microservice)
 - [gateway-async](https://github.com/biqasoft/gateway-async-microservice)
 - [frontend](https://github.com/biqasoft/frontend)

## Maven shared modules
Modules used in different microservices; `NOTE` currently, they must use the same version

 - [bindings-java](https://github.com/biqasoft/bindings-java)
 - [infrastructure-java](https://github.com/biqasoft/infrastructure-java)

### infrastructure-java module

 - bpmn
 - common; Some spring services and other classes which is used across projects/modules
 - microservice-i18n
 - microservice; Microservice common
 - persistence; database, object audit: add createdInfo (created by user and date) to objects. Common aspects, processing custom fields
 - base; This is parent module in project with dependency versions etc
 - storage; Storage support such as Amazon S3, Google Drive, Dropbox, Webdav

### bindings-java
 
 - auth
 - authmicroservicecommunication
 - email-api
 - entity-core
 - entity; Shared/common used object entities used across all projects. Http responses, DTO(Data Transfer Objects) and DAO 

### Install
go to
/d/github-repos/biqasoft/infrastructure-java

ensure that you have java 10
```bash
export JAVA_HOME="C:\Program Files\Java\jdk-10"
```

set version of platform
```bash
export PROJECT_VERSION=2018.7.0
```

then in console execute script

```bash
./ci.sh dev
```

then go to  /cygdrive/d/github-repos/biqasoft/bindings-java and also execute

```bash
mvn clean install
```

## Run
`StartApplication.java` - start class for Spring Boot

### Running params

#### Mandatory
 - `--spring.cloud.consul.host=192.168.127.131` replace with address of consul
 - `spring.profiles.active=development` or `spring.profiles.active=production` for configuration
 - AWS S3 (file storage)

| Option                                           | example                                           | mandatory | description                                                                                                                                                                                             |
| ------------------------------------------------ | ------------------------------------------------- | --------- | ------------------------------------------------------------------------------------------------- |
| biqa.REQUIRE_ALL                                 |   TRUE                                            |    no     | some modules such as google drive, dropbox and some other are optional and work when you set up properties for them(such as api keys etc), so you can run system without them. But if you want to start with all modules, cou can force it|
| biqa.urls.http.cloud                             |   https://cloud.biqasoft.com                      |    yes    | |
| biqa.urls.http.support                           |   https://support.biqasoft.com                    |    yes    | |
| biqa.urls.email.support                          |   support@biqasoft.com                            |    yes    | |
| biqa.notification.email.sender.email             |   info@biqasoft.com                               |    yes    | |
| biqa.notification.header.system                  |   biqasoft.com                                    |    yes    | |

##### Profiles
You `must` manually specify profile to run every microservice or program startup will fail

 - `--spring.profiles.active=test` - Used for tests.
 - `--spring.profiles.active=development` - local development
 - `--spring.profiles.active=production` - production

#### Optional
Common arguments for running

 - `--spring.output.ansi.enabled=ALWAYS` Spring Boot: to enable color logging
 - `-Dhttp.proxyHost=127.0.0.1 -Dhttp.proxyPort=9999 -Dhttps.proxyHost=127.0.0.1 -Dhttps.proxyPort=9999 -Djava.net.useSystemProxies=true` :
just common argument to use local proxy for JVM (port 9999)

## Server metrics

You can get metrics provided by `spring boot actuator`. see `http://docs.spring.io/spring-boot/docs/current/reference/html/production-ready-endpoints.html`
`NOTE` Every microservice with REST have `/health` endpoint. 
This endpoint have sensitive information and user should not have access to it(firewall or smth else should do it).
Spring actuator for main API url is `/internal`

## i18n

 - `com.biqasoft.microservice.i18n` package
 - `ThrowExceptionHelper.throwExceptionInvalidRequestLocalized("analytics.no_such_counter");`

## API

 - All microservices and gateway have Swagger `http://localhost:8080/v2/api-docs`

## Auth API

 - you can auth with basic auth (username/token and password) as http header
 - send auth as param `http://api-server/v1/myaccount?token=T0FVVEgyX3JuaWspYmcsNitiWy0xPHoqY3UwOnc8Nih3NzAwNmcsdD44PyElW10t` where token is Base64.encode(`username:password`)
 - In Java Spring Security `GatewayAuthenticationProvider.java` auth provider which dispose to microservice authenticator

### Java 9
 - to fix spring add `-addmods java.xml.bind` as VM options.
 - to fix aspectj aop see `com.biqasoft.common.hacks.Java9Fix` (org.aspectj.util.LangUtil line ~59 works incorrectly with jdk9 eap build) 
 - to run tests `env JAVA_HOME="C:\Program Files\Java\jdk-9" JRE_HOME="C:\Program Files\Java\jre-9" mvn package -Pjdk9` - and see maven profile jdk9

### Other

 - [ascii banner generator](http://patorjk.com/software/taag/#p=display&f=Big&t=biqasoft.com)

## Run

You should replace folders, network interfaces to your

### Docker

1) run consul `docker run -d --net=host --name=consul -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' -e -client=0.0.0.0 -e 'CONSUL_BIND_INTERFACE=ens33' consul agent -server -ui -bootstrap`
2) for development run docker [gliderlabs/registrator](http://gliderlabs.com/registrator/latest/user/quickstart/) for consul

```bash
docker run -d \
    --name=registrator \
    --net=host \
    --volume=/var/run/docker.sock:/tmp/docker.sock \
    gliderlabs/registrator:latest \
    -ip="192.168.1.86" consul://localhost:8500
```

3) Run users microservice
```bash
# users
docker run --name=db-users -d -p 27018:27017 -v /home/microservices/users/mongodb/data:/data/db -P -e "SERVICE_NAME=db-users" biqasoft/mongodb:3.4.1
db.createUser({user: "v2jGUCHOtqfzahgDH6p27pzmUq8MtyqKCnXkQyiz", pwd: "@FU%1QOe>sz5Y,gmy9gvc?sYBg%Bf4xhRk^aSa", roles: [ { role: "root", db: "admin" } ] } )
```
4) Run main tenant database storage

```bash
#tenant
docker run --name=db-tenant-1 -d -p 27019:27017 -v /home/microservices/tenant-1/mongodb/data:/data/db -P -e "SERVICE_NAME=db-tenant-1" biqasoft/mongodb:3.4.1
db.createUser({user: "3rTbIgJ2btIy8xWxAiFiSW8394Om11mSkZdHsdKr", pwd: "nusZHFul8bt0mKZKmLsHXjvmcQ88Ra4mhlURxiEM", roles: [ { role: "root", db: "admin" } ] } )
```

`NOTE`:
 - most of microservices require mongodb; insted of running your own mongodb instances, you can use [mongodb atlas](https://www.mongodb.com/cloud/atlas/pricing)
 - all microservices require connection to consul

### Optional

#### Run S3-compatible API server

```bash
docker run -d -p 9000:9000 --name minio \
-e "MINIO_ACCESS_KEY=AKIActAMPLE" \
-e "MINIO_SECRET_KEY=wJalrX4ghEXAMPLEKEY" \
-v /home/nbakaev/minio/export/minio1:/export \
-v /home/nbakaev/minio/config/minio1:/root/.minio \
minio/minio /export
```

further for development example run `docker start consul registrator db-tenant-1 db-users`

## Build own

Current build steps for java-infrastructure and java-binding is compilcated and will be refactored.
Currently to build all modules, you should build in following order

![](images/build_steps_java_infra.png?raw=true)

### Compiling & running steps
 - In project folder with `pom.xml` file run `mvn package`. You will have `*.jar` in `./target` folder.
 - run development environment with `java -jar api.biqasoft.com.jar --spring.profiles.active=development --spring.cloud.consul.host=192.168.127.131`
 - or run production environment with `java -jar api.biqasoft.com.jar --spring.profiles.active=production  --spring.cloud.consul.host=some_local_consul_agent.server`

## Maven usage
All poms have one parent with common libs versions

#### Versioning

##### Microservices

Version semantic `$YEAR$.$MONTH$.$MINOR_VERSION$`. For example if current month is 7 and year is 2016, version can be `2016.7.9`

Use versions:set from the versions-maven plugin:

Change version of module `mvn versions:set -DnewVersion=5.0.1-RELEASE`  set version for root (parent) module
It will adjust all pom versions, parent versions and dependency versions in a multi-module project.

If you made a mistake, do `mvn versions:revert` afterwards, or `mvn versions:commit`
To install parent(root) module `mvn install -N` / `mvn deploy -N`
You can deploy to artifactory (binary repo) using `mvn deploy` in every project 

##### Libs

For libs, such as:

 - [bindings-java](https://github.com/biqasoft/bindings-java)
 - [infrastructure-java](https://github.com/biqasoft/infrastructure-java)

[semver](http://semver.org/) is used

### Maven Standard Directory Layout

| Path               |   Description                                |                               
| ------------------ | -------------------------------------------- |
| src/main/java	     |   Application/Library sources                |
| src/main/resources |	 Application/Library resources              |
| src/main/filters	 |   Resource filter files                      |
| src/main/config	 |   Configuration files                        |
| src/main/scripts	 |   Application/Library scripts                |
| src/main/webapp	 |   Web application sources                    |
| src/test/java	     |   Test sources                               |
| src/test/resources |	 Test resources                             |
| src/test/filters	 |   Test resource filter files                 |
| src/it	         |   Integration Tests (primarily for plugins)  |
| src/assembly	     |   Assembly descriptors                       |
| src/site	         |   Site                                       |
| LICENSE.txt	     |   Project's license                          |
| NOTICE.txt	     |   Notices and attributions                   |
| README.txt	     |   Project's readme                           |
