#!/bin/bash

set -e

cf login -u $PCF_USERNAME -p $PCF_PASSWORD -o $PCF_ORG -s $PCF_SPACE -a $PCF_DESTINATION_API_ENDPOINT

cf unmap-route maintenance-mode $PCF_DOMAIN -n $WHITEBOARD_HOSTNAME
cf unmap-route whiteboard $CF_TEMP_DOMAIN -n $TEMP_WHITEBOARD_HOSTNAME
cf map-route whiteboard $PCF_DOMAIN -n $WHITEBOARD_HOSTNAME

