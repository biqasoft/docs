![](logo.jpg?raw=true)

This is backend repository

## Architecture overview
 - frontend - [AngularJS](https://angularjs.org/)
 - client-server communication

### backend
 - Java 8 & [spring](https://spring.io/) 4.3 & [Spring Boot 1.4](http://projects.spring.io/spring-boot/)
 - [Swagger](http://swagger.io/) generated from Spring MVC
 - [MongoDB](https://www.mongodb.com/) - database
 - multitenancy (db for every domain)

## Microservices
They can be independent run

### [com.biqasoft.gateway](gateway)
 - port=8080
 - Public service
 - This is a main module. This is an API gateway for user requests Package com.biqasoft.gateway. `api.biqasoft.com`, - public api server, communicating with clients

### [com.biqasoft.datasourcebatching](data-source-batching)
 - port=9090
 - Not public service
 - Periodically(CRON) update KPI, dataSource, leadGenProjects/methods and save to history

### [com.biqasoft.control](control)
 - port=9091
 - Not public service
 - Internally system to control domains and users

### [com.biqasoft.async](gateway-async)
 - Alpha
 - port=9096
 - Public service
 - Async API (websocket streaming API)

### [com.biqasoft.database.backup](database-backup)
 - port=9095
 - Not public service
 - backup MongoDB database

### [com.biqasoft.exporter](exporter)
 - port=10010
 - Not public service
 - Export html to pdf using phantomjs and pandoc

### [com.biqasoft.exporter.excel](exporter-excel)
 - port=10015
 - Not public service
 - Export to excel

## Maven shared modules
Modules used in another modules, not executable

### [com.biqasoft.entity](entity)
Shared/common used object entities used across all projects. Http responses, DTO(Data Transfer Objects) and DAO

### [com.biqasoft.common](common)
Some spring services and other classes which is used across projects/modules

### [com.biqasoft.object-audit](object-audit)
Add createdInfo (created by user and date) to objects. Common aspects, processing custom fields

### com.biqasoft.base
This is parent module in project with dependency versions etc...

### [com.biqasoft.storage](storage)
Storage support such as Amazon S3, Google Drive, Dropbox, Webdav

### [com.biqasoft.microservice](microservice)
Microservice common

## Continuous Integration

 - [ci.sh](ci.sh) for production CI server
 - [ci-local.sh](ci-local.sh) for local developments and local tests

## Maven usage
All poms have one version (parent)

 - `https://maven.apache.org/guides/mini/guide-deployment-security-settings.html`
 - `https://maven.apache.org/settings.html`

## Project structure notes 

#### Change version

Version semantic `$YEAR$.$MONTH$.$MINOR_VERSION$`. For example if current month is 7 and year is 2016, version can be `2016.7.9`

Use versions:set from the versions-maven plugin:

Change version of module `mvn versions:set -DnewVersion=5.0.1-RELEASE`  set version for root (parent) module
It will adjust all pom versions, parent versions and dependency versions in a multi-module project.

If you made a mistake, do `mvn versions:revert` afterwards, or `mvn versions:commit`

To install parent(root) module `mvn install -N` / `mvn deploy -N`
 
You can deploy to artifactory (binary repo) using `mvn deploy` in every project 

## Build & Run
`StartApplication.java` - start class for Spring Boot

### Compiling & running steps
 - In project folder with `pom.xml` file run `mvn package`. You will have `*.jar` in `./target` folder.
 - run development environment with `java -jar api.biqasoft.com.jar --spring.profiles.active=development --spring.cloud.consul.host=192.168.127.131`
 - or run production environment with `java -jar api.biqasoft.com.jar --spring.profiles.active=production  --spring.cloud.consul.host=some_local_consul_agent.server`

### Running params

#### Mandatory
 - `--spring.cloud.consul.host=192.168.127.131` replace with address of consul
 - `spring.profiles.active=development` or `spring.profiles.active=production` for configuration
 - [mailgun](https://www.mailgun.com) credentials (send email messages with DKIM and spam filter)
 - AWS S3 (file storage)

| Option                                           | example                                           | mandatory | description                                                                                                                                                                                             |
| ------------------------------------------------ | ------------------------------------------------- | --------- | ------------------------------------------------------------------------------------------------- |
| biqa.security.global.root.enable                 |   TRUE                                            |    no     | this allow root user auth with `biqa.security.global.root.password` password. Disabled by default |
| biqa.internal.exception.strategy                 |   PRINT_STACKTRACE                                |    no     | values `PRINT_STACKTRACE` or `DO_NOT_PRINT` described in ThrowExceptionHelper.class. Print stack trace on user failed responses because of invalid request data. `DO_NOT_PRINT` by default.             |
| biqa.REQUIRE_ALL                                 |   TRUE                                            |    no     | some modules such as google drive, dropbox and some other are optional and work when you set up properties for them(such as api keys etc), so you can run system without them. But if you want to start with all modules, cou can force it|
| biqa.urls.http.cloud                             |   https://cloud.biqasoft.com                      |    yes    | |
| biqa.urls.http.support                           |   https://support.biqasoft.com                    |    yes    | |
| biqa.urls.email.support                          |   support@biqasoft.com                            |    yes    | |
| biqa.notification.email.sender.email             |   info@biqasoft.com                               |    yes    | |
| biqa.notification.header.system                  |   biqasoft.com                                    |    yes    | |
| mailgun.api.key                                  |   key-1812b2569a3d7923a5ed5                       |    yes    | |
| mailgun.api.url                                  |   https://api.mailgun.net/v2/example.com/messages |    yes    | |


##### API Gateway

| Option                                           | example                                           | mandatory | description                                                                                                                                                                                             |
| ------------------------------------------------ | ------------------------------------------------- | --------- | ------------------------------------------------------------------------------------------------- |
| biqa.urls.http.async                             |   http://localhost:9096                           |    yes    | async gateway url |


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
!!! WARNING !!! Every microservice with REST have `/health` endpoint. 
This endpoint have sensitive information and user should not have access to it(firewall or smth else should do it).
Spring actuator for main API url is `/internal`

## i18n

 - `com.biqasoft.microservice.i18n` package
 - `ThrowExceptionHelper.throwExceptionInvalidRequestLocalized("analytics.no_such_counter");`

## API

 - All microservices and gateway have Swagger `http://localhost:8080/v2/api-docs`

## Auth

 - you can auth with basic auth (username/token and password) as http header
 - send auth as param `http://api-server/v1/myaccount?token=T0FVVEgyX3JuaWspYmcsNitiWy0xPHoqY3UwOnc8Nih3NzAwNmcsdD44PyElW10t` where token is Base64.encode(`username:password`)

### API
 - basic auth is used (Authorization header with base64)
 - password can be used; tokens(generated by OAuth2 apps) can be used
 - passwords are hashed with bcrypt2

###
`LocalAuthenticationProvider.java` auth provider

### Root user auth

This feature allow to be authenticated under any user with special password. Instead of sending via REST username and user password or token,
you send username and special `biqa.security.global.root.password` as password.

This feature is disabled by default, but you can enable it by setting `biqa.security.global.root.enable` to `TRUE`.
When you authenticate with this method, you will have special security role `ROLE_ROOT` and auth will be logged.

### Java 9
 - to fix spring add `-addmods java.xml.bind` as VM options.
 - to fix aspectj aop see `com.biqasoft.common.hacks.Java9Fix` (org.aspectj.util.LangUtil line ~59 works incorrectly with jdk9 eap build) 
 - to run tests `env JAVA_HOME="C:\Program Files\Java\jdk-9" JRE_HOME="C:\Program Files\Java\jre-9" mvn package -Pjdk9` - and see maven profile jdk9

### Other

 - [ascii banner generator](http://patorjk.com/software/taag/#p=display&f=Big&t=biqasoft.com)

### DevOps

1) run consul `docker run --name=consul -d  -p 8400:8400 -p 8500:8500 -p 8600:53/udp -h node1 progrium/consul -server -bootstrap -ui-dir /ui`
2) for development run docker gliderlabs/registrator for consul

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

### Error levels logging

 - Trace - Only when I would be "tracing" the code and trying to find one part of a function specifically
 - Debug - Information that is diagnostically helpful to people more than just developers (IT, sysadmins, etc)
 - Info  - Generally useful information to log (service start/stop, configuration assumptions, etc). Info I want to always have available but usually dont care about under normal circumstances. This is my out-of-the-box config level
 - Warn  - Anything that can potentially cause application oddities, but for which I am automatically recoverring (such as switching from a primary to backup server, retrying an operation, missing secondary data, etc)
 - Error - Any error which is fatal to the operation but not the service or application (cant open a required file, missing data, etc). These errors will force user (administrator, or direct user) intervention. These are usually reserved (in my apps) for incorrect connection strings, missing services, etc.
 - Fatal - Any error that is forcing a shutdown of the service or application to prevent data loss (or further data loss). I reserve these only for the most heinous errors and situations where there is guaranteed to have been data corruption or loss.