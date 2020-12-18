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
start-maintenance ()
{
    appName=$1
    domain=$2
    hostname=$3

    cf map-route maintenance-mode ${domain} -n ${hostname}
    cf unmap-route ${appName} ${domain} -n ${hostname}
}

echo "checking loaded keys"
ssh-add -l

ls -la ~/.ssh
ls -la /etc/ssh
cat /etc/ssh/ssh_config

echo "Running deploy maintenance"

git clone git@github.com-repo-1:pivotal/txp-maintenance-mode.git txp-maintenance-mode
cd txp-maintenance-mode

git checkout ruby-buildpack-1-8-15

gem install bundler -v 1.17.2
bundle install

cf api ${PCF_API_ENDPOINT}
cf auth ${PCF_USERNAME} ${PCF_PASSWORD}
cf target -o ${PCF_ORG} -s ${PCF_SPACE}

cf push -f manifest.yml
start-maintenance whiteboard $PCF_DOMAIN $WHITEBOARD_HOSTNAME