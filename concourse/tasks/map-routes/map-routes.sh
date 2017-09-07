#!/bin/bash

set -e -x

wget -q -O cf-cli.deb https://cli.run.pivotal.io/stable?release=debian64
sudo dpkg -i cf-cli.deb
cf login -u $CF_USERNAME -p $CF_PASSWORD -o $CF_ORG -s $CF_SPACE -a $CF_API_ENDPOINT

cf unmap-route maintenance-mode $CF_DOMAIN -n $WHITEBOARD_HOSTNAME
cf unmap-route whiteboard $CF_DOMAIN -n $TEMP_WHITEBOARD_HOSTNAME
cf map-route whiteboard $CF_DOMAIN -n $WHITEBOARD_HOSTNAME

