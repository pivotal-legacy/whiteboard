#!/bin/bash

set -e

git clone git@github.com-repo-1:pivotal/whiteboard-acceptance-tests.git acceptance-tests

cd acceptance-tests
export WHITEBOARD_ENDPOINT=https://$TEMP_WHITEBOARD_HOSTNAME.$CF_TEMP_DOMAIN
echo $WHITEBOARD_ENDPOINT
./gradlew clean acceptanceTest