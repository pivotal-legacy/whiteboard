#!/bin/bash

set -e

cat /etc/ssh/ssh_config

git clone git@whiteboard_acceptance_repo:pivotal/whiteboard-acceptance-tests.git acceptance-tests

cd acceptance-tests
export WHITEBOARD_ENDPOINT=https://$TEMP_WHITEBOARD_HOSTNAME.$CF_TEMP_DOMAIN
echo $WHITEBOARD_ENDPOINT
./gradlew clean acceptanceTest