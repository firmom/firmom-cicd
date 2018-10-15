#!/bin/sh
set -e

REPO="$1"
TAG="$2"
IMAGE="$3"
DEST_DIR_PATH="/data/deploy/$REPO-$TAG"
DEST_FILE_PATH="$DEST_DIR_PATH/docker-compose.yaml"

mkdir -p $DEST_DIR_PATH

# Add config file
cat > $DEST_FILE_PATH << EndOfMessage
version: '3.4'

services:
  main:
    image: $IMAGE
    environment:
      TZ: 'Europe/Warsaw'
    restart: always
    environment:
    volumes:
      - "/dockerdata/$REPO-$TAG/data:/app/data"
      - "/dockerdata/certs/firmom.com:/certs"
    ports:
      - 2079:443
  db:
    image: mariadb
    restart: always
    environment:
      - "MYSQL_DATABASE=dev.GoatCMSEmptyapp"
      - "MYSQL_USER=$GOATCMSEMPTYAPP_DB_USER"
      - "MYSQL_PASSWORD=$GOATCMSEMPTYAPP_DB_PASS"
      - "MYSQL_ROOT_PASSWORD=$GOATCMSEMPTYAPP_DB_PASS"
    volumes:
      - "/dockerdata/$REPO-$TAG/mysql:/var/lib/mysql"
  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    restart: always
    ports:
     - 12079:80
    environment:
      - "PMA_HOST=db"
      - "PMA_VERBOSE=dev.GoatCMSEmptyapp"
      - "PMA_PORT=3306"
      - "PMA_ARBITRARY=1"

EndOfMessage