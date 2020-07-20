#!/bin/bash

wget -q -O cf-cli.deb https://cli.run.pivotal.io/stable?release=debian64
sudo dpkg -i cf-cli.deb
cf login -u $CF_USERNAME -p $CF_PASSWORD -o $CF_ORG -s $CF_SPACE -a $CF_API_ENDPOINT

cd whiteboard

cf set-env whiteboard GIT_SHA `git rev-parse HEAD`
cf set-env whiteboard OKTA_SSO_TARGET_URL $OKTA_SSO_TARGET_URL
cf set-env whiteboard OKTA_CERT_FINGERPRINT $OKTA_CERT_FINGERPRINT
cf set-env whiteboard IP_WHITELIST $IP_WHITELIST
cf set-env whiteboard SENTRY_DSN $SENTRY_DSN
cf set-env whiteboard WHITEBOARD_MAILER_URL $WHITEBOARD_MAILER_URL
cf set-env whiteboard SECRET_KEY_BASE $SECRET_KEY_BASE
cf set-env whiteboard IDP_METADATA_XML_URL $IDP_METADATA_XML_URL
cf set-env whiteboard WS1_AUDIENCE WS1_AUDIENCE

if [ "$ENVIRONMENT" == "production" ] ; then
    cf set-env whiteboard NEWRELIC_APP_NAME $NEWRELIC_APP_NAME
    cf set-env whiteboard NEWRELIC_LICENSE $NEWRELIC_LICENSE
fi

bundle install

#takes hostname from config/cf-{ENVIRONMENT}.yml manifest
cf push -f concourse/manifests/$ENVIRONMENT.yml
