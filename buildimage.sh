#!/bin/bash

docker rmi --force eborges/phpnginx7.1:latest
docker build -t eborges/phpnginx7.1:latest .
