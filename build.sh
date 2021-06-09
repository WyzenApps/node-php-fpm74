#!/bin/sh

TAG=${1:-"node-php-fpm74"}

docker build -f Dockerfile --tag ${TAG}:latest .

