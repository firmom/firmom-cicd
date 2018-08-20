#!/bin/sh
set -e

mkdir -p /data/docker/sebastianpozoga/events.pozoga.eu

cat > /data/docker/sebastianpozoga/events.pozoga.eu/docker-compose.yaml << EndOfMessage
version: '3.4'

services:
  events:
    image: spozoga/events.pozoga.eu
    environment:
      TZ: 'Europe/Warsaw'
    restart: always
    environment:
      - "DB_HOST=db"
      - "DB_PORT=3306"
      - "DB_NAME=dev.events.pozoga.eu"
      - "DB_USER=$EVENTS_POZOGA_EU_DB_USER"
      - "DB_PASS=$EVENTS_POZOGA_EU_DB_PASS"
      - "WP_USER=$EVENTS_POZOGA_EU_WP_USER_NAME"
      - "WP_PASS=$EVENTS_POZOGA_EU_WP_USER_PASS"
      - "WP_EMAIL=$EVENTS_POZOGA_EU_WP_USER_EMAIL"
      - "WP_HOST=$EVENTS_POZOGA_EU_WP_HOST:2012"
      - "WP_TITLE=Events Poznań"
      - "MIGRATE_FROM=http://events.pozoga.eu"
      - "MIGRATE_TO=http://$EVENTS_POZOGA_EU_WP_HOST:2012"
    volumes:
      - "/dockerdata/sebastianpozoga/events.pozoga.eu/uploads:/var/www/html/wp-content/uploads"
    ports:
      - 2012:8080
  db:
    image: mariadb
    restart: always
    environment:
      - "MYSQL_DATABASE=dev.events.pozoga.eu"
      - "MYSQL_USER=$EVENTS_POZOGA_EU_DB_USER"
      - "MYSQL_PASSWORD=$EVENTS_POZOGA_EU_DB_PASS"
      - "MYSQL_ROOT_PASSWORD=$EVENTS_POZOGA_EU_DB_PASS"
    volumes:
      - "/dockerdata/sebastianpozoga/events.pozoga.eu/mysql:/var/lib/mysql"
  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    restart: always
    ports:
     - 2013:80
    environment:
      - "PMA_HOST=db"
      - "PMA_VERBOSE=dev.events.pozoga.eu"
      - "PMA_PORT=3306"
      - "PMA_ARBITRARY=1"

EndOfMessage

scp -o "StrictHostKeyChecking no" /data/docker/sebastianpozoga/events.pozoga.eu/docker-compose.yaml $DEPLOY_DEV_REMOTE_USER@$DEPLOY_DEV_REMOTE_HOST:~/sebastianpozoga/events.pozoga.eu/docker-compose.yaml
