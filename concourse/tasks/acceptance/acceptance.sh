#!/bin/bash

set -e -x

pushd acceptance-tests
    export WHITEBOARD_ENDPOINT=https://$TEMP_WHITEBOARD_HOSTNAME.$CF_DOMAIN
    echo $WHITEBOARD_ENDPOINT
    ./gradlew clean acceptanceTest
popd