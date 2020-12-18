#!/bin/bash
set -eu

export BUILDKITE_PLUGIN_S3_SECRETS_BUCKET=${TEST_BUCKET?}

pre_exit() {
  source hooks/pre-exit
}

trap pre_exit EXIT
source hooks/environment

if [[ -d example-private-repository ]] ; then
  rm -rf example-private-repository
fi

echo "+++ Cloning private repository with https"
git clone -- https://github.com/lox/example-private-repository.git example-private-repository
rm -rf example-private-repository
