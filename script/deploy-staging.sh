#!/bin/bash

set -ev

echo $TRAVIS_BRANCH
echo $TRAVIS_PULL_REQUEST

if [[ "$TRAVIS_BRANCH" == "master" ]] && [[ "$TRAVIS_PULL_REQUEST" == false ]]; then
  wget -q -O cf-cli.deb https://cli.run.pivotal.io/stable?release=debian64
  sudo dpkg -i cf-cli.deb
  cf login -u $CF_USERNAME -p $CF_PASSWORD -o Pivotal-IPS -s whiteboard-staging -a https://api.run.pivotal.io
  git status
  git checkout .
  cf set-env whiteboard OKTA_SSO_TARGET_URL $OKTA_SSO_TARGET_URL
  cf set-env whiteboard OKTA_CERT_FINGERPRINT $OKTA_CERT_FINGERPRINT
  cf set-env whiteboard IP_WHITELIST $IP_WHITELIST
  bundle exec rake SPACE=whiteboard-staging cf:deploy:staging
fi
