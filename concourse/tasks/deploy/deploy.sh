#!/bin/bash

wget -q -O cf-cli.deb https://cli.run.pivotal.io/stable?release=debian64
sudo dpkg -i cf-cli.deb
cf login -u $CF_USERNAME -p $CF_PASSWORD -o $CF_ORG -s $CF_SPACE -a https://api.run.pivotal.io
cf set-env whiteboard OKTA_SSO_TARGET_URL $OKTA_SSO_TARGET_URL
cf set-env whiteboard OKTA_CERT_FINGERPRINT $OKTA_CERT_FINGERPRINT
cf set-env whiteboard IP_WHITELIST $IP_WHITELIST
cd whiteboard
bundle install
bundle exec rake SPACE=$CF_SPACE cf:deploy:$ENVIRONMENT