#!/bin/bash

set -e -x

#start-maintenance ()
#{
#    appName=$1
#    domain=$2
#    hostname=$3
#
#    cf map-route maintenance-mode ${domain} -n ${hostname}
#    cf unmap-route ${appName} ${domain} -n ${hostname}
#}
#
## get CF CLI
#wget -q -O cf-cli.deb https://cli.run.pivotal.io/stable?release=debian64
#sudo dpkg -i cf-cli.deb
#cf login -u $CF_USERNAME -p $CF_PASSWORD -o $CF_ORG -s $CF_SPACE -a $CF_API_ENDPOINT
#
#cd maintenance-mode
#bundle install
#
#cf push -f manifest.yml
#start-maintenance whiteboard $CF_DOMAIN $WHITEBOARD_HOSTNAME

git clone git@github.com:pivotal-legacy/maintenance-mode.git