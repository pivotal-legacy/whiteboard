#!/bin/bash

set -e -x
export IDP_METADATA_XML_URL=$TEST_IDP_METADATA_XML_URL

#    before install
export DISPLAY=:99.0
sh -e /etc/init.d/xvfb start
gem install bundler -v 1.10.6

#    install
bundle install --with development

/etc/init.d/mysql start

#    before script
bundle exec rake db:setup

#    script
xvfb-run -a bundle exec rspec

