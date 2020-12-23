#!/bin/bash

set -e

start-maintenance ()
{
    appName=$1
    domain=$2
    hostname=$3

    cf map-route maintenance-mode ${domain} -n ${hostname}
    cf unmap-route ${appName} ${domain} -n ${hostname}
}

echo "Running deploy maintenance"

git clone git@maintenance_mode_repo:pivotal/txp-maintenance-mode.git txp-maintenance-mode

cd txp-maintenance-mode

git checkout ruby-buildpack-1-8-15
git pull origin ruby-buildpack-1-8-15

source /.bashrc
rbenv local 2.6.4

gem install bundler -v 1.17.2
bundle install

cf api ${PCF_DESTINATION_API_ENDPOINT}
cf auth ${PCF_USERNAME} ${PCF_PASSWORD}
cf target -o ${PCF_ORG} -s ${PCF_SPACE}

cf push -f manifest.yml
start-maintenance whiteboard $PCF_DOMAIN $WHITEBOARD_HOSTNAME