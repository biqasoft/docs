#!/usr/bin/env bash

# This is file for CI and production env

# if you editing file in windows editor
# and have issue with `\r not found` - fix file with `dos2unix ci.sh` in unix cmd

# fail execution on any error
set -e

# git clone git@github.com:biqasoft/docs || true

BASE_PATH=`pwd`
BASE_PATH_CLONE=`pwd`/../

# main microservices, components and repos

cd $BASE_PATH_CLONE
git clone git@github.com:biqasoft/auth-gateway || true
git clone git@github.com:biqasoft/auth-microservie || true
git clone git@github.com:biqasoft/notification-microservice || true
git clone git@github.com:biqasoft/infrastructure-java || true
git clone git@github.com:biqasoft/gateway-microservice || true
git clone git@github.com:biqasoft/exporter-microservice || true
git clone git@github.com:biqasoft/bindings-java || true
git clone git@github.com:biqasoft/exporter-excel-microservice || true
git clone git@github.com:biqasoft/microservice-communicator || true
git clone git@github.com:biqasoft/manage-microservices || true
git clone git@github.com:biqasoft/databasebackup || true
git clone git@github.com:biqasoft/data-source-microservice || true
git clone git@github.com:biqasoft/frontend || true
