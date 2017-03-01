#!/usr/bin/env bash

# This is file for CI and production env

# if you editing file in windows editor
# and have issue with `\r not found` - fix file with `dos2unix ci.sh` in unix cmd

# fail execution on any error
set -e

# do not execute tests
export mvnParams=-DskipTests

# 1) change version of parent module
mvn build-helper:parse-version versions:set -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.nextIncrementalVersion}
# 2) deploy parent module
mvn deploy -N "$mvnParams"

# 3) deploy diffs module
cd entity
mvn deploy "$mvnParams"

# 4) deploy common module
cd ./../common
mvn deploy

# 5) deploy storage (s3...) module
cd ./../storage
mvn deploy "$mvnParams"

# 6) deploy microservice module
cd ./../microservice
mvn deploy "$mvnParams"

# 4) install common module
cd ./../object-audit
mvn install "$mvnParams"

# 7) deploy auth module
cd ./../auth
mvn deploy "$mvnParams"

# 7) deploy auth module
cd ./../auth-microservice
mvn deploy

# 8) deploy gateway module
cd ./../gateway
mvn deploy "$mvnParams"

# 9) deploy control module
cd ./../control
mvn deploy "$mvnParams"

# 12) deploy database-backup module
cd ./../database-backup
mvn deploy "$mvnParams"

# 13) deploy data-source-batching module
cd ./../data-source-batching
mvn deploy "$mvnParams"

# 14) deploy gateway-async module
cd ./../gateway-async
mvn deploy "$mvnParams"

# 15) deploy exporter module
cd ./../exporter
mvn deploy "$mvnParams"

# 15) deploy exporter-excel module
cd ./../exporter-excel
mvn deploy "$mvnParams"

# go to root folder
cd ./../

# maven version
PROJECT_VERSION="`mvn org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.version 2> /dev/null |grep -Ev '(^\[|Download\w+:)'`"
# in docker tag we can not use plus sign(`+`) - replace it with `_`
PROJECT_VERSION_DOCKER=`echo $PROJECT_VERSION | tr + _`

echo "PROJECT_VERSION is $PROJECT_VERSION"
echo "PROJECT_VERSION_DOCKER is $PROJECT_VERSION_DOCKER"

# add updated versions to git
# add tag and push
git add */pom.xml
git commit -m "$PROJECT_VERSION auto commit [ci-skip]"
git tag -a "$PROJECT_VERSION" -m "Auto increment version $PROJECT_VERSION"
git push --follow-tags