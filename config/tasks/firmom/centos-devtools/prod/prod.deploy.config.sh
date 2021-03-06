#!/bin/bash
set -e

IMAGE="$1"
BASE_PORT="$2"
BASE_KEY="$3"

eval USERNAME=\${${BASE_KEY}USERNAME}
eval FIRSTNAME=\${${BASE_KEY}FIRSTNAME}
eval LASTNAME=\${${BASE_KEY}LASTNAME}
eval EMAIL=\${${BASE_KEY}EMAIL}
eval PASSWORD=\${${BASE_KEY}PASSWORD}
eval VNC_RESOLUTION=\${${BASE_KEY}VNC_RESOLUTION}
eval VNC_COL_DEPTH=\${${BASE_KEY}VNC_COL_DEPTH}

PORT_VNC_SYS=$(($BASE_PORT + 0))
PORT_VNC_CONN=$(($BASE_PORT + 1))
PORT_VNC_WEB=$(($BASE_PORT + 2))
PORT_80=$(($BASE_PORT + 3))
PORT_8080=$(($BASE_PORT + 4))
PORT_3000=$(($BASE_PORT + 5))
PORT_SFTP=$(($BASE_PORT + 6))

DEST_DIR_PATH="/data/deploy/devtools-prod-$USERNAME"
DEST_FILE_PATH="$DEST_DIR_PATH/docker-compose.yaml"

DEST_HELP_DIR_PATH="/data/deploy/devtools-prod-$USERNAME"
DEST_HELP_FILE_PATH="$DEST_HELP_DIR_PATH/README_PORTS_PROD.txt"

REMOTE_DIR_PATH="~/deploy/devtools-prod-$USERNAME"
REMOTE_FILE_PATH="$REMOTE_DIR_PATH/docker-compose.yaml"

REMOTE_HELP_DIR_PATH="/dockerdata/devtools/$USERNAME/work"
REMOTE_HELP_FILE_PATH="$REMOTE_HELP_DIR_PATH/README_PORTS_PROD.txt"

# Prepare config file
mkdir -p $DEST_DIR_PATH
cat > $DEST_FILE_PATH << EndOfMessage
version: '3'

## $USERNAME port list:
# (public port) -> (container port)
# $PORT_VNC_SYS -> 5000 (VNC system port)
# $PORT_VNC_CONN -> 5901 (VNC first desktop - use it for vnc viewer )
# $PORT_VNC_WEB -> 6901 (VNC web browser port)
# $PORT_80 -> 80 (default HTTP port)
# $PORT_8080 -> 8080 (external HTTP port)
# $PORT_3000 -> 3000 (development port)
# $PORT_SFTP -> 22 (SFTP port to share directory)
#
# Your personal data (never share):
# username: $USERNAME
# password: $PASSWORD

services:
  centos:
    image: $IMAGE
    ports:
     - "$PORT_VNC_SYS:5000"
     - "$PORT_VNC_CONN:5901"
     - "$PORT_VNC_WEB:6901"
     - "$PORT_80:80"
     - "$PORT_8080:8080"
     - "$PORT_3000:3000"
    volumes:
     - "/dockerdata/devtools/$USERNAME/share:/headless/Desktop/share"
     - "/dockerdata/devtools/$USERNAME/work:/headless/Desktop/work"
     - "/dockerdata/devtools/$USERNAME/atom:/headless/.atom"
     - "/dockerdata/devtools/$USERNAME/www:/var/www"
     - "/dockerdata/devtools/$USERNAME/fssh:/headless/.ssh"
    environment:
     - "SMTP_SERVER=$DEVTOOLS_SMTP_SERVER"
     - "SMTP_USERNAME=$DEVTOOLS_SMTP_USERNAME"
     - "SMTP_PASSWORD=$DEVTOOLS_SMTP_PASSWORD"
     - "VNC_RESOLUTION=$VNC_RESOLUTION"
     - "VNC_COL_DEPTH=$VNC_COL_DEPTH"
     - "VNC_PW=$PASSWORD"
     - "GIT_USER_EMAIL=$EMAIL"
     - "GIT_USER_NAME=$FIRSTNAME $LASTNAME"
  sftp:
    image: atmoz/sftp
    volumes:
     - "/dockerdata/devtools/$USERNAME/share:/home/$USERNAME/share"
    ports:
     - "$PORT_SFTP:22"
    command: "$USERNAME:$PASSWORD"

EndOfMessage

# Prepare help file
mkdir -p $DEST_HELP_DIR_PATH
cat > $DEST_HELP_FILE_PATH << EndOfMessage
## $USERNAME port list:
# (public port) -> (container port)
# $PORT_VNC_SYS -> 5000 (VNC system port)
# $PORT_VNC_CONN -> 5901 (VNC first desktop - use it for vnc viewer )
# $PORT_VNC_WEB -> 6901 (VNC web browser port)
# $PORT_80 -> 80 (default HTTP port)
# $PORT_8080 -> 8080 (external HTTP port)
# $PORT_3000 -> 3000 (development port)
# $PORT_SFTP -> 22 (SFTP port to share directory)
EndOfMessage

# Deploy config
ssh $DEPLOY_DEVTOOLS_REMOTE_USER@$DEPLOY_DEVTOOLS_REMOTE_HOST "mkdir -p $REMOTE_DIR_PATH"
scp -o "StrictHostKeyChecking no" "$DEST_FILE_PATH" "$DEPLOY_DEVTOOLS_REMOTE_USER@$DEPLOY_DEVTOOLS_REMOTE_HOST:$REMOTE_FILE_PATH"

# Deploy help
ssh $DEPLOY_DEVTOOLS_REMOTE_USER@$DEPLOY_DEVTOOLS_REMOTE_HOST "mkdir -p $REMOTE_HELP_DIR_PATH"
scp -o "StrictHostKeyChecking no" "$DEST_HELP_FILE_PATH" "$DEPLOY_DEVTOOLS_REMOTE_USER@$DEPLOY_DEVTOOLS_REMOTE_HOST:$REMOTE_HELP_FILE_PATH"

# Append app
ssh -o "StrictHostKeyChecking no" $DEPLOY_DEVTOOLS_REMOTE_USER@$DEPLOY_DEVTOOLS_REMOTE_HOST << ENDSSH
#commands to run on remote host
set -e

docker pull $IMAGE
cd $REMOTE_DIR_PATH
docker-compose rm --force --stop -v
docker-compose up -d

ENDSSH