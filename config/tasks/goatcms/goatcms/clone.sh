#!/bin/sh
set -e

REPO_URL="https://github.com/goatcms/goatcms"
DIRECTORY="/data/code/goatcms/goatcms"

if [ -d "$DIRECTORY" ]; then
  cd "$DIRECTORY"
  git reset --hard
  git clean -f -d
  git pull
fi

if [ ! -d "$DIRECTORY" ]; then
  git clone "$REPO_URL" "$DIRECTORY"
fi

rm -rf /go/src/github.com/goatcms/goatcms ||:
ln -s //data/code/goatcms/goatcms /go/src/github.com/goatcms/goatcms
