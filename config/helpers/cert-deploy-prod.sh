#!/bin/sh
set -e

REPO="$1"
TAG="$2"
CERT="$3"
SRC="/etc/letsencrypt/live/$CERT/."
DEST="/dockerdata/certs/$CERT"

# Deploy certs
ssh $DEPLOY_PROD_REMOTE_USER@$DEPLOY_PROD_REMOTE_HOST "mkdir -p $DEST"
scp -rp -o "StrictHostKeyChecking no" "$SRC" "$DEPLOY_PROD_REMOTE_USER@$DEPLOY_PROD_REMOTE_HOST:$DEST"
