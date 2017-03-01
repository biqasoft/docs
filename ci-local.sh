#!/usr/bin/env bash

# This is file for local development

# if you editing file in windows editor
# and have issue with `\r not found` - fix file with `dos2unix ci.sh` in unix cmd

# fail execution on any error
set -e

echo "Usage ci-local.sh buildAll"

updateVersion (){
    # change version of parent module
    mvn build-helper:parse-version versions:set -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.nextIncrementalVersion} --quiet
}

buildAll (){
SECONDS=0
base_path=`pwd`

# mvn clean all target folders
mvn clean --quiet

# do not execute tests
export mvnParams="-DskipTests"

# install parent module
mvn install -N "$mvnParams"

cd $base_path
cd persistence
# install manage module
mvn install -N "$mvnParams"

# install entity-core module
cd $base_path
cd persistence/mongodb-core
mvn install "$mvnParams"

# install entity-core module
cd $base_path
cd persistence/customer
mvn install "$mvnParams"

# install entity-core module
cd $base_path
cd persistence/datasource
mvn install "$mvnParams"

# install entity-core module
cd $base_path
cd entity-core
mvn install "$mvnParams"

# install entity module
cd $base_path
cd entity
mvn install "$mvnParams"

# install common module
cd $base_path
cd common
mvn install "$mvnParams"

# install bpmn module
cd $base_path
cd bpmn
mvn install "$mvnParams"

# install storage (s3...) module
cd $base_path
cd storage
mvn install "$mvnParams"

# install microservice module
cd $base_path
cd microservice
mvn install "$mvnParams"

# install microservice-i18n module
cd $base_path
cd microservice-i18n
mvn install "$mvnParams"

cd $base_path
cd notifications
# install notifications module
mvn install -N "$mvnParams"

# install notifications module
cd $base_path
cd notifications
mvn install -N "$mvnParams"

# install notifications/email-api module
cd $base_path
cd notifications/email-api
mvn install "$mvnParams"

# install persistence parent module
cd $base_path
cd persistence
mvn install -N "$mvnParams"

# install persistence/mongodb module
cd $base_path
cd persistence/mongodb
mvn install "$mvnParams"

# install persistence/object-audit module
cd $base_path
cd persistence/object-audit
mvn install "$mvnParams"

# install auth module
cd $base_path
cd auth
mvn install "$mvnParams"

# package auth-microservice
cd $base_path
cd auth-microservice
mvn package "$mvnParams"

# package gateway microservice
cd $base_path
cd gateway
mvn package "$mvnParams"

cd $base_path
cd manage
# install manage module
mvn install -N "$mvnParams"

# package control microservice
cd $base_path
cd manage/control
mvn package "$mvnParams"

# package database-backup microservice
cd $base_path
cd manage/database-backup
mvn package "$mvnParams"

# package data-source-batching microservice
cd $base_path
cd data-source-batching
mvn package "$mvnParams"

# package server-async microservice
cd $base_path
cd gateway-async
mvn package "$mvnParams"

# package exporter microservice
cd $base_path
cd exporter
mvn package "$mvnParams"

# package exporter-excel microservice
cd $base_path
cd exporter-excel
mvn package "$mvnParams"

# package exporter-excel microservice
cd $base_path
cd notifications/email-microservice
mvn package "$mvnParams"

cd $base_path

# maven version
PROJECT_VERSION="`mvn org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.version 2> /dev/null |grep -Ev '(^\[|Download\w+:)'`"
# in docker tag we can not use plus sign(`+`) - replace it with `_`
PROJECT_VERSION_DOCKER=`echo $PROJECT_VERSION | tr + _`

echo "                                               "
echo "###############################################"
echo "###############  SUCCESS BUILD ################"
echo "###############################################"
echo "                                               "
echo "Maven version is $PROJECT_VERSION"
echo "Docker tag is $PROJECT_VERSION_DOCKER"

duration=$SECONDS
echo "Build for: $(($duration / 60)) minutes and $(($duration % 60)) seconds"
echo "###############################################"
}

# execute function from command line such as `./main.js build`
$@
