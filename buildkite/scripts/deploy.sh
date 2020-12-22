#!/bin/bash

set -e

cf login -u $PCF_USERNAME -p $PCF_PASSWORD -o $PCF_ORG -s $PCF_SPACE -a $PCF_DESTINATION_API_ENDPOINT

cf set-env whiteboard GIT_SHA `git rev-parse HEAD`
cf set-env whiteboard OKTA_SSO_TARGET_URL $OKTA_SSO_TARGET_URL
cf set-env whiteboard OKTA_CERT_FINGERPRINT $OKTA_CERT_FINGERPRINT
cf set-env whiteboard IP_WHITELIST $IP_WHITELIST
cf set-env whiteboard SENTRY_DSN $SENTRY_DSN
cf set-env whiteboard WHITEBOARD_MAILER_URL $WHITEBOARD_MAILER_URL
cf set-env whiteboard SECRET_KEY_BASE $SECRET_KEY_BASE
cf set-env whiteboard IDP_METADATA_XML_URL $IDP_METADATA_XML_URL
cf set-env whiteboard WS1_AUDIENCE $WS1_AUDIENCE
cf set-env whiteboard WHITEBOARD_MAILER_FROM_ADDRESS $WHITEBOARD_MAILER_FROM_ADDRESS

if [ "$ENVIRONMENT" == "production" ] ; then
    cf set-env whiteboard NEWRELIC_APP_NAME $NEWRELIC_APP_NAME
    cf set-env whiteboard NEWRELIC_LICENSE $NEWRELIC_LICENSE
fi

source /.bashrc
rbenv local 2.6.2

gem install bundler -v 2.0.2
bundle install

cf push -f buildkite/manifests/$ENVIRONMENT.yml
